package com.example.caller

import android.content.Context
import android.os.Build
import android.telecom.Call
import android.telecom.CallScreeningService
import androidx.annotation.RequiresApi

/**
 * Decides for every incoming call whether to let it ring, send it to
 * voicemail silently, or reject it outright. Reads its rules from a
 * dedicated SharedPreferences file ("caller_protect") that the Flutter
 * side keeps in sync via the platform method channel.
 *
 * Android 10+ (API 29) is required for CallScreeningService.onScreenCall.
 */
@RequiresApi(Build.VERSION_CODES.Q)
class CallBlockerService : CallScreeningService() {

    override fun onScreenCall(callDetails: Call.Details) {
        val number = extractNumber(callDetails)
        val store = ProtectStore(applicationContext)
        val decision = decide(number, store)

        val response = CallResponse.Builder().apply {
            if (decision.reject) {
                setDisallowCall(true)
                setRejectCall(true)
                setSkipCallLog(false)
                setSkipNotification(true)
            } else if (decision.silence) {
                setSilenceCall(true)
            }
        }.build()

        respondToCall(callDetails, response)

        if (decision.reject || decision.silence) {
            store.incrementBlockedCount()
        } else if (!number.isNullOrBlank()) {
            // Not blocked — show the caller-ID popup. onScreenCall gives the
            // most reliable number on modern Android, so this is the primary
            // trigger; PhoneStateReceiver handles dismissal when the call ends.
            CallerIdOverlay.show(applicationContext, number)
        }
    }

    private fun extractNumber(details: Call.Details): String? {
        val handle = details.handle ?: return null
        val schemeSpecific = handle.schemeSpecificPart ?: return null
        return normalize(schemeSpecific)
    }

    private fun decide(number: String?, store: ProtectStore): Decision {
        val settings = store.readSettings()
        val blockList = store.readBlockList()

        if (number != null && blockList.contains(number)) {
            return Decision(reject = true)
        }

        if (number == null || number.isEmpty()) {
            if (settings.silenceUnknown) return Decision(silence = true)
            return Decision()
        }

        if (settings.intlSpamFilter && number.startsWith("+") && !isLocalCountry(number)) {
            return Decision(reject = true)
        }

        return Decision()
    }

    private fun isLocalCountry(number: String): Boolean {
        // Without a configured home country we can't reliably tell which
        // numbers are "local", so treat anything with a + prefix as
        // international. The Flutter side will eventually pass the user's
        // country code; until then this filter is permissive.
        return false
    }

    private fun normalize(raw: String): String {
        val trimmed = raw.trim()
        if (trimmed.isEmpty()) return ""
        val hasPlus = trimmed.startsWith("+")
        val digits = trimmed.filter { it.isDigit() }
        if (digits.isEmpty()) return ""
        return if (hasPlus) "+$digits" else digits
    }

    private data class Decision(
        val reject: Boolean = false,
        val silence: Boolean = false,
    )
}

class ProtectStore(context: Context) {
    private val prefs = context.getSharedPreferences("caller_protect", Context.MODE_PRIVATE)

    fun readSettings(): ProtectSettings = ProtectSettings(
        blockSpam = prefs.getBoolean(KEY_BLOCK_SPAM, true),
        blockScam = prefs.getBoolean(KEY_BLOCK_SCAM, true),
        silenceUnknown = prefs.getBoolean(KEY_SILENCE_UNKNOWN, false),
        intlSpamFilter = prefs.getBoolean(KEY_INTL_SPAM, false),
    )

    fun writeSettings(s: ProtectSettings) {
        prefs.edit()
            .putBoolean(KEY_BLOCK_SPAM, s.blockSpam)
            .putBoolean(KEY_BLOCK_SCAM, s.blockScam)
            .putBoolean(KEY_SILENCE_UNKNOWN, s.silenceUnknown)
            .putBoolean(KEY_INTL_SPAM, s.intlSpamFilter)
            .apply()
    }

    fun readBlockList(): Set<String> = prefs.getStringSet(KEY_BLOCK_LIST, emptySet()) ?: emptySet()

    fun writeBlockList(list: List<String>) {
        prefs.edit().putStringSet(KEY_BLOCK_LIST, list.toSet()).apply()
    }

    /**
     * Stores the credentials + endpoint the native NameResolver needs to query
     * the backend directory during an incoming call. Null values are left
     * untouched so a partial sync never wipes a previously stored token.
     */
    fun writeCallerIdConfig(
        apiBaseUrl: String?,
        authToken: String?,
        deviceSecret: String?,
        homeDialCode: String?,
        callerIdEnabled: Boolean,
    ) {
        val e = prefs.edit()
        if (apiBaseUrl != null) e.putString(NameResolver.KEY_API_BASE, apiBaseUrl)
        if (authToken != null) e.putString(NameResolver.KEY_AUTH_TOKEN, authToken)
        if (deviceSecret != null) e.putString(NameResolver.KEY_DEVICE_SECRET, deviceSecret)
        if (homeDialCode != null) e.putString(NameResolver.KEY_HOME_DIAL_CODE, homeDialCode)
        e.putBoolean(NameResolver.KEY_CALLER_ID_ENABLED, callerIdEnabled)
        e.apply()
    }

    fun readBlockedCount(): Int = prefs.getInt(KEY_BLOCKED_COUNT, 0)

    fun incrementBlockedCount() {
        val next = readBlockedCount() + 1
        prefs.edit().putInt(KEY_BLOCKED_COUNT, next).apply()
    }

    companion object {
        const val KEY_BLOCK_SPAM = "blockSpam"
        const val KEY_BLOCK_SCAM = "blockScam"
        const val KEY_SILENCE_UNKNOWN = "silenceUnknown"
        const val KEY_INTL_SPAM = "intlSpamFilter"
        const val KEY_BLOCK_LIST = "blockList"
        const val KEY_BLOCKED_COUNT = "blockedCount"
    }
}

data class ProtectSettings(
    val blockSpam: Boolean,
    val blockScam: Boolean,
    val silenceUnknown: Boolean,
    val intlSpamFilter: Boolean,
)
