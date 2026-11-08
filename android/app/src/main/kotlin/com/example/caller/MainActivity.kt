package com.example.caller

import android.app.Activity
import android.app.role.RoleManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "caller/protect"
    private val roleRequestCode = 4711
    private val overlayRequestCode = 4712
    private var pendingRoleResult: MethodChannel.Result? = null
    private var pendingOverlayResult: MethodChannel.Result? = null
    private var channel: MethodChannel? = null
    // Number captured from a caller-ID overlay tap before Flutter is ready to
    // receive it; drained by the Dart side via "consumePendingLookup".
    private var pendingLookupNumber: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val ch = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        )
        channel = ch
        // The activity may have been launched (cold start) straight from an
        // overlay tap — stash the number so Dart can pick it up once ready.
        pendingLookupNumber =
            intent?.getStringExtra(CallerIdOverlay.EXTRA_LOOKUP_NUMBER)
        ch.setMethodCallHandler { call, result ->
            when (call.method) {
                "sync" -> {
                    val store = ProtectStore(applicationContext)
                    val settings = ProtectSettings(
                        blockSpam = call.argument<Boolean>("blockSpam") ?: true,
                        blockScam = call.argument<Boolean>("blockScam") ?: true,
                        silenceUnknown = call.argument<Boolean>("silenceUnknown") ?: false,
                        intlSpamFilter = call.argument<Boolean>("intlSpamFilter") ?: false,
                    )
                    store.writeSettings(settings)
                    val list = call.argument<List<String>>("blockList") ?: emptyList()
                    store.writeBlockList(list)
                    // Caller-ID credentials + endpoint, used by NameResolver to
                    // query the backend directory natively during a call.
                    store.writeCallerIdConfig(
                        apiBaseUrl = call.argument<String>("apiBaseUrl"),
                        authToken = call.argument<String>("authToken"),
                        deviceSecret = call.argument<String>("deviceSecret"),
                        homeDialCode = call.argument<String>("homeDialCode"),
                        callerIdEnabled = call.argument<Boolean>("callerIdEnabled") ?: true,
                    )
                    result.success(true)
                }
                "hasOverlayPermission" -> {
                    result.success(hasOverlayPermission())
                }
                "requestOverlayPermission" -> {
                    if (hasOverlayPermission()) {
                        result.success(true)
                        return@setMethodCallHandler
                    }
                    pendingOverlayResult = result
                    val intent = Intent(
                        Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:$packageName"),
                    )
                    startActivityForResult(intent, overlayRequestCode)
                }
                "isDefaultCallScreener" -> {
                    result.success(isDefaultCallScreener())
                }
                "requestCallScreenerRole" -> {
                    if (isDefaultCallScreener()) {
                        result.success(true)
                        return@setMethodCallHandler
                    }
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    val rm = getSystemService(RoleManager::class.java)
                    if (rm == null || !rm.isRoleAvailable(RoleManager.ROLE_CALL_SCREENING)) {
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    pendingRoleResult = result
                    val intent: Intent = rm.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING)
                    startActivityForResult(intent, roleRequestCode)
                }
                "blockedCount" -> {
                    result.success(ProtectStore(applicationContext).readBlockedCount())
                }
                "consumePendingLookup" -> {
                    val n = pendingLookupNumber
                    pendingLookupNumber = null
                    result.success(n)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun hasOverlayPermission(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)

    private fun isDefaultCallScreener(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return false
        val rm = getSystemService(RoleManager::class.java) ?: return false
        if (!rm.isRoleAvailable(RoleManager.ROLE_CALL_SCREENING)) return false
        return rm.isRoleHeld(RoleManager.ROLE_CALL_SCREENING)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        // App was already running when an overlay tap brought it forward: push
        // the number straight to Dart (its handler is registered by now).
        val number = intent.getStringExtra(CallerIdOverlay.EXTRA_LOOKUP_NUMBER)
        if (!number.isNullOrBlank()) {
            channel?.invokeMethod("openLookup", number) ?: run {
                pendingLookupNumber = number
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == roleRequestCode) {
            val granted = resultCode == Activity.RESULT_OK
            pendingRoleResult?.success(granted)
            pendingRoleResult = null
        } else if (requestCode == overlayRequestCode) {
            // The overlay settings screen doesn't return a useful resultCode,
            // so re-check the actual permission state.
            pendingOverlayResult?.success(hasOverlayPermission())
            pendingOverlayResult = null
        }
    }
}
