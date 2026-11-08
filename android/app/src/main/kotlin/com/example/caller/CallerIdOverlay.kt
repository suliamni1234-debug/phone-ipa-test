package com.example.caller

import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import android.widget.TextView

/**
 * Heads-up caller-ID banner pinned to the top of the screen while a call
 * rings. Info-only (name/photo/number/status) — answering/declining stays on
 * the system call UI, which remains visible and usable below. A single
 * instance lives for one call. All WindowManager work happens on the main
 * thread; name + photo lookups run on a background thread.
 */
object CallerIdOverlay {

    private val main = Handler(Looper.getMainLooper())
    private var windowManager: WindowManager? = null
    private var view: View? = null
    private var currentNumber: String? = null
    private var currentKey: String? = null

    /** When the current banner was shown — used to delay the name reveal. */
    private var shownAtMs: Long = 0L

    /** Photo + number show instantly; the name fades in this long after. */
    private const val NAME_REVEAL_DELAY_MS = 1000L

    fun canDraw(context: Context): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(context)

    /**
     * Show the screen for [rawNumber]; resolves name + photo in the background.
     * Safe to call multiple times per call — duplicates (keyed on the digits)
     * are ignored.
     */
    fun show(context: Context, rawNumber: String) {
        val appContext = context.applicationContext
        if (rawNumber.isBlank() || !canDraw(appContext)) return

        val enabled = appContext
            .getSharedPreferences("caller_protect", Context.MODE_PRIVATE)
            .getBoolean(NameResolver.KEY_CALLER_ID_ENABLED, true)
        if (!enabled) return

        val key = digitsKey(rawNumber)

        main.post {
            try {
                if (view != null && currentKey == key) return@post
                dismissInternal()
                addView(appContext, rawNumber, key)

                Thread {
                    val info = try {
                        NameResolver.resolve(appContext, rawNumber)
                    } catch (_: Exception) {
                        null
                    }
                    main.post { bind(key, info) }
                    // Photo is a second, slower step — fetch then push it in.
                    if (info != null) {
                        val bmp = try {
                            NameResolver.loadAvatar(appContext, info)
                        } catch (_: Exception) {
                            null
                        }
                        if (bmp != null) main.post { bindPhoto(key, bmp) }
                    }
                }.start()
            } catch (_: Exception) {
            }
        }
    }

    fun dismiss() {
        main.post { dismissInternal() }
    }

    // ---- internals ---------------------------------------------------------

    private fun addView(context: Context, rawNumber: String, key: String) {
        val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val v = LayoutInflater.from(context).inflate(R.layout.overlay_caller_id, null)

        v.findViewById<TextView>(R.id.overlay_number).text = rawNumber
        // The name stays hidden at first — only the photo/number show. It fades
        // in ~1s later once resolution finishes (see [bind]).
        v.findViewById<TextView>(R.id.overlay_name).apply {
            text = ""
            alpha = 0f
        }
        v.findViewById<TextView>(R.id.overlay_close).setOnClickListener { dismissInternal() }
        // Tapping the caller row opens the app on the full number-info screen.
        v.findViewById<View>(R.id.overlay_card).setOnClickListener {
            openInApp(context, rawNumber)
        }

        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }
        // Heads-up banner pinned to the top, like a system notification. The
        // window is NOT focusable / NOT touch-modal so the system incoming-call
        // UI below stays fully usable; taps inside the card still land on our
        // buttons. Shown over the lock screen, keeping the screen awake.
        @Suppress("DEPRECATION")
        val flags = WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            type,
            flags,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP
        }

        wm.addView(v, params)
        windowManager = wm
        view = v
        currentNumber = rawNumber
        currentKey = key
        shownAtMs = System.currentTimeMillis()
    }

    private fun bind(key: String, info: NameResolver.CallerInfo?) {
        if (view == null || currentKey != key) return

        val name = info?.name
        val spam = info?.isSpam == true

        // Reveal the name no sooner than ~1s after the banner appeared, then
        // keep it on screen for the rest of the call (fade it in for polish).
        val elapsed = System.currentTimeMillis() - shownAtMs
        val delay = (NAME_REVEAL_DELAY_MS - elapsed).coerceAtLeast(0L)
        main.postDelayed({
            val v = view ?: return@postDelayed
            if (currentKey != key) return@postDelayed
            val nameView = v.findViewById<TextView>(R.id.overlay_name)
            val initialsView = v.findViewById<TextView>(R.id.overlay_initials)
            val root = v.findViewById<View>(R.id.overlay_root)

            root.setBackgroundResource(
                if (spam) R.drawable.overlay_banner_bg_spam else R.drawable.overlay_banner_bg,
            )

            if (name.isNullOrBlank()) {
                nameView.text = "Unknown number"
                initialsView.text = "?"
            } else {
                nameView.text = name
                initialsView.text = initials(name)
            }
            nameView.animate().alpha(1f).setDuration(280).start()
        }, delay)
    }

    private fun bindPhoto(key: String, bmp: Bitmap) {
        val v = view ?: return
        if (currentKey != key) return
        val photo = v.findViewById<ImageView>(R.id.overlay_photo)
        val initials = v.findViewById<TextView>(R.id.overlay_initials)
        photo.setImageBitmap(bmp)
        photo.visibility = View.VISIBLE
        initials.visibility = View.GONE
    }

    private fun dismissInternal() {
        val v = view
        val wm = windowManager
        if (v != null && wm != null) {
            try {
                wm.removeView(v)
            } catch (_: Exception) {
            }
        }
        view = null
        windowManager = null
        currentNumber = null
        currentKey = null
    }

    /**
     * Launches the app (MainActivity) on the number-info screen for [rawNumber]
     * and dismisses the overlay. Carries the number as an intent extra that
     * MainActivity forwards to Flutter (see [EXTRA_LOOKUP_NUMBER]).
     */
    private fun openInApp(context: Context, rawNumber: String) {
        try {
            // Hand the app the canonical +E.164 form (e.g. 0770… → +964770…) so
            // its directory lookup matches regardless of how the call arrived.
            val number = NameResolver.canonicalE164(context, rawNumber)
                .ifBlank { rawNumber }
            val intent = Intent(context, MainActivity::class.java).apply {
                addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP,
                )
                putExtra(EXTRA_LOOKUP_NUMBER, number)
            }
            context.startActivity(intent)
        } catch (_: Exception) {
        }
        dismissInternal()
    }

    /** Intent extra carrying the number to look up when the app is opened. */
    const val EXTRA_LOOKUP_NUMBER = "caller_lookup_number"

    // ---- helpers -----------------------------------------------------------

    /** Digits-only key used to dedupe shows for the same caller. */
    private fun digitsKey(raw: String): String = raw.filter { it.isDigit() }

    private fun initials(name: String): String {
        val parts = name.trim().split(Regex("\\s+")).filter { it.isNotEmpty() }
        if (parts.isEmpty()) return "?"
        if (parts.size == 1) return parts[0].take(1).uppercase()
        return (parts.first().take(1) + parts.last().take(1)).uppercase()
    }
}
