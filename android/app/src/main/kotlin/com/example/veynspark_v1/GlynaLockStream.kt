package com.example.veynspark_v1

import android.app.KeyguardManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.PowerManager
import io.flutter.plugin.common.EventChannel

/**
 * État de verrouillage de l'appareil, pour les défis à minuteur.
 *
 * Lu dans les diffusions d'état d'écran et de verrouillage : écran éteint ou
 * écran de verrouillage affiché = verrouillé ; `ACTION_USER_PRESENT` =
 * déverrouillé. Émet l'état courant dès l'abonnement, puis chaque changement.
 * Aucune autorisation requise.
 */
class GlynaLockStream(private val context: Context) : EventChannel.StreamHandler {
    private val keyguard = context.getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager
    private val power = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
    private var sink: EventChannel.EventSink? = null
    private var last: Boolean? = null

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                Intent.ACTION_SCREEN_OFF -> emit(true)
                Intent.ACTION_USER_PRESENT -> emit(false)
                Intent.ACTION_SCREEN_ON -> emit(isLocked())
            }
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        sink = events
        last = null
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_OFF)
            addAction(Intent.ACTION_SCREEN_ON)
            addAction(Intent.ACTION_USER_PRESENT)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            context.registerReceiver(receiver, filter)
        }
        emit(isLocked())
    }

    override fun onCancel(arguments: Any?) {
        context.unregisterReceiver(receiver)
        sink = null
    }

    private fun isLocked(): Boolean =
        power?.isInteractive == false || keyguard?.isKeyguardLocked == true

    private fun emit(locked: Boolean) {
        if (locked == last) return
        last = locked
        sink?.success(locked)
    }
}
