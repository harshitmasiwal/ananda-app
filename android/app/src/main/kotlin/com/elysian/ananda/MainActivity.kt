package com.elysian.ananda

import android.app.WallpaperManager
import android.content.ContentValues
import android.content.Intent
import android.graphics.BitmapFactory
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.provider.Settings
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

class MainActivity : AudioServiceActivity() {
    private val WALLPAPER_CHANNEL = "com.elysian.ananda/wallpaper"
    private val RINGTONE_CHANNEL = "com.elysian.ananda/ringtone"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── Wallpaper Channel ────────────────────────────────────────────────
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WALLPAPER_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "setWallpaper") {
                    val filePath = call.argument<String>("filePath")
                    val location = call.argument<Int>("location") ?: 3 // 1: Home, 2: Lock, 3: Both

                    if (filePath == null) {
                        result.error("INVALID_PATH", "File path cannot be null", null)
                        return@setMethodCallHandler
                    }

                    Thread {
                        try {
                            val file = File(filePath)
                            if (!file.exists()) {
                                runOnUiThread {
                                    result.error("FILE_NOT_FOUND", "Wallpaper file does not exist", null)
                                }
                                return@Thread
                            }

                            val bitmap = BitmapFactory.decodeFile(file.absolutePath)
                            if (bitmap == null) {
                                runOnUiThread {
                                    result.error("DECODE_FAILED", "Failed to decode wallpaper image", null)
                                }
                                return@Thread
                            }

                            val wm = WallpaperManager.getInstance(applicationContext)

                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                val flags = when (location) {
                                    1 -> WallpaperManager.FLAG_SYSTEM
                                    2 -> WallpaperManager.FLAG_LOCK
                                    else -> WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK
                                }
                                wm.setBitmap(bitmap, null, true, flags)
                            } else {
                                wm.setBitmap(bitmap)
                            }

                            runOnUiThread {
                                result.success(true)
                            }
                        } catch (e: Exception) {
                            runOnUiThread {
                                result.error("SET_WALLPAPER_ERROR", e.localizedMessage, null)
                            }
                        }
                    }.start()
                } else {
                    result.notImplemented()
                }
            }

        // ── Ringtone Channel ─────────────────────────────────────────────────
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, RINGTONE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "canWriteSettings" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            result.success(Settings.System.canWrite(applicationContext))
                        } else {
                            result.success(true)
                        }
                    }
                    "openWriteSettings" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            try {
                                val intent = Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS).apply {
                                    data = Uri.parse("package:" + applicationContext.packageName)
                                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                }
                                applicationContext.startActivity(intent)
                                result.success(true)
                            } catch (e: Exception) {
                                try {
                                    val fallbackIntent = Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS).apply {
                                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                    }
                                    applicationContext.startActivity(fallbackIntent)
                                    result.success(true)
                                } catch (e2: Exception) {
                                    result.error("INTENT_ERROR", e2.localizedMessage, null)
                                }
                            }
                        } else {
                            result.success(true)
                        }
                    }
                    "setRingtone" -> {
                        val filePath = call.argument<String>("filePath")
                        val title = call.argument<String>("title") ?: "Ringtone"
                        val ringtoneType = call.argument<Int>("type") ?: 1 // 1: Ringtone, 2: Notification, 3: Alarm, 4: All

                        if (filePath == null) {
                            result.error("INVALID_PATH", "File path cannot be null", null)
                            return@setMethodCallHandler
                        }

                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.System.canWrite(applicationContext)) {
                            result.error("PERMISSION_DENIED", "WRITE_SETTINGS permission not granted", null)
                            return@setMethodCallHandler
                        }

                        Thread {
                            try {
                                val file = File(filePath)
                                if (!file.exists()) {
                                    runOnUiThread { result.error("FILE_NOT_FOUND", "Audio file does not exist", null) }
                                    return@Thread
                                }

                                val contentResolver = applicationContext.contentResolver
                                val values = ContentValues().apply {
                                    put(MediaStore.MediaColumns.TITLE, title)
                                    put(MediaStore.MediaColumns.MIME_TYPE, "audio/mp3")
                                    put(MediaStore.Audio.Media.IS_RINGTONE, ringtoneType == 1 || ringtoneType == 4)
                                    put(MediaStore.Audio.Media.IS_NOTIFICATION, ringtoneType == 2 || ringtoneType == 4)
                                    put(MediaStore.Audio.Media.IS_ALARM, ringtoneType == 3 || ringtoneType == 4)
                                    put(MediaStore.Audio.Media.IS_MUSIC, false)

                                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                                        put(MediaStore.MediaColumns.DISPLAY_NAME, "${file.nameWithoutExtension}_${System.currentTimeMillis()}.mp3")
                                        val subDir = when (ringtoneType) {
                                            2 -> Environment.DIRECTORY_NOTIFICATIONS
                                            3 -> Environment.DIRECTORY_ALARMS
                                            else -> Environment.DIRECTORY_RINGTONES
                                        }
                                        put(MediaStore.MediaColumns.RELATIVE_PATH, subDir)
                                    } else {
                                        put(MediaStore.MediaColumns.DATA, file.absolutePath)
                                    }
                                }

                                var uri: Uri? = null

                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                                    val collection = MediaStore.Audio.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
                                    uri = contentResolver.insert(collection, values)
                                    if (uri != null) {
                                        contentResolver.openOutputStream(uri)?.use { os ->
                                            FileInputStream(file).use { fis ->
                                                fis.copyTo(os)
                                            }
                                        }
                                    }
                                } else {
                                    uri = contentResolver.insert(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, values)
                                }

                                if (uri == null) {
                                    uri = Uri.fromFile(file)
                                }

                                if (ringtoneType == 1 || ringtoneType == 4) {
                                    RingtoneManager.setActualDefaultRingtoneUri(
                                        applicationContext,
                                        RingtoneManager.TYPE_RINGTONE,
                                        uri
                                    )
                                }
                                if (ringtoneType == 2 || ringtoneType == 4) {
                                    RingtoneManager.setActualDefaultRingtoneUri(
                                        applicationContext,
                                        RingtoneManager.TYPE_NOTIFICATION,
                                        uri
                                    )
                                }
                                if (ringtoneType == 3 || ringtoneType == 4) {
                                    RingtoneManager.setActualDefaultRingtoneUri(
                                        applicationContext,
                                        RingtoneManager.TYPE_ALARM,
                                        uri
                                    )
                                }

                                runOnUiThread { result.success(true) }
                            } catch (e: Exception) {
                                runOnUiThread { result.error("SET_RINGTONE_ERROR", e.localizedMessage, null) }
                            }
                        }.start()
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
