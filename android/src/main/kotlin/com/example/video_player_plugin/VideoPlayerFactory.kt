package com.example.video_player_plugin

import android.content.Context
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * Factory for the VideoPlayer
 */
class VideoPlayerFactory(registrar:Registrar):PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    private var mPluginRegistrar: Registrar = registrar
    override fun create(context: Context, i: Int, o: Any?): PlatformView? {
        return VideoPlayer(context, mPluginRegistrar, i)
    }
}