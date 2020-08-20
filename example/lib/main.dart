import 'package:flutter/material.dart';
import 'package:video_player_plugin/video_player_plugin.dart';
import 'dart:io' show Platform;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  VideoPlayerController videoPlayerController;
  double _value = 100.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String url =
        "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8";

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: <Widget>[
            Container(
              ///Widget VideoPlayer that display the video
              child: VideoPlayer(
                videoPlayerCreated: (videoPlayerController) {
                  this.videoPlayerController = videoPlayerController;
                  this.videoPlayerController.loadUrl(url);
                },

                ///Cllback function for when video end
                videoPlayerEnded: (videoPlayerController) {
                  ///When video end load this video
                  videoPlayerController.loadUrl(
                      'https://www.radiantmediaplayer.com/media/big-buck-bunny-360p.mp4');
                },
              ),
              height: 200,
            ),

            ///Following is buttons that show some function of the widget
            Row(
              children: <Widget>[
                ///Button to play video
                IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: () {
                    videoPlayerController.play();
                  },
                ),

                ///Button to pause video
                IconButton(
                  icon: Icon(Icons.pause),
                  onPressed: () {
                    videoPlayerController.pause();
                  },
                ),

                ///Button that view make video skip to 0m:50s
                IconButton(
                  icon: Icon(Icons.skip_next),
                  onPressed: () {
                    videoPlayerController.seekTo(50000);
                  },
                ),

                ///Button that view print the current position of video
                ///to console (in milliseconds)
                RaisedButton(
                    child: Text('Get position'),
                    onPressed: () {
                      videoPlayerController
                          .getPosition()
                          .then((value) => print(value));
                    }),

                ///Button that view print duration of video
                ///to console (in milliseconds)
                RaisedButton(
                  child: Text('Get duration'),
                  onPressed: () {
                    videoPlayerController
                        .getDuration()
                        .then((value) => print(value));
                  },
                ),
              ],
            ),
            Row(
              children: <Widget>[
                ///Button that will enable or disable the default controller
                ///of player
                RaisedButton(
                  child: Text('Use Native Control'),
                  onPressed: () {
                    videoPlayerController.useNativeController(
                        !videoPlayerController.isNativeControllerEnabled);
                  },
                ),

                ///Button that will load the local video place in assets of the plugin
                RaisedButton(
                  child: Text('Load Local Video'),
                  onPressed: () {
                    url = 'file:/android_asset/butterfly.mp4';
                    videoPlayerController.loadUrl(url);
                  },
                )
              ],
            ),
            Row(
              children: <Widget>[
                ///Button that will load the video use DASH streaming protocol
                RaisedButton(
                  child: Text("DASH"),
                  onPressed: Platform.isIOS
                      ? null
                      : () {
                          setState(() {
                            url =
                                "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/"
                                "mpds/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.mpd";
                            videoPlayerController.loadUrl(url);
                          });
                        },
                ),

                ///Button that will load the video use HLS streaming protocol
                RaisedButton(
                  child: Text("HLS"),
                  onPressed: () {
                    setState(() {
                      url =
                          "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/"
                          "m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8";
                      videoPlayerController.loadUrl(url);
                    });
                  },
                ),

                ///Button that will load the video use Smooth Streaming protocol
                RaisedButton(
                  child: Text("Smooth"),
                  onPressed: Platform.isIOS
                      ? null
                      : () {
                          setState(() {
                            url =
                                "https://test.playready.microsoft.com/smoothstreaming/"
                                "SSWSS720H264/SuperSpeedway_720.ism";
                            videoPlayerController.loadUrl(url);
                          });
                        },
                ),
                RaisedButton(
                  ///Button that will load video use Progressing Streaming protocol
                  child: Text("Progressive"),
                  onPressed: Platform.isIOS
                      ? null
                      : () {
                          setState(() {
                            url =
                                "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/"
                                "MI201109210084_mpeg-4_hd_high_1080p25_10mbits.mp4";
                            videoPlayerController.loadUrl(url);
                          });
                        },
                ),
              ],
            ),
            Slider(
              min: 0,
              max: 100,
              value: _value,
              label: "Volume",
              divisions: 10,
              activeColor: Colors.blue,
              inactiveColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  _value = value;
                  this.videoPlayerController.setVolume(_value / 100);
                });
                print(_value);
              },
            )
          ],
        ),
      ),
    );
  }
}
