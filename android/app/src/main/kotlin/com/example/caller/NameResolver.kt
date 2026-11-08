package com.example.caller

import android.content.Context
import android.net.Uri
import android.provider.ContactsContract
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder
import java.security.SecureRandom
import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec

/**
 * Resolves an incoming phone number to a display name for the caller-ID
 * overlay. Resolution order, cheapest first:
 *
 *   1. Device contacts (free, offline, instant)
 *   2. Local cache of previous backend lookups (free, offline)
 *   3. Backend /lookup directory (network, HMAC-signed, counts against the
 *      user's search quota — so results are cached aggressively)
 *
 * The token, device secret and API base URL are pushed here from the Flutter
 * side via the `caller/protect` method channel and stored in the shared
 * "caller_protect" preferences (see MainActivity.sync).
 */
object NameResolver {

    data class CallerInfo(
        val name: String?,
        val subtitle: String?,
        val isSpam: Boolean,
        val verified: Boolean,
        /** Absolute http(s) URL of the registered user's avatar, if any. */
        val avatarUrl: String? = null,
        /** content:// URI of the device contact's photo, if saved. */
        val contactPhotoUri: String? = null,
    ) {
        val hasName: Boolean get() = !name.isNullOrBlank()
    }

    /** Time-to-live for cached backend results. */
    private const val CACHE_TTL_MS = 7L * 24 * 60 * 60 * 1000 // 7 days

    /**
     * Blocking resolve — MUST be called off the main thread (it may hit the
     * network). Returns the best info we could find, or an empty CallerInfo.
     */
    fun resolve(context: Context, rawNumber: String): CallerInfo {
        if (normalize(rawNumber).isEmpty()) {
            return CallerInfo(null, null, isSpam = false, verified = false)
        }

        // Expand a local number ("7724239917" / "07724239917") to full E.164
        // ("+9647724239917") using the user's home dial code, so it matches the
        // directory (which stores international form). This E.164 is the single
        // canonical key for the cache and the backend query.
        val e164 = canonicalE164(context, rawNumber)

        // 1. Device contacts (try the raw number and the E.164 form). If the
        // saved contact has no photo, enrich with a previously cached account
        // avatar (free — no network, no quota).
        (contactLookup(context, rawNumber) ?: contactLookup(context, e164))?.let {
            return CallerInfo(
                name = it.first,
                subtitle = "In your contacts",
                isSpam = false,
                verified = false,
                avatarUrl = if (it.second == null) cacheRead(context, e164)?.avatarUrl else null,
                contactPhotoUri = it.second,
            )
        }

        // 2. Local cache (keyed on the canonical E.164).
        cacheRead(context, e164)?.let { return it }

        // 3. Backend directory.
        val fromBackend = backendLookup(context, e164)
        if (fromBackend != null) {
            cacheWrite(context, e164, fromBackend)
            return fromBackend
        }

        return CallerInfo(null, null, isSpam = false, verified = false)
    }

    /**
     * Builds an E.164-ish number from a raw incoming number using the user's
     * home [dialCode] (e.g. "964"):
     *   +9647724239917 -> +9647724239917   (already international)
     *   009647724239917 -> +9647724239917  (00 international prefix)
     *   07724239917 -> +9647724239917      (national trunk 0)
     *   7724239917 -> +9647724239917       (bare national)
     *   9647724239917 -> +9647724239917    (country code, no +)
     */
    /**
     * Public canonical form of [raw] using the stored home dial code — the
     * exact key the resolver/cache/backend use. Also handed to the app when
     * the user taps the banner, so the in-app lookup matches the directory.
     */
    fun canonicalE164(context: Context, raw: String): String {
        val dialCode = context
            .getSharedPreferences("caller_protect", Context.MODE_PRIVATE)
            .getString(KEY_HOME_DIAL_CODE, null)
        return toE164(raw, dialCode)
    }

    private fun toE164(raw: String, dialCode: String?): String {
        val trimmed = raw.trim()
        val hasPlus = trimmed.startsWith("+")
        var digits = trimmed.filter { it.isDigit() }
        if (digits.isEmpty()) return ""
        if (hasPlus) return "+$digits"
        if (digits.startsWith("00")) return "+" + digits.substring(2)
        val dc = dialCode?.filter { it.isDigit() }
        if (dc.isNullOrEmpty()) return "+$digits"
        if (digits.startsWith("0")) digits = digits.substring(1)
        if (digits.startsWith(dc)) return "+$digits"
        return "+$dc$digits"
    }

