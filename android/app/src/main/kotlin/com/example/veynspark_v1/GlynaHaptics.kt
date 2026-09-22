package com.example.veynspark_v1

import android.content.Context
import android.media.AudioAttributes
import android.os.Build
import android.os.VibrationAttributes
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager

/**
 * Vibrations de Glyna, selon le tableau du brief (« Le plaisir de nettoyer »).
 * Les noms des moments sont ceux de `HapticMoment` côté Dart.
 *
 * Effets prédéfinis à partir d'Android 10, impulsions simples avant.
 */
class GlynaHaptics(context: Context) {
    private val vibrator: Vibrator? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            (context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager)
                ?.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
        }

    fun play(moment: String) {
        val vibrator = vibrator?.takeIf { it.hasVibrator() } ?: return
        when (moment) {
            "tileTap", "dragPickUp" ->
                predefined(vibrator, VibrationEffect.EFFECT_TICK, TICK_MS)
            "challengeAccepted", "dragDrop" ->
                predefined(vibrator, VibrationEffect.EFFECT_CLICK, CLICK_MS)
            "tileCleaned" ->
                predefined(vibrator, VibrationEffect.EFFECT_HEAVY_CLICK, HEAVY_MS)
            "gridCleared" -> doubleImpulse(vibrator)
        }
    }

    private fun predefined(vibrator: Vibrator, effectId: Int, fallbackMs: Long) {
        when {
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q ->
                vibrate(vibrator, VibrationEffect.createPredefined(effectId))
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.O ->
                vibrate(
                    vibrator,
                    VibrationEffect.createOneShot(fallbackMs, VibrationEffect.DEFAULT_AMPLITUDE),
                )
            else -> @Suppress("DEPRECATION") vibrator.vibrate(fallbackMs)
        }
    }

    /** Grille nettoyée : l'impact lourd de la tuile, puis une seconde impulsion. */
    private fun doubleImpulse(vibrator: Vibrator) {
        val click = VibrationEffect.Composition.PRIMITIVE_CLICK
        when {
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.R &&
                vibrator.areAllPrimitivesSupported(click) ->
                vibrate(
                    vibrator,
                    VibrationEffect.startComposition()
                        .addPrimitive(click, 1f)
                        .addPrimitive(click, 1f, SECOND_IMPULSE_DELAY_MS)
                        .compose(),
                )
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q ->
                vibrate(vibrator, VibrationEffect.createPredefined(VibrationEffect.EFFECT_DOUBLE_CLICK))
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.O ->
                vibrate(vibrator, VibrationEffect.createWaveform(DOUBLE_WAVEFORM, -1))
            else -> @Suppress("DEPRECATION") vibrator.vibrate(DOUBLE_WAVEFORM, -1)
        }
    }

    /** Déclarée comme retour tactile : le réglage système des vibrations au toucher s'applique. */
    private fun vibrate(vibrator: Vibrator, effect: VibrationEffect) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            vibrator.vibrate(
                effect,
                VibrationAttributes.createForUsage(VibrationAttributes.USAGE_TOUCH),
            )
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            @Suppress("DEPRECATION")
            vibrator.vibrate(
                effect,
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ASSISTANCE_SONIFICATION)
                    .build(),
            )
        }
    }

    private companion object {
        const val TICK_MS = 10L
        const val CLICK_MS = 20L
        const val HEAVY_MS = 40L
        const val SECOND_IMPULSE_DELAY_MS = 90
        val DOUBLE_WAVEFORM = longArrayOf(0, HEAVY_MS, 90, CLICK_MS)
    }
}
