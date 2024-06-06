package com.videoplayer.native_in_flutter

import android.annotation.SuppressLint
import android.app.Activity
import android.app.AlertDialog
import android.content.Context
import android.content.DialogInterface
import android.content.Intent
import android.content.pm.ActivityInfo
import android.media.AudioManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.GestureDetector
import android.view.MotionEvent
import android.view.View
import android.view.Window
import android.view.WindowManager
import android.widget.ImageView
import android.widget.ProgressBar
import android.widget.TextView
import androidx.activity.OnBackPressedCallback
import androidx.appcompat.app.AppCompatActivity
import com.google.android.exoplayer2.MediaItem
import com.google.android.exoplayer2.PlaybackParameters
import com.google.android.exoplayer2.Player
import com.google.android.exoplayer2.SimpleExoPlayer
import com.google.android.exoplayer2.ext.ima.ImaAdsLoader
import com.google.android.exoplayer2.source.DefaultMediaSourceFactory
import com.google.android.exoplayer2.source.MediaSourceFactory
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector
import com.google.android.exoplayer2.ui.PlayerView
import com.google.android.exoplayer2.ui.TrackSelectionDialogBuilder
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory
import com.google.android.exoplayer2.util.Assertions
import com.google.android.exoplayer2.util.MimeTypes
import android.provider.Settings
import android.widget.Button
import android.widget.LinearLayout
import android.content.res.Configuration
import android.view.Surface
import android.view.ViewGroup

class ViewPlayerActivity : AppCompatActivity() {

    private var doubleTapListener: GestureDetector.SimpleOnGestureListener? = null
    private var gestureDetector: GestureDetector? = null
    private var adsLoader: ImaAdsLoader? = null
    private lateinit var audioManager: AudioManager
    private var maxVolume: Int = 0
    var speed = arrayOf("0.25x", "0.5x", "Normal", "1.5x", "2x")
    private lateinit var handler: Handler
    private val checkInterval: Long = 500 // Interval to check playback position
    private lateinit var playerView: PlayerView

    @SuppressLint("MissingInflatedId", "ClickableViewAccessibility", "WrongViewCast")
    override fun onCreate(savedInstanceState: Bundle?) {
        requestWindowFeature(Window.FEATURE_NO_TITLE)
        super.onCreate(savedInstanceState)
//        enableEdgeToEdge()

        window.setFlags(
            WindowManager.LayoutParams.FLAG_FULLSCREEN,
            WindowManager.LayoutParams.FLAG_FULLSCREEN
        )
        window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)

        //hide notch and fill full screen
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            window.setFlags(
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
            )
            window.attributes.layoutInDisplayCutoutMode =
                WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
        }

        setContentView(R.layout.activity_view_player)

        val playerView = findViewById<PlayerView>(R.id.player)
        val progressBar = findViewById<ProgressBar>(R.id.progress_bar)
        val titleTextView = findViewById<TextView>(R.id.titleMoviePlayer)
        val rewBtn = findViewById<ImageView>(R.id.rew)
        val fwdBtn = findViewById<ImageView>(R.id.fwd)
        val backBtn = findViewById<ImageView>(R.id.backExo)
        val speedBtn = findViewById<ImageView>(R.id.exo_playback_speed)
        val speedTxt = findViewById<TextView>(R.id.speed)
        val exoQuality = findViewById<ImageView>(R.id.exo_quality)
        val brightnessLayout = findViewById<LinearLayout>(R.id.brightness_layout)
        val volumeLayout = findViewById<LinearLayout>(R.id.volume_layout)
        val brightnessPercentage = findViewById<TextView>(R.id.brightness_percentage)
        val volumePercentage = findViewById<TextView>(R.id.volume_percentage)
        val skipIntroButton = findViewById<Button>(R.id.skip_intro_button)

        brightnessLayout.visibility = View.GONE
        volumeLayout.visibility = View.GONE

        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE)

        adsLoader = ImaAdsLoader.Builder(this).build()

        val dataSourceFactory = DefaultDataSourceFactory(this, "exoplayer-ima")
        val mediaSourceFactory: MediaSourceFactory = DefaultMediaSourceFactory(dataSourceFactory)
            .setAdsLoaderProvider { unusedAdTagUri: MediaItem.AdsConfiguration? -> adsLoader }
            .setAdViewProvider(playerView)

        val trackSelector = DefaultTrackSelector(this)
        val simpleExoPlayer = SimpleExoPlayer.Builder(this)
            .setMediaSourceFactory(mediaSourceFactory)
            .setTrackSelector(trackSelector)
            .setSeekBackIncrementMs(5000)
            .setSeekForwardIncrementMs(5000)
            .build()

        playerView.player = simpleExoPlayer
        playerView.keepScreenOn = true
        simpleExoPlayer.addListener(object: Player.Listener{
            override fun onPlayerStateChanged(playWhenReady: Boolean, playbackState: Int){
                if(playbackState == Player.STATE_BUFFERING){
                    progressBar.visibility = View.VISIBLE
                }else if(playbackState == Player.STATE_READY){
                    progressBar.visibility = View.GONE
                }
            }
        })
        val videoUrl: String? = intent.getStringExtra("videoUrl")
        val videoText: String? = intent.getStringExtra("videoText")
        val videoId: String? = intent.getStringExtra("videoId")
        val videoSource = Uri.parse(videoUrl)