    // ---- 1. Contacts -------------------------------------------------------

    /** Returns (display name, photo content-uri or null) for a saved contact. */
    private fun contactLookup(context: Context, rawNumber: String): Pair<String, String?>? {
        return try {
            val uri = Uri.withAppendedPath(
                ContactsContract.PhoneLookup.CONTENT_FILTER_URI,
                Uri.encode(rawNumber),
            )
            context.contentResolver.query(
                uri,
                arrayOf(
                    ContactsContract.PhoneLookup.DISPLAY_NAME,
                    ContactsContract.PhoneLookup.PHOTO_URI,
                ),
                null, null, null,
            )?.use { c ->
                if (c.moveToFirst()) {
                    val name = c.getString(0)
                    val photo = c.getString(1)
                    if (!name.isNullOrBlank()) Pair(name, photo) else null
                } else null
            }
        } catch (_: SecurityException) {
            null // READ_CONTACTS not granted
        } catch (_: Exception) {
            null
        }
    }

    // ---- 3. Backend --------------------------------------------------------

    private fun backendLookup(context: Context, number: String): CallerInfo? {
        val prefs = context.getSharedPreferences("caller_protect", Context.MODE_PRIVATE)
        val baseUrl = prefs.getString(KEY_API_BASE, null)?.trimEnd('/') ?: return null
        val token = prefs.getString(KEY_AUTH_TOKEN, null) ?: return null
        val secret = prefs.getString(KEY_DEVICE_SECRET, null) ?: return null
        if (token.isEmpty() || secret.isEmpty()) return null

        return try {
            val encoded = URLEncoder.encode(number, "UTF-8")
            // Path must match exactly what the server sees as req.originalUrl,
            // because that string is part of the HMAC canonical payload.
            val pathWithQuery = "/api/v1/lookup?phone=$encoded"
            val ts = (System.currentTimeMillis() / 1000L).toString()
            val nonce = randomNonce()
            val canonical = "GET\n$pathWithQuery\n\n$ts\n$nonce"
            val signature = hmacSha256Hex(secret, canonical)

            val conn = (URL("$baseUrl$pathWithQuery").openConnection() as HttpURLConnection).apply {
                requestMethod = "GET"
                connectTimeout = 6000
                readTimeout = 6000
                setRequestProperty("Accept", "application/json")
                setRequestProperty("Authorization", "Bearer $token")
                setRequestProperty("X-Request-Timestamp", ts)
                setRequestProperty("X-Request-Nonce", nonce)
                setRequestProperty("X-Request-Signature", signature)
            }
            val code = conn.responseCode
            if (code != 200) {
                conn.disconnect()
                return null // 401/429/etc — fall back to "no name"
            }
            val body = BufferedReader(InputStreamReader(conn.inputStream)).use { it.readText() }
            conn.disconnect()
            parseLookup(body, baseUrl)
        } catch (_: Exception) {
            null
        }
    }

    private fun parseLookup(body: String, baseUrl: String): CallerInfo? {
        return try {
            val json = JSONObject(body)
            // NOTE: JSONObject.optString returns the literal string "null" when
            // the JSON value is null, so guard with isNull()/has() explicitly.
            val registeredName = json.stringOrNull("registered_name")
            val topName = json.stringOrNull("name")
            val isRegistered = json.optBoolean("is_registered", false)
            val spamReports = json.optInt("spam_reports", 0)
            val isSpam = json.optBoolean("is_spam", spamReports >= 3)
            val name = registeredName ?: topName
            // Registered avatar is served at a relative path like
            // "/uploads/avatars/x.jpg" — make it absolute against the API host.
            val avatar = json.stringOrNull("registered_avatar")?.let {
                if (it.startsWith("http")) it else baseUrl.trimEnd('/') + "/" + it.trimStart('/')
            }
            val subtitle = when {
                isSpam -> "Reported as spam ($spamReports)"
                isRegistered -> "Verified user"
                name != null -> "Identified by Yellow Fast Call"
                else -> "Not in directory"
            }
            CallerInfo(
                name = name,
                subtitle = subtitle,
                isSpam = isSpam,
                verified = isRegistered,
                avatarUrl = avatar,
            )
        } catch (_: Exception) {
            null
        }
    }

    // ---- 2. Cache ----------------------------------------------------------

