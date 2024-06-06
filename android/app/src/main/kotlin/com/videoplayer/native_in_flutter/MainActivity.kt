package com.videoplayer.native_in_flutter

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity(){
    private val CHANNEL = "com.videoplayer.native_in_flutter"

    var result: MethodChannel.Result? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Set up the MethodChannel with the same name as defined in Dart
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            this.result=result
            if (call.method == "goToNativeView") {
                // Perform platform-specific operations and obtain the result
                val videoUrl: String? = call.argument("videoUrl")
                val videoText: String? = call.argument("videoText")
                val videoId: String? = call.argument("videoId")
                openSecondActivityForResult(videoUrl, videoText, videoId, result)
                // Send the result back to Flutter
            } else {
                result.notImplemented()
            }
        }
    }

    private fun openSecondActivityForResult(videoUrl: String?, videoText: String?, videoId: String?, result: MethodChannel.Result) {
        val intent = Intent(this, ViewPlayerActivity::class.java)
        intent.putExtra("videoUrl", videoUrl)
        intent.putExtra("videoText", videoText)
        intent.putExtra("videoId", videoId)
        startActivityForResult(intent,3001)
    }

    // We can do the assignment inside onAttach or onCreate
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode == Activity.RESULT_OK) {
            val state_data = data?.getStringExtra("state_data")
            println("STATE DATA => $state_data ")
            result?.success(state_data)
        }
    }
}
