public class VideoPlayerFactory: NSObject, FlutterPlatformViewFactory {
  let messenger:FlutterBinaryMessenger
  init(messenger:FlutterBinaryMessenger) {
    self.messenger=messenger
 }
 public func create(withFrame frame: CGRect,
                    viewIdentifier viewId: Int64,
                    arguments args: Any?) -> FlutterPlatformView {
  let channel = FlutterMethodChannel(name:"video_player_plugin"+String(viewId),binaryMessenger:messenger)
  return VideoPlayerPlatformView(channel:channel,
                             frame: frame, viewId: viewId,
                             messenger:messenger,
                             args: args)
 }
 public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
   return FlutterStandardMessageCodec.sharedInstance()
 }
}
