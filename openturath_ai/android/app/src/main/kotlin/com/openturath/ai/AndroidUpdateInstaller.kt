package com.openturath.ai

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import java.io.File

/** Installs only a newer, same-package APK signed by the existing publisher. */
class AndroidUpdateInstaller(private val activity: Activity) {
    companion object { const val INSTALL = 8092; const val PERMISSION = 8093 }
    private val prefs get() = activity.getSharedPreferences("openturath_updater", 0)

    @Suppress("DEPRECATION")
    private fun validate(path: String, expected: Long): File {
        val file = File(path).canonicalFile
        require(file.path.startsWith(File(activity.filesDir, "updates").canonicalPath + File.separator))
        require(file.isFile && file.extension == "apk")
        val pm = activity.packageManager
        val flags = if (Build.VERSION.SDK_INT >= 28) PackageManager.GET_SIGNING_CERTIFICATES else PackageManager.GET_SIGNATURES
        val candidate = requireNotNull(pm.getPackageArchiveInfo(file.path, flags))
        val current = pm.getPackageInfo(activity.packageName, flags)
        require(candidate.packageName == activity.packageName)
        val candidateVersion = if (Build.VERSION.SDK_INT >= 28) candidate.longVersionCode else candidate.versionCode.toLong()
        val currentVersion = if (Build.VERSION.SDK_INT >= 28) current.longVersionCode else current.versionCode.toLong()
        require(candidateVersion == expected && candidateVersion > currentVersion)
        val currentSigners = if (Build.VERSION.SDK_INT >= 28) current.signingInfo?.apkContentsSigners else current.signatures
        val candidateSigners = if (Build.VERSION.SDK_INT >= 28) {
            val info = candidate.signingInfo
            if (info?.hasMultipleSigners() == true) info.apkContentsSigners else info?.signingCertificateHistory
        } else candidate.signatures
        require(!currentSigners.isNullOrEmpty() && !candidateSigners.isNullOrEmpty())
        require(currentSigners.all { candidateSigners.contains(it) })
        return file
    }

    fun install(path: String, expected: Long): String {
        val file = validate(path, expected)
        prefs.edit().putString("path", file.path).putLong("build", expected).putString("status", "waiting").commit()
        if (Build.VERSION.SDK_INT >= 26 && !activity.packageManager.canRequestPackageInstalls()) {
            activity.startActivityForResult(Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                Uri.parse("package:${activity.packageName}")), PERMISSION)
            return "permission_required"
        }
        val uri = FileProvider.getUriForFile(activity, "${activity.packageName}.fileprovider", file)
        val intent = Intent(Intent.ACTION_INSTALL_PACKAGE).apply {
            data = uri
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            putExtra(Intent.EXTRA_RETURN_RESULT, true)
        }
        activity.startActivityForResult(intent, INSTALL)
        return "started"
    }

    fun onResult(request: Int, result: Int) {
        if (request == PERMISSION) {
            if (Build.VERSION.SDK_INT < 26 || activity.packageManager.canRequestPackageInstalls()) {
                try { install(requireNotNull(prefs.getString("path", null)), prefs.getLong("build", 0)) }
                catch (_: Exception) { prefs.edit().putString("status", "failed").apply() }
            } else prefs.edit().putString("status", "permission_denied").apply()
        } else if (request == INSTALL) {
            prefs.edit().putString("status", if (result == Activity.RESULT_OK) "installed" else "cancelled").apply()
        }
    }

    fun status(): String = prefs.getString("status", "idle") ?: "idle"
}
