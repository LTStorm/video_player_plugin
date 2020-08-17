package com.example.video_player_plugin

import android.content.Context
import android.net.Uri
import com.google.android.exoplayer2.C
import com.google.android.exoplayer2.Player
import com.google.android.exoplayer2.SimpleExoPlayer
import com.google.android.exoplayer2.extractor.DefaultExtractorsFactory
import com.google.android.exoplayer2.source.ExtractorMediaSource
import com.google.android.exoplayer2.source.MediaSource
import com.google.android.exoplayer2.source.dash.DashMediaSource
import com.google.android.exoplayer2.source.dash.DefaultDashChunkSource
import com.google.android.exoplayer2.source.hls.HlsMediaSource
import com.google.android.exoplayer2.source.smoothstreaming.DefaultSsChunkSource
import com.google.android.exoplayer2.source.smoothstreaming.SsMediaSource
import com.google.android.exoplayer2.ui.PlayerView
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory
import com.google.android.exoplayer2.util.Util
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.platform.PlatformView

/**
 * Class that has been registered in the plugin registry and handle all the call that been made from
 * MethodChannel
 */
class VideoPlayer(context: Context,registrar: PluginRegistry.Registrar,id:Int?):PlatformView,
        MethodChannel.MethodCallHandler {
    private var methodChannel:MethodChannel = MethodChannel(registrar.messenger(),
            "video_player_plugin_$id")

    /**
     * Context passed from client in futter app
     */
    private var context:Context = context

    /**
     * The instance that handle the ExoPlayer operation
     */
    private var exoPlayer:ExoPlayerEmbedded

    /**
     * Set this object to handle call from MethodChannel and init exoplayer
     */
    init {
        methodChannel.setMethodCallHandler(this)
        exoPlayer=ExoPlayerEmbedded(context,registrar,methodChannel)
    }

    /**
     * Return the player view for client in Flutter to display in AndroidView
     */
    override fun getView(): PlayerView? {
        return exoPlayer.getPlayerView()
    }

    /**
     * The default dispose method of PlatformView
     * Currently not being used
     */
    override fun dispose() {
    }

    /**
     * Handle the call passed from method channel
     * @param call messengers passed from client in Flutter through MethodChannel
     * @param result Result which will be returned to client
     */
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            /**
             * Load media from url
             */
            "loadUrl" -> {
                val url = call.arguments.toString()
                /**
                 * Parse the url sent from channel and set media source for player
                 */
                exoPlayer.setMediaSource(Uri.parse(url))
            }
            /**
             * Load media asset file
             */
            "loadLocal"->{
                val url=call.arguments.toString()
                /**
                 * Parse the url of video file to URI and set this video for player to play
                 */
                result.success(exoPlayer.setMediaSource(Uri.parse("file:/android_asset/" +
                        "butterfly.mp4")))
            }
            /**
             * Return if the player is playing or not to client in Flutter
             */
            "isPlaying"->{
                result.success(exoPlayer.isPlaying())
            }
            /**
             * Set the player to play when ready
             */
            "play"->{
                if(exoPlayer.play()){
                    result.success(true)
                }else{
                    result.success(false)
                }

            }
            /**
             * Set the player to pause when ready
             * */
            "pause"->{
                if(exoPlayer.pause()){
                    result.success(true)
                }else{
                    result.success(false)
                }
            }
            /**
             * Set current position of player to the beginning a
             */
            "reStart"->{
                if(exoPlayer.reStart()){
                    result.success(true)
                }else{
                    result.success(false)
                }
            }
            /**
             * Set current position of player to desired position
             */
            "seekTo"->{
                val duration=call.arguments.toString().toLong()
                if(exoPlayer.seekTo(duration)){
                    result.success(true)
                }else{
                    result.success(false)
                }
            }
            /**
             * Get current position of player
             */
            "getPosition"->{
                result.success(exoPlayer.getPosition())
            }
            /**
             * Get duration of media the player is currently holds
             */
            "getDuration"->{
                result.success(exoPlayer.getDuration())
            }
            /**
             * Enable/disable the default controller in ExoPlayer
             */
            "useNativeController"->{
                val isEnable=call.arguments.toString().toBoolean()
                /**
                 * isEnable: true -> turn of dafult controller, false -> turn off default controller
                 */
                result.success(exoPlayer.enableController(isEnable))
            }
            /**
             * Set the volume of player and
             * volume: 0 -> mute, 1.0 -> maximum
             */
            "setVolume"->{
                val volume=call.arguments.toString().toFloat()
                result.success(exoPlayer.setVolume(volume))
            }
            /**
             * Call that not been recognized
             */
            else -> result.notImplemented()
        }
    }

}

/**
 * Class that handle the ExoPlayer operation
 */