//        val adTagUri3 = Uri.parse("http://pubads.g.doubleclick.net/gampad/ads?slotname=/124319096/external/ad_rule_samples&sz=640x480&ciu_szs=300x250&cust_params=sample_ar%3Dpremidpostpod%26deployment%3Dgmf-js&url=&unviewed_position_start=1&output=xml_vast3&impl=s&env=vp&gdfp_req=1&ad_rule=0&useragent=Mozilla/5.0+(Windows+NT+10.0%3B+Win64%3B+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/124.0.0.0+Safari/537.36,gzip(gfe)&vad_type=linear&vpos=preroll&pod=1&ppos=1&lip=true&min_ad_duration=0&max_ad_duration=30000&vrid=6376&cmsid=496&video_doc_id=short_onecue&kfa=0&tfcd=0")
        val adTagUri3 = Uri.parse("https://indimuse.in/api/v1/vmap/${videoId}")
        val mediaItem = MediaItem.Builder()
            .setUri(videoSource)
            .setMimeType(MimeTypes.APPLICATION_M3U8)
            .setAdTagUri(adTagUri3)
            .build()

        adsLoader!!.setPlayer(simpleExoPlayer)

        simpleExoPlayer.setMediaItem(mediaItem)
        simpleExoPlayer.prepare()
        simpleExoPlayer.play()

        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)

        // Initialize gesture detector
        doubleTapListener = object : GestureDetector.SimpleOnGestureListener() {
            override fun onDoubleTap(e: MotionEvent): Boolean {
                // Implement skipping logic here
                val screenWidth = resources.displayMetrics.widthPixels
                val currentPosition = simpleExoPlayer.currentPosition
                val totalDuration = simpleExoPlayer.duration

                val seekDuration = screenWidth / 4 // Adjust as needed
                val targetPosition = if ((e.x ?: 0f) < screenWidth / 2) {
                    // Skip backward
                    currentPosition - 10000
                } else {
                    // Skip forward
                    currentPosition + 10000
                }
                simpleExoPlayer.seekTo(targetPosition.coerceIn(0, totalDuration))
                return true
            }
            override fun onScroll(
                e1: MotionEvent?,
                e2: MotionEvent,
                distanceX: Float,
                distanceY: Float
            ): Boolean {
                val x1 = e1?.x ?: 0f
                val y1 = e1?.y ?: 0f
                val x2 = e2?.x ?: 0f
                val y2 = e2?.y ?: 0f
                handleScroll(x1, y1, x2, y2)
                return true
            }
        }
        gestureDetector = GestureDetector(this,
            doubleTapListener as GestureDetector.SimpleOnGestureListener
        )
        playerView.setOnTouchListener { _, event -> gestureDetector?.onTouchEvent(event) ?: false }

        titleTextView.text = videoText;

        // Set up button click listeners
        rewBtn.setOnClickListener {
            val num: Long = simpleExoPlayer.getCurrentPosition() - 10000
            if (num < 0) {
                simpleExoPlayer.seekTo(0)
            } else {
                simpleExoPlayer.seekTo(simpleExoPlayer.getCurrentPosition() - 10000)
            }
        }

        fwdBtn.setOnClickListener {
            simpleExoPlayer.seekTo(simpleExoPlayer.getCurrentPosition() + 10000)
        }

        backBtn.setOnClickListener {
            handleBackPress(simpleExoPlayer)
        }

        speedBtn.setOnClickListener {
            val builder = AlertDialog.Builder(playerView.context)
            builder.setTitle("Set Speed")
            builder.setItems(speed) { _, which ->
                val param = when (which) {
                    0 -> PlaybackParameters(0.25f)
                    1 -> PlaybackParameters(0.5f)
                    2 -> PlaybackParameters(1f)
                    3 -> PlaybackParameters(1.5f)
                    4 -> PlaybackParameters(2f)
                    else -> PlaybackParameters(1f)
                }
                speedTxt.visibility = if (which == 2) View.GONE else View.VISIBLE
                speedTxt.text = speed[which]
                simpleExoPlayer.setPlaybackParameters(param)
            }
            builder.show()
        }

        exoQuality.setOnClickListener {
            val mappedTrackInfo = Assertions.checkNotNull(trackSelector.currentMappedTrackInfo)
            val trackSelectionDialogBuilder = TrackSelectionDialogBuilder(
                this, "Select Quality", trackSelector, 0
            )
            trackSelectionDialogBuilder.build().show()
        }

        skipIntroButton.setOnClickListener {
            // Set the time in milliseconds to skip to (e.g., 60 seconds)
            val skipToPositionMs = 10 * 1000L
            simpleExoPlayer.seekTo(skipToPositionMs)

            skipIntroButton.visibility = Button.GONE
        }

        handler = Handler(Looper.getMainLooper())
        handler.post(object : Runnable {
            override fun run() {
                if (simpleExoPlayer.isPlayingAd) {
                    skipIntroButton.visibility = Button.GONE
                } else {
                    if (simpleExoPlayer.currentPosition >= 10 * 1000L) {
                        skipIntroButton.visibility = Button.GONE
                    } else {
                        skipIntroButton.visibility = Button.VISIBLE
                    }
                }
                handler.postDelayed(this, checkInterval)
            }
        })

        // Set orientation when the video starts
        simpleExoPlayer.addListener(object : Player.Listener {
            override fun onIsPlayingChanged(isPlaying: Boolean) {
                if (isPlaying) {
                    requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE
                } else {
                    requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
                }
            }
        })

        onBackPressedDispatcher.addCallback(this, object: OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                handleBackPress(simpleExoPlayer)
            }
        })

    }

    @SuppressLint("SetTextI18n")
    private fun handleScroll(x1: Float, y1: Float, x2: Float, y2: Float) {
        val screenHeight = resources.displayMetrics.heightPixels
        val screenWidth = resources.displayMetrics.widthPixels
        val diffY = y1 - y2
        val sensitivityFactor = 0.001f // Adjust this factor to control sensitivity

        if (x1 < screenWidth / 2) {
            // Adjust brightness for the activity
            val layoutParams = window.attributes
            val newBrightness = (layoutParams.screenBrightness + diffY * sensitivityFactor).coerceIn(0.01f, 1.0f)
            layoutParams.screenBrightness = newBrightness
            window.attributes = layoutParams

            // Show brightness icon and percentage
            val brightnessPercent = (newBrightness * 100).toInt()
            findViewById<LinearLayout>(R.id.brightness_layout).visibility = View.VISIBLE
            findViewById<LinearLayout>(R.id.volume_layout).visibility = View.GONE
            findViewById<TextView>(R.id.brightness_percentage).text = "$brightnessPercent%"
        } else {
            // Adjust volume
            val currentVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
            val volumeChange = (diffY * sensitivityFactor * maxVolume).toInt()
            val newVolume = (currentVolume + volumeChange).coerceIn(0, maxVolume)
            audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, newVolume, 0)

            // Show volume icon and percentage
            val volumePercent = (newVolume * 100 / maxVolume).toInt()
            findViewById<LinearLayout>(R.id.brightness_layout).visibility = View.GONE
            findViewById<LinearLayout>(R.id.volume_layout).visibility = View.VISIBLE
            findViewById<TextView>(R.id.volume_percentage).text = "$volumePercent%"
        }
    }

    private fun handleBackPress(simpleExoPlayer: SimpleExoPlayer) {
        println("Back button pressed")
        simpleExoPlayer.stop()
        simpleExoPlayer.release()
        val returnIntent = Intent()
        returnIntent.putExtra("state_data", "If anything need to return")
        setResult(Activity.RESULT_OK, returnIntent)
        finish()
    }

    // orientation handel
    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        if (newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE) {
            val windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
            val rotation = windowManager.defaultDisplay.rotation

            when (rotation) {
                Surface.ROTATION_0 -> {
                    // Handle standard landscape (device is in its natural orientation)
                    updateLayoutForStandardLandscape()
                }
                Surface.ROTATION_180 -> {
                    // Handle reverse landscape
                    updateLayoutForReverseLandscape()
                }
            }
        }
    }

    private fun updateLayoutForStandardLandscape() {
        // Adjust your player layout for standard landscape orientation
        val params = playerView.layoutParams
        params.width = ViewGroup.LayoutParams.MATCH_PARENT
        params.height = ViewGroup.LayoutParams.MATCH_PARENT
        playerView.layoutParams = params
    }

    private fun updateLayoutForReverseLandscape() {
        // Adjust your player layout for reverse landscape orientation
        val params = playerView.layoutParams
        params.width = ViewGroup.LayoutParams.MATCH_PARENT
        params.height = ViewGroup.LayoutParams.MATCH_PARENT
        playerView.layoutParams = params
    }
    // orientation handel

    override fun onPause() {
        super.onPause()
    }


}