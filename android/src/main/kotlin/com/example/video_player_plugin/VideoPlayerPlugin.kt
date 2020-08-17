package com.example.video_player_plugin

import android.content.Context
import android.net.Uri
import android.view.View
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.annotation.NonNull;
import com.google.android.exoplayer2.SimpleExoPlayer
import com.google.android.exoplayer2.source.MediaSource
import com.google.android.exoplayer2.source.ProgressiveMediaSource
import com.google.android.exoplayer2.ui.PlayerView
import com.google.android.exoplayer2.upstream.DataSource
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.platform.PlatformView

/** VideoPlayerPlugin */
/**
 * Plugin register with Registry
 */
class VideoPlayerPlugin: FlutterPlugin {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  /**
   * 2 function override of Flutter Plugin for API 2.0 use ( currently not use )
   */
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
  }

  override fun onDetachedFromEngine(p0: FlutterPlugin.FlutterPluginBinding) {
  }

  companion object {
    /**
     * Register plugin with the registry
     */
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      registrar
              .platformViewRegistry()
              .registerViewFactory(
                      "video_player_plugin", VideoPlayerFactory(registrar));
    }
  }
}



