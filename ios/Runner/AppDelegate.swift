import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  let controller = window?.rootViewController as! FlutterViewController
  let videoPlayerFactory = VideoPlayerFactory(controller:controller)
  registrar(forPlugin:"video_player_plugin").register(videoPlayerFactory,withId:"video_player_plugin")
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
