package com.example.caller

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.TelephonyManager

/**
 * Listens for the system phone-state broadcast and drives the caller-ID
 * overlay:
 *
 *   RINGING  -> resolve the number and show the floating card
 *   OFFHOOK  -> keep the card (call answered) — left visible
 *   IDLE     -> call ended/declined, remove the card
 *
 * The incoming number arrives in EXTRA_INCOMING_NUMBER, which the system only
 * delivers because the app holds READ_CALL_LOG + READ_PHONE_STATE. The
 * broadcast can fire several times per call, sometimes with the number on the
 * RINGING event and an empty extra afterwards, so we remember the last number
 * we saw for the current call.
 */
class PhoneStateReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != TelephonyManager.ACTION_PHONE_STATE_CHANGED) return

        val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
        val number = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)
        if (!number.isNullOrBlank()) {
            lastIncomingNumber = number
        }

        when (state) {
            TelephonyManager.EXTRA_STATE_RINGING -> {
                val n = lastIncomingNumber
                if (!n.isNullOrBlank()) {
                    CallerIdOverlay.show(context.applicationContext, n)
                }
            }
            TelephonyManager.EXTRA_STATE_OFFHOOK -> {
                // Call answered (here or elsewhere) — get out of the way so the
                // system in-call screen is visible.
                CallerIdOverlay.dismiss()
            }
            TelephonyManager.EXTRA_STATE_IDLE -> {
                CallerIdOverlay.dismiss()
                lastIncomingNumber = null
            }
        }
    }

    companion object {
        @Volatile
        private var lastIncomingNumber: String? = null
    }
}
