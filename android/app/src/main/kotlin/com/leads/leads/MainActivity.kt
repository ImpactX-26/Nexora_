package com.leads.leads

import android.app.role.RoleManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.leads.leads/url_interceptor"
    private val REQUEST_CODE_ROLE = 1001
    private var initialUrl: String? = null
    private var methodChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
        intent.dataString?.let { url ->
            methodChannel?.invokeMethod("onUrlIntercepted", url)
        }
    }

    private fun handleIntent(intent: Intent?) {
        if (intent?.action == Intent.ACTION_VIEW) {
            val url = intent.dataString
            if (!url.isNullOrEmpty()) {
                initialUrl = url
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialUrl" -> {
                    val url = initialUrl
                    initialUrl = null
                    result.success(url)
                }
                "isDefaultBrowser" -> {
                    result.success(checkIsDefaultBrowser())
                }
                "requestDefaultBrowser" -> {
                    requestDefaultBrowserRole()
                    result.success(true)
                }
                "openInExternalBrowser" -> {
                    val url = call.argument<String>("url")
                    if (url != null) {
                        val launched = openRealBrowser(url)
                        result.success(launched)
                    } else {
                        result.error("INVALID_URL", "URL cannot be null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun checkIsDefaultBrowser(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(Context.ROLE_SERVICE) as? RoleManager
            roleManager?.isRoleHeld(RoleManager.ROLE_BROWSER) ?: false
        } else {
            val testIntent = Intent(Intent.ACTION_VIEW, Uri.parse("https://google.com"))
            val resolveInfo = packageManager.resolveActivity(testIntent, PackageManager.MATCH_DEFAULT_ONLY)
            resolveInfo?.activityInfo?.packageName == packageName
        }
    }

    private fun requestDefaultBrowserRole() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(Context.ROLE_SERVICE) as? RoleManager
            if (roleManager != null && roleManager.isRoleAvailable(RoleManager.ROLE_BROWSER)) {
                val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_BROWSER)
                startActivityForResult(intent, REQUEST_CODE_ROLE)
                return
            }
        }
        // Fallback for older devices or custom OEM settings (e.g. ColorOS / Realme UI)
        try {
            val intent = Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS)
            startActivity(intent)
        } catch (e: Exception) {
            try {
                val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                    data = Uri.fromParts("package", packageName, null)
                }
                startActivity(intent)
            } catch (_: Exception) {}
        }
    }

    private fun openRealBrowser(rawUrl: String): Boolean {
        try {
            var formattedUrl = rawUrl.trim()
            if (!formattedUrl.startsWith("http://") && !formattedUrl.startsWith("https://")) {
                formattedUrl = "https://$formattedUrl"
            }
            val uri = Uri.parse(formattedUrl)

            // Find all installed browsers excluding ourselves
            val browserIntent = Intent(Intent.ACTION_VIEW, Uri.parse("https://google.com"))
            val resolveList = packageManager.queryIntentActivities(browserIntent, PackageManager.MATCH_ALL)

            // Known browser packages in priority order
            val popularBrowsers = listOf(
                "com.android.chrome",
                "com.heytap.browser",
                "com.coloros.browser",
                "com.sec.android.app.sbrowser",
                "org.mozilla.firefox",
                "com.microsoft.emmx",
                "com.brave.browser",
                "com.opera.browser"
            )

            var targetPackage: String? = null

            // 1. Try to find a popular browser
            for (pkg in popularBrowsers) {
                if (resolveList.any { it.activityInfo.packageName == pkg }) {
                    targetPackage = pkg
                    break
                }
            }

            // 2. Otherwise pick the first non-leads browser package
            if (targetPackage == null) {
                targetPackage = resolveList.firstOrNull { it.activityInfo.packageName != packageName }?.activityInfo?.packageName
            }

            val launchIntent = Intent(Intent.ACTION_VIEW, uri).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                if (targetPackage != null) {
                    setPackage(targetPackage)
                }
            }

            startActivity(launchIntent)
            return true
        } catch (e: Exception) {
            return false
        }
    }
}
