import WebKit
import UIKit
import Foundation
import AVFoundation
import AVKit
import GPUImage

public class VideoPlayerPlatformView: NSObject, FlutterPlatformView,WKNavigationDelegate {
  let viewId: Int64
  let channel:FlutterMethodChannel
  let messenger:FlutterBinaryMessenger
  let videoPlayer:TestVideoPlayer
  let frame : CGRect
//////////Camera test//////////
  var camera_1 : GPUImageVideoCamera!
  var cameraView_1:GPUImageView!
  ///////////////////////////
  init(channel:FlutterMethodChannel,
       frame: CGRect,
       viewId: Int64,
       messenger:FlutterBinaryMessenger,
       args: Any?) {
    self.viewId = viewId
    self.channel=FlutterMethodChannel(name:"video_player_plugin_"+String(viewId),binaryMessenger:messenger)
    self.messenger=messenger
    self.videoPlayer=TestVideoPlayer(frame:frame)
    self.frame = frame
    super.init()
    self.setupCamera()
    self.setCaller()
  }
  public func setCaller(){
    self.channel.setMethodCallHandler({ (call: FlutterMethodCall, result: FlutterResult) -> Void in
      switch call.method {
        case "loadUrl":
         let args = call.arguments as? String ?? ""
         let url = args
         self.loadUrl(url:url)
         result("done")
      case "play":
        self.videoPlayer.play()
        result("done")
      case "pause":
        self.videoPlayer.pause()
        result("Done")
      case "getPosition":
        result(self.videoPlayer.getPosition())
      case "getDuration":
        result(self.videoPlayer.getDurationOfCurrentVideo())
      case "seekTo":
        let args = call.arguments as? NSNumber ?? 0
        let position = Int64(args)
        if (position != nil){
          self.videoPlayer.seekTo(position:position)
        }
        result(args)
      case "isPlaying":
        result(self.videoPlayer.isPlaying())
      case "useNativeController":
        let args = call.arguments as? NSNumber ?? true as NSNumber
        let isEnable = args.boolValue
        self.videoPlayer.useNativeControl(isEnable:isEnable)
        result(true)
      case "setVolume":
        let args = call.arguments as? NSNumber ?? NSNumber(value:0.0)
        let volume = args.floatValue
        self.videoPlayer.setVolume(volume:volume)
        result(true)
       default:
          result(FlutterMethodNotImplemented)
      }
    })

  }

    private func setupCamera(){
//    do{
//      camera = try Camera(sessionPreset: AVCaptureSession.Preset.high,cameraDevice: AVCaptureDevice.default(.builtInWideAngleCamera,for: AVMediaType.video,position: .front))
//      cameraView = RenderView(frame:self.view.bounds)
//      self.view.addSubview(cameraView)
//      self.view.bringSubviewToFront(cameraView)
//
//      let filter = BilateralBlur()
//
//      camera --> filter --> cameraView
//      camera.startCapture()
//
//    }catch{
//      debugPrint(error)
//    }
    let start = DispatchTime.now()
    camera_1 = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: AVCaptureDevice.Position.front)
    camera_1.outputImageOrientation = UIInterfaceOrientation.portrait;
    let filter = GPUImageBilateralFilter()
    cameraView_1 = GPUImageView(frame: self.frame)
    camera_1.addTarget(filter)
    filter.addTarget(cameraView_1)
    camera_1.startCapture()
  }

  public func view() -> UIView {
    // return videoPlayer.playerViewController.view
    return self.cameraView_1
  }

  public func loadUrl(url:String){
    videoPlayer.loadUrl(url:url)
  }
}

class TestVideoPlayer{
  let player:AVQueuePlayer
  let playerViewController:AVPlayerViewController

  init(frame:CGRect) {
    self.player=AVQueuePlayer.init()
    self.playerViewController=AVPlayerViewController()
    playerViewController.player=player
  }

  public func loadUrl(url:String){
    self.player.removeAllItems()

    let url:URL?=URL.init(string:url)
    if url != nil {
      let playerItem=AVPlayerItem.init(url:url!)
      self.player.insert(playerItem,after:nil)
      self.player.play()
    }
  }
  public func play(){
    self.player.play()
  }
  public func pause(){
    self.player.pause()
  }
  public func seekTo(position:Int64){
    self.player.seek(to:CMTimeMakeWithSeconds(Float64(position)/1000,preferredTimescale:1000000))
  }
  public func useNativeControl(isEnable:Bool){
    self.playerViewController.showsPlaybackControls=isEnable
  }
  public func getPosition()->NSNumber{
    return NSNumber(value:Int(CMTimeGetSeconds(self.player.currentTime())*1000))
  }
  public func getDurationOfCurrentVideo()->NSNumber{
    let arrayItems = self.player.items()
    let currentItem = arrayItems[0]
    return NSNumber(value:Int(CMTimeGetSeconds(currentItem.duration)*1000))
  }
  public func isPlaying()->NSNumber{
    if (self.player.rate != 0 && self.player.error==nil){
      return true as NSNumber
    }
    else{
      return false as NSNumber
    }
  }
  public func setVolume(volume:Float){
    self.player.volume=volume
  }
}


