package com.openturath.ai

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** Acknowledge our own replacement. Android may require the user to tap Open. */
class UpdateReplacedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_MY_PACKAGE_REPLACED) return
        val prefs = context.getSharedPreferences("openturath_updater", 0)
        if (prefs.getString("status", "idle") != "waiting") return
        prefs.edit().putString("status", "installed").commit()
        try {
            context.packageManager.getLaunchIntentForPackage(context.packageName)?.let {
                it.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                context.startActivity(it)
            }
        } catch (_: Exception) {
            // Do not fight background launch restrictions or request privileged permissions.
            // The system installer still offers Open; next launch verifies the build.
        }
    }
}
