package com.openturath.ai

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.openturath.ai/native_launcher"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isNotebookAppInstalled" -> {
                    try {
                        packageManager.getPackageInfo("com.google.android.apps.labs.language.tailwind", 0)
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "openInNotebookApp" -> {
                    val url = call.argument<String>("url")
                    if (url.isNullOrEmpty()) {
                        result.error("INVALID_URL", "URL is null or empty", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
                            setPackage("com.google.android.apps.labs.language.tailwind")
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        if (intent.resolveActivity(packageManager) != null) {
                            startActivity(intent)
                            result.success(true)
                        } else {
                            try {
                                packageManager.getPackageInfo("com.google.android.apps.labs.language.tailwind", 0)
                                startActivity(intent)
                                result.success(true)
                            } catch (e: Exception) {
                                result.success(false)
                            }
                        }
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "shareText" -> {
                    val text = call.argument<String>("text") ?: ""
                    val title = call.argument<String>("title") ?: "Bagikan Modul"
                    try {
                        val sendIntent = Intent().apply {
                            action = Intent.ACTION_SEND
                            putExtra(Intent.EXTRA_TEXT, text)
                            type = "text/plain"
                        }
                        val shareIntent = Intent.createChooser(sendIntent, title).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(shareIntent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SHARE_FAILED", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
