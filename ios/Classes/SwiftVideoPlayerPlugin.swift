import Flutter
import UIKit

public class SwiftVideoPlayerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "video_player_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftVideoPlayerPlugin()
    let factory = VideoPlayerFactory(messenger:registrar.messenger())
    registrar.register(factory as FlutterPlatformViewFactory,withId:"video_player_plugin")
  }
}