    private fun cacheRead(context: Context, number: String): CallerInfo? {
        val prefs = context.getSharedPreferences(CACHE_PREFS, Context.MODE_PRIVATE)
        val raw = prefs.getString(number, null) ?: return null
        return try {
            val j = JSONObject(raw)
            if (System.currentTimeMillis() - j.optLong("at", 0) > CACHE_TTL_MS) {
                prefs.edit().remove(number).apply()
                return null
            }
            CallerInfo(
                name = j.optString("name").takeIf { it.isNotBlank() },
                subtitle = j.optString("subtitle").takeIf { it.isNotBlank() },
                isSpam = j.optBoolean("spam", false),
                verified = j.optBoolean("verified", false),
                avatarUrl = j.optString("avatar").takeIf { it.isNotBlank() },
            )
        } catch (_: Exception) {
            null
        }
    }

    private fun cacheWrite(context: Context, number: String, info: CallerInfo) {
        // Only cache something useful (a name or a spam flag).
        if (!info.hasName && !info.isSpam) return
        val prefs = context.getSharedPreferences(CACHE_PREFS, Context.MODE_PRIVATE)
        val j = JSONObject()
            .put("name", info.name ?: "")
            .put("subtitle", info.subtitle ?: "")
            .put("spam", info.isSpam)
            .put("verified", info.verified)
            .put("avatar", info.avatarUrl ?: "")
            .put("at", System.currentTimeMillis())
        prefs.edit().putString(number, j.toString()).apply()
    }

    // ---- image loading (called off the main thread by the overlay) ---------

    /**
     * Loads the caller's photo as a Bitmap — device contact photo first, then
     * the registered avatar URL. Returns null if neither is available.
     */
    fun loadAvatar(context: Context, info: CallerInfo): android.graphics.Bitmap? {
        info.contactPhotoUri?.let { uri ->
            try {
                context.contentResolver.openInputStream(Uri.parse(uri))?.use {
                    val bmp = android.graphics.BitmapFactory.decodeStream(it)
                    if (bmp != null) return bmp
                }
            } catch (_: Exception) {
            }
        }
        info.avatarUrl?.let { url ->
            try {
                val conn = (URL(url).openConnection() as HttpURLConnection).apply {
                    connectTimeout = 6000
                    readTimeout = 6000
                }
                if (conn.responseCode == 200) {
                    conn.inputStream.use {
                        val bmp = android.graphics.BitmapFactory.decodeStream(it)
                        conn.disconnect()
                        return bmp
                    }
                }
                conn.disconnect()
            } catch (_: Exception) {
            }
        }
        return null
    }

    // ---- helpers -----------------------------------------------------------

    /** Returns a trimmed non-empty string, or null for missing/JSON-null/"null". */
    private fun JSONObject.stringOrNull(key: String): String? {
        if (!has(key) || isNull(key)) return null
        val s = optString(key, "").trim()
        return if (s.isEmpty() || s.equals("null", ignoreCase = true)) null else s
    }

    private fun hmacSha256Hex(secret: String, message: String): String {
        val mac = Mac.getInstance("HmacSHA256")
        mac.init(SecretKeySpec(secret.toByteArray(Charsets.UTF_8), "HmacSHA256"))
        val bytes = mac.doFinal(message.toByteArray(Charsets.UTF_8))
        val sb = StringBuilder(bytes.size * 2)
        for (b in bytes) sb.append(String.format("%02x", b))
        return sb.toString()
    }

    private fun randomNonce(): String {
        val bytes = ByteArray(16)
        SecureRandom().nextBytes(bytes)
        return android.util.Base64.encodeToString(
            bytes,
            android.util.Base64.URL_SAFE or android.util.Base64.NO_PADDING or android.util.Base64.NO_WRAP,
        )
    }

    /** Keep a leading '+', strip everything else but digits. */
    private fun normalize(raw: String): String {
        val trimmed = raw.trim()
        if (trimmed.isEmpty()) return ""
        val hasPlus = trimmed.startsWith("+")
        val digits = trimmed.filter { it.isDigit() }
        if (digits.isEmpty()) return ""
        return if (hasPlus) "+$digits" else digits
    }

    // v2: bust entries cached before avatar support / by older app versions —
    // a stale "no avatar" entry would otherwise hide the photo for 7 days.
    const val CACHE_PREFS = "caller_id_cache_v2"
    const val KEY_API_BASE = "apiBaseUrl"
    const val KEY_AUTH_TOKEN = "authToken"
    const val KEY_DEVICE_SECRET = "deviceSecret"
    const val KEY_HOME_DIAL_CODE = "homeDialCode"
    const val KEY_CALLER_ID_ENABLED = "callerIdEnabled"
}
