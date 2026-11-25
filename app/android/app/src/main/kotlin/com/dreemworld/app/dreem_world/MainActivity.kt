package com.dreemworld.app.dreem_world

import android.Manifest
import android.content.pm.PackageManager
import android.media.MediaPlayer
import android.media.MediaRecorder
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Base64
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val recorderChannel = "dreemworld/voice_recorder"
    private val playerChannel = "dreemworld/voice_player"
    private val recordAudioRequest = 9101

    private var recorder: MediaRecorder? = null
    private var recordFile: File? = null
    private var recordStartMs: Long = 0L
    private var pendingRecordResult: MethodChannel.Result? = null

    private var player: MediaPlayer? = null
    private var playerFile: File? = null
    private var playerHandler: Handler? = null
    private var playerTicker: Runnable? = null
    private var playerMethodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, recorderChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> startRecording(result)
                    "stop" -> stopRecording(result)
                    "cancel" -> cancelRecording(result)
                    else -> result.notImplemented()
                }
            }

        val pChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, playerChannel)
        playerMethodChannel = pChannel
        pChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "setSource" -> setSource(call, result)
                "play" -> play(result)
                "pause" -> pause(result)
                "seek" -> seek(call, result)
                "release" -> releasePlayer(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun startRecording(result: MethodChannel.Result) {
        if (recorder != null) {
            result.error("already_recording", "Запись уже идет", null)
            return
        }
        val granted = ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) ==
            PackageManager.PERMISSION_GRANTED
        if (!granted) {
            pendingRecordResult = result
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.RECORD_AUDIO), recordAudioRequest)
            return
        }
        beginRecording(result)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == recordAudioRequest) {
            val result = pendingRecordResult
            pendingRecordResult = null
            if (result == null) return
            val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
            if (granted) {
                beginRecording(result)
            } else {
                result.error("permission_denied", "Разрешите доступ к микрофону в настройках приложения.", null)
            }
        }
    }

    private fun beginRecording(result: MethodChannel.Result) {
        try {
            val outFile = File(cacheDir, "voice_${System.currentTimeMillis()}.m4a")
            val r = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                MediaRecorder(this)
            } else {
                @Suppress("DEPRECATION")
                MediaRecorder()
            }
            r.setAudioSource(MediaRecorder.AudioSource.MIC)
            r.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
            r.setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
            r.setAudioEncodingBitRate(64000)
            r.setAudioSamplingRate(44100)
            r.setOutputFile(outFile.absolutePath)
            r.prepare()
            r.start()
            recorder = r
            recordFile = outFile
            recordStartMs = System.currentTimeMillis()
            result.success(null)
        } catch (e: Exception) {
            cleanupRecorder(deleteFile = true)
            result.error("record_start_failed", "Не удалось начать запись голоса: ${e.message}", null)
        }
    }

    private fun stopRecording(result: MethodChannel.Result) {
        val r = recorder
        val file = recordFile
        if (r == null || file == null) {
            result.success(null)
            return
        }
        try {
            r.stop()
        } catch (_: Exception) {
            cleanupRecorder(deleteFile = true)
            result.success(null)
            return
        }
        try {
            r.release()
        } catch (_: Exception) {}
        recorder = null
        val durationMs = (System.currentTimeMillis() - recordStartMs).coerceAtLeast(0L)
        try {
            val bytes = file.readBytes()
            val base64 = Base64.encodeToString(bytes, Base64.NO_WRAP)
            val dataUri = "data:audio/mp4;base64,$base64"
            result.success(mapOf("dataUri" to dataUri, "durationMs" to durationMs.toInt(), "mimeType" to "audio/mp4"))
        } catch (e: Exception) {
            result.error("record_read_failed", "Не удалось прочитать запись: ${e.message}", null)
        } finally {
            try { file.delete() } catch (_: Exception) {}
            recordFile = null
        }
    }

    private fun cancelRecording(result: MethodChannel.Result) {
        cleanupRecorder(deleteFile = true)
        result.success(null)
    }

    private fun cleanupRecorder(deleteFile: Boolean) {
        try { recorder?.reset() } catch (_: Exception) {}
        try { recorder?.release() } catch (_: Exception) {}
        recorder = null
        if (deleteFile) {
            try { recordFile?.delete() } catch (_: Exception) {}
        }
        recordFile = null
    }

    private fun setSource(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url")
        if (url.isNullOrBlank()) {
            result.error("bad_args", "url required", null)
            return
        }
        releasePlayerInternal()
        try {
            val p = MediaPlayer()
            if (url.startsWith("data:")) {
                val file = writeDataUriToTemp(url)
                playerFile = file
                p.setDataSource(file.absolutePath)
            } else {
                p.setDataSource(url)
            }
            p.setOnPreparedListener {
                result.success(mapOf("durationMs" to p.duration))
            }
            p.setOnCompletionListener {
                notifyPlayer("completed", mapOf("positionMs" to p.duration, "durationMs" to p.duration))
                stopTicker()
            }
            p.setOnErrorListener { _, what, extra ->
                notifyPlayer("error", mapOf("message" to "Ошибка воспроизведения ($what/$extra)"))
                true
            }
            p.prepareAsync()
            player = p
        } catch (e: Exception) {
            releasePlayerInternal()
            result.error("set_source_failed", e.message, null)
        }
    }

    private fun writeDataUriToTemp(dataUri: String): File {
        val comma = dataUri.indexOf(',')
        val base64Part = if (comma >= 0) dataUri.substring(comma + 1) else dataUri
        val bytes = Base64.decode(base64Part, Base64.DEFAULT)
        val ext = when {
            dataUri.contains("audio/mp4") || dataUri.contains("audio/m4a") -> "m4a"
            dataUri.contains("audio/mpeg") || dataUri.contains("audio/mp3") -> "mp3"
            dataUri.contains("audio/ogg") -> "ogg"
            dataUri.contains("audio/wav") -> "wav"
            else -> "webm"
        }
        val file = File(cacheDir, "voice_play_${System.currentTimeMillis()}.$ext")
        FileOutputStream(file).use { it.write(bytes) }
        return file
    }

    private fun play(result: MethodChannel.Result) {
        val p = player
        if (p == null) {
            result.error("no_player", "Источник не установлен", null)
            return
        }
        try {
            p.start()
            startTicker()
            result.success(null)
        } catch (e: Exception) {
            result.error("play_failed", e.message, null)
        }
    }

    private fun pause(result: MethodChannel.Result) {
        try { player?.pause() } catch (_: Exception) {}
        stopTicker()
        notifyPlayer("paused", currentPositionMap())
        result.success(null)
    }

    private fun seek(call: MethodCall, result: MethodChannel.Result) {
        val ms = call.argument<Int>("ms") ?: 0
        try { player?.seekTo(ms) } catch (_: Exception) {}
        result.success(null)
    }

    private fun releasePlayer(result: MethodChannel.Result) {
        releasePlayerInternal()
        result.success(null)
    }

    private fun releasePlayerInternal() {
        stopTicker()
        try { player?.stop() } catch (_: Exception) {}
        try { player?.release() } catch (_: Exception) {}
        player = null
        try { playerFile?.delete() } catch (_: Exception) {}
        playerFile = null
    }

    private fun startTicker() {
        if (playerHandler == null) playerHandler = Handler(Looper.getMainLooper())
        stopTicker()
        val h = playerHandler ?: return
        val r = object : Runnable {
            override fun run() {
                val p = player
                if (p != null && p.isPlaying) {
                    notifyPlayer("position", currentPositionMap())
                    h.postDelayed(this, 250)
                }
            }
        }
        playerTicker = r
        h.post(r)
    }

    private fun stopTicker() {
        val h = playerHandler
        val r = playerTicker
        if (h != null && r != null) h.removeCallbacks(r)
        playerTicker = null
    }

    private fun currentPositionMap(): Map<String, Int> {
        val p = player
        return if (p != null) {
            mapOf("positionMs" to p.currentPosition, "durationMs" to p.duration)
        } else {
            mapOf("positionMs" to 0, "durationMs" to 0)
        }
    }

    private fun notifyPlayer(event: String, args: Map<String, Any>) {
        val payload = HashMap<String, Any>(args)
        payload["event"] = event
        playerMethodChannel?.invokeMethod("event", payload)
    }

    override fun onDestroy() {
        cleanupRecorder(deleteFile = true)
        releasePlayerInternal()
        super.onDestroy()
    }
}