class VideoPlayer{
  var playerContainerView: UIView!
  //Reference for the player view
  var playerView: PlayerView!
  var playerViewController:AVPlayerViewController!
  var frame:CGRect

  init(frame:CGRect) {
    self.frame=frame
    setUpPlayerContainerView()
    setUpPlayerView()
    playerViewController=AVPlayerViewController()
    playerViewController.player=playerView.player
    playerViewController.showsPlaybackControls=true
    playerViewController.view.frame=playerView.frame
    playerView.addSubview(playerViewController.view)
  }
  // Set  up constraints for the player container view.
  private func setUpPlayerContainerView() {
    playerContainerView = UIView()
    playerContainerView.backgroundColor = .black
  }

  private func setUpPlayerView() {
    playerView = PlayerView()
    playerView.frame=self.frame
    playerContainerView.addSubview(playerView)
  }

  func playVideo(url:String) {
      guard let videoURL = URL(string: url) else { return }
      playerView.setUrl(with: videoURL)
  }
  func pauseVideo(){
    playerView.pause()
  }
  func playVideo(){
    playerView.play()
  }
  func getPosition()->NSNumber{
    return playerView.getCurTime()
  }
  func getDurationOfCurrentVideo()->NSNumber{
    return playerView.getDurationOfCurItem();
  }
  func seekTo(position:NSNumber){
    playerView.seekTo(position:position)
  }

}

class PlayerView:UIView{
  override class var layerClass:AnyClass{
    return AVPlayerLayer.self
  }

  var player:AVPlayer?{
    get{
      return playerLayer.player
    }
    set{
      playerLayer.player=newValue
    }
  }

  var playerLayer:AVPlayerLayer{
    return layer as! AVPlayerLayer
  }

  private var playerItemContext = 0
  private var currentDurationOfCurItem:NSNumber = 0
  //Keep the reference and use it to observer the loading status
  private var playerItem: AVPlayerItem?

  private func setUpAsset(with url: URL, completion: ((_ asset: AVAsset) -> Void)?) {
    let asset = AVAsset(url: url)
    asset.loadValuesAsynchronously(forKeys: ["playable"]) {
      var error: NSError? = nil
      let status = asset.statusOfValue(forKey: "playable", error: &error)
      switch status {
      case .loaded:
        completion?(asset)
      case .failed:
        print(".failed")
      case .cancelled:
        print(".cancelled")
      default:
              print("default")
          }
      }
  }


  private func setUpPlayerItem(with asset: AVAsset) {
    playerItem = AVPlayerItem(asset: asset)
    playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &playerItemContext)

    DispatchQueue.main.async { [weak self] in
      self?.player = AVPlayer(playerItem: self?.playerItem!)
    }
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    // Only handle observations for the playerItemContext
    guard context == &playerItemContext else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
      return
    }

    if keyPath == #keyPath(AVPlayerItem.status) {
      let status: AVPlayerItem.Status
      if let statusNumber = change?[.newKey] as? NSNumber {
        status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
      } else {
        status = .unknown
      }
      // Switch over status value
      switch status {
      case .readyToPlay:
        print(".readyToPlay")
        player?.play()
        let duration = (playerItem?.asset.duration.seconds ?? 0)*1000
        currentDurationOfCurItem=NSNumber(value:Int(duration))
      case .failed:
        print(".failed")
      case .unknown:
        print(".unknown")
      @unknown default:
        print("@unknown default")
          }
      }
  }

  func setUrl(with url: URL) {
    setUpAsset(with: url) { [weak self] (asset: AVAsset) in
      self?.setUpPlayerItem(with: asset)
    }
  }

  func pause(){
    player!.pause()
  }
  func play(){
    player!.play()
  }
  func getCurTime()->NSNumber{
    return NSNumber(value:Int(CMTimeGetSeconds(player!.currentTime())*1000))
  }
  func getDurationOfCurItem()->NSNumber{
    return currentDurationOfCurItem
  }
  func seekTo(position:NSNumber){
    player!.seek(to:CMTimeMakeWithSeconds(Double(Int(position)/1000),preferredTimescale:1000000))
  }
  deinit {
      playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
      print("deinit of PlayerView")
  }
}

