import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

typedef void VideoPlayerCreatedCallback(VideoPlayerController controller);
typedef void VideoPlayerEndedCallback(VideoPlayerController controller);

class VideoPlayer extends StatefulWidget {
  ///Callback function when PlatformView is created
  final VideoPlayerCreatedCallback videoPlayerCreated;
  ///Callback function when video end
  final VideoPlayerEndedCallback videoPlayerEnded;
  ///Controller that control player
  VideoPlayerController controller;

///Constructor for the widget
  VideoPlayer({
    Key key,
    this.videoPlayerEnded,
    @required this.videoPlayerCreated,
  });
  @override
  _VideoPlayerState createState() => _VideoPlayerState();

  ///Assign callback function for when the Platform created
  Future<void> onPlatformViewCreated(id) async {
    if (videoPlayerCreated == null) {
      return;
    }
    videoPlayerCreated(controller = new VideoPlayerController.init(id, this));
  }

  ///Assign callback function for when video end
  Future<void> onVideoEnd() async{
    if(videoPlayerEnded==null){
      return;
    }
    videoPlayerEnded(controller);
  }
}

class _VideoPlayerState extends State<VideoPlayer> {
  /// Build widget that display video
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return
          /**
           *Create android view that display ExoPlayer on screen
           */
          AndroidView(
             ///Name of the channel will be used to communicate between Android
             ///host and Flutter client
            viewType: 'video_player_plugin',

             ///Assign method to invoke when this android view is created
            onPlatformViewCreated: widget.onPlatformViewCreated,

             ///The codec that will be used in the communication
            creationParamsCodec: const StandardMessageCodec(),
          );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
       ///TODO: IOS implementation
      return UiKitView(
        viewType: 'video_player_plugin',
        onPlatformViewCreated: widget.onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
  }
}

class VideoPlayerController {
  /// Method channel instance that will handle the communication between android
  /// host and flutter client
  MethodChannel _methodChannel;

  /// The instance of video player widget that will display the video
  VideoPlayer player;

  /// Default controller of player is disable, this variable hold that
  bool isNativeControllerEnabled = false;

  VideoPlayerController.init(int id, VideoPlayer player) {
     ///Create new MethodChannel to cummunicate with native
    _methodChannel = new MethodChannel('video_player_plugin_$id');

     ///Assign player to controller
    this.player = player;

     ///Set method that will handle the call of native Android host
     ///to Flutter client
    _methodChannel.setMethodCallHandler((call) {
      print("Method ${call.method} call");
      switch (call.method) {

       ///Android host will call back to Flutter client when the state of player
       ///has changed
        case "stateChange":
          switch (call.arguments){

           ///When player has ended
            case "ended":
              player.onVideoEnd();
              return;


           ///When player idle ( has nothing to play )
            case "idle":
              ///Insert code here
              return;

           ///When player is buffering media
            case "buffering":
              ///Insert code here
              return;

           ///When player is ready to play
            case "ready":
              ///Insert code here
              return;

              ///Throw exception if not recognised this arguments
            default:
              throw PlatformException(code: 'stateChange/${call.arguments}', message: 'not implemented');
          }
          return;
        default:
          throw PlatformException(code: 'notimpl', message: 'not implemented');
      }
    });
  }
  /// Load url of media into player, player will auto play if load media succesfully
  /// @return Operation success or not
  Future<void> loadUrl(String url) async {
    assert(url != null);
    return await _methodChannel.invokeMethod('loadUrl', url);
  }
  /// Set player to play when ready
  /// @return Operation success or not
  Future<void> play() async {
    return await _methodChannel.invokeMethod('play');
  }
  /// Pause player
  /// @return Operation success or not
  Future<void> pause() async {
    return await _methodChannel.invokeMethod('pause');
  }
  /// Restart media that player is playing
  /// @return Operation success or not
  Future<void> reStart() async {
    return await _methodChannel.invokeMethod('reStart');
  }
  /// Set current position of player at desired position
  /// @param position Posision that want to set (in milliseconds)
  /// @return Operation success or not
  Future<void> seekTo(int position) async {
    return await _methodChannel.invokeMethod('seekTo', position);
  }
  /// Get current position of the player
  /// @return Current postion (in milliseconds)
  Future<int> getPosition() async {
    var position = await _methodChannel.invokeMethod('getPosition');
    return position;
  }
  /// Get duration of media the player is playing
  /// @return The duration of media (in milliseconds)
  Future<int> getDuration() async {
    return await _methodChannel.invokeMethod('getDuration');
  }
  /// Enable/disable the default controller in player
  /// @param isEnable : true for enable, false for disable
  /// @return Operation success or not
  Future<bool> useNativeController(bool isEnable) async {
    if(await _methodChannel.invokeMethod('useNativeController', isEnable)){
      ///Change the variable that holds enable/disable
      ///state of default controller
      isNativeControllerEnabled=!isNativeControllerEnabled;
      return true;
    }else{
      return false;
    }
  }
  /// Check if player is playing
  /// @return true if player is playing, otherwise
  Future<bool> isPlaying() async {
    return await _methodChannel.invokeMethod('isPlaying');
  }

  /// Set volume for player
  /// @param volume Volume value: 0->mute, 1->maximum
  /// @return Operation success or not
  Future<bool> setVolume(double volume) async{
    return await _methodChannel.invokeMethod('setVolume',volume);
  }

}
