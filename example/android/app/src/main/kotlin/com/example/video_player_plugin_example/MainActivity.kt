package com.example.video_player_plugin_example

import android.os.Bundle
import io.flutter.app.FlutterActivity

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(FlutterEngine(this))
        com.example.video_player_plugin.VideoPlayerPlugin.registerWith(this.registrarFor("Video_Player"))
    }
}