class ExoPlayerEmbedded(private val context: Context,private val registrar: PluginRegistry.Registrar,
                        private val methodChannel: MethodChannel):Player.EventListener{
    /**
     * The instance of SimpleExoPlayer
     */
    private lateinit var player:SimpleExoPlayer

    /**
     * The view that holds the ExoPlayer
     */
    private lateinit var playerView:PlayerView

    init {
        /**
         * Initialize player when object is being created
         */
        initializePlayer(registrar)
    }

    fun getPlayerView():PlayerView{
        return playerView
    }
    /**
    *Initialize the player, player view
    *@param registrar Registrar receive from the VideoPlayer class
    * */
    private fun initializePlayer(registrar: PluginRegistry.Registrar) {
        /**
        *Build the player from SimpleExoPlayer, context is passed from VideoPlayer, and set context
        * for player view that will ve returned to Flutter Android View
        *  */
        player = SimpleExoPlayer.Builder(this.context).build()
        playerView= PlayerView(registrar.context())
        /**
        * Add listener for player to handle the playback state changing
        * */
        player.addListener(this)
        /**
        * Set player for player view and disable the default controller of ExoPlayer
        * */
        playerView.player = player;
        playerView.useController=false
    }

    /**
    *Override the default function of Player.EventListener
    *Return state to Flutter through MethodChannel when playback state change
    * @param playWhenReady Whether playback will proceed when ready.
    * @param playbackState The new playback state.
    * */
    @Override
    override fun onPlayerStateChanged(playWhenReady: Boolean, playbackState: Int) {
        /**
        * Notify to Flutter handle the playback state change
        * */
        when (playbackState) {
            Player.STATE_ENDED -> {
                methodChannel.invokeMethod("stateChange","ended")
            }
            Player.STATE_IDLE -> {
                methodChannel.invokeMethod("stateChange","idle")
            }
            Player.STATE_BUFFERING -> {
                methodChannel.invokeMethod("stateChange","buffering")
            }
            Player.STATE_READY -> {
                methodChannel.invokeMethod("stateChange","ready")
            }
        }
    }

    /**
    * Set media source for the player
    * @param uri The URI of media
    * */
    fun setMediaSource(uri:Uri){
        /**
        * Build media source from URI of media
        * */
        val mediaSource = buildMediaSource(uri)
        /**
        * Check whether media source already built or not
        * */
        if (mediaSource != null) {
            /**
            * Prepare media source already built for player
            * */
            player.prepare(mediaSource, false, false)
        }
        /**
        * Reset current position of player to the beginning
        * */
        player.seekTo(0)
        /**
        * Start player when player is ready
        * */
        player.playWhenReady=true
    }


    /**
    * Build corresponding media source from URI of media
    * @param uri The URI of media
    * @return The MediaSource built from URI of media
    * */
    private fun buildMediaSource(uri: Uri): MediaSource? {
        /**
        * Create factory for DataSource
        * */
        val mediaSourceFactory=DefaultDataSourceFactory(context,"video_player_plugin")
        /**
        * Infer the type of media by the Util library of Exoplayer
        * */
        val type = Util.inferContentType(uri.lastPathSegment)
        /**
        * Built correct media source for each type of media
        * */
        when(type){
            /**
             * DASH streaming protocol
             */
            C.TYPE_DASH->{
                return DashMediaSource.Factory(
                        DefaultDashChunkSource.Factory(mediaSourceFactory),
                        DefaultDataSourceFactory(context, null, mediaSourceFactory))
                        .createMediaSource(uri)
            }
            /**
             * HLS streaming protocol
             */
            C.TYPE_HLS->{
                return HlsMediaSource.Factory(mediaSourceFactory).createMediaSource(uri)
            }
            /**
             * Smooth streaming protocol
             */
            C.TYPE_SS->{
                return SsMediaSource.Factory(
                        DefaultSsChunkSource.Factory(mediaSourceFactory),
                        DefaultDataSourceFactory(context,null,mediaSourceFactory))
                        .createMediaSource(uri)
            }
            /**
             * Progressive and other type
             */
            C.TYPE_OTHER->{
                return ExtractorMediaSource.Factory(mediaSourceFactory).setExtractorsFactory(DefaultExtractorsFactory())
                        .createMediaSource(uri)
            }
            /**
             * Type that ExoPlayer not support
             */
            else->
            {
                throw IllegalStateException("Unsupported type: $type");
            }
        }
    }

    /**
    * Check whether the player is plaing or not
    * @return player is playing or not
    * */
    fun isPlaying():Boolean{
        return player.isPlaying;
    }
    /**
    * Set the player to play when ready
    * @return Whether the player is set to play when ready successfully or not
    * */
    fun play():Boolean{
        if (!player.isPlaying){
            player.playWhenReady=true
            return true
        }
        return false
    }
    /**
    * Set the player to pause when ready
    * @return Whether the player is set to pause when ready successfully or not
    * */
    fun pause():Boolean{
        if(player.isPlaying){
            player.playWhenReady=false;
            return true
        }
        return false
    }
    /**
    * Set the current position of player to the beginning of media
    * @return Whether the player restart successfully
    * */
    fun reStart():Boolean{
        player.seekTo(0) //Position is set in millisecond
        return true
    }
    /**
    *Seeks to a position specified in milliseconds of player
    * @param position (in milliseconds) want to seeks
    * @return Seeking success or position is out of range of media
    * */
    fun seekTo(position:Long):Boolean{
        /*
        *
        * */
        if(position<player.duration){
            player.seekTo(position)
            return true
        }
        return false
    }

    /**
     * Get current position of player
     * @return Current position of player (in milliseconds)
     */
    fun getPosition():Long{
        return player.currentPosition
    }
    /**
     * Get duration of current media the player hold
     * @return Duration of media (in milliseconds)
     */
    fun getDuration():Long{
        return player.duration
    }

    /**
     * Sets the audio volume, with 0 being silence and 1 being unity gain.
     * @param volume volume value want to set
     */
    fun setVolume(volume:Float):Boolean{
        player.volume=volume
        return true
    }

    /**
     * Set the default controller of ExoPlayer visible or not
     * @param isEnable 'true' for turn of, 'false' for turn off
     * @return Whether the visibility of controller is changed successfully
     */
    fun enableController(isEnable:Boolean):Boolean{
        if (isEnable){
            /**
             *Change the visibility of controller from off to on
             * And show controller on screen
             */
            playerView.useController=isEnable
            playerView.showController()
        }else{

            /**
             * Change the visibility of controller from on to off
             */
            playerView.useController=isEnable
        }
        return true;
    }
}

