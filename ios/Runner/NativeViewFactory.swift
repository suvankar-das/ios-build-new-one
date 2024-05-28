import Foundation
import GoogleInteractiveMediaAds
import GSPlayer
import Flutter

class NativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return NativeView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }
}

public class NativeView: NSObject, FlutterPlatformView, fullScreeenDelegate, IMAAdsLoaderDelegate, IMAAdsManagerDelegate {

    deinit {
        stopTimer()
        playerView.pause()
    }

    private var _view: UIView
    var kTestAppContentUrl_MP4 = ""

    var settings = UIButton()
    var playerView = VideoPlayerView()
    var controlView = GSPlayerControlUIView()
    var paybackSlider = UISlider()

    var contentPlayhead: IMAAVPlayerContentPlayhead?
    var adsLoader: IMAAdsLoader!
    var adsManager: IMAAdsManager!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let controller = UIApplication.topViewController()

    var item: AVPlayerItem!
    var message: FlutterBinaryMessenger!
    weak var timer: Timer?

    static let kTestAppAdTagUrl =
        "https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/vmap_ad_samples&sz=640x480&cust_params=sample_ar%3Dpremidpostpod&ciu_szs=300x250&gdfp_req=1&ad_rule=1&output=vmap&unviewed_position_start=1&env=vp&impl=s&cmsid=496&vid=short_onecue&correlator="

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView()
        super.init()

        if let argumentsDictionary = args as? Dictionary<String, Any> {
            self.kTestAppContentUrl_MP4 = argumentsDictionary["videoURL"] as! String
            print("test URL:", kTestAppContentUrl_MP4)
        }
        message = messenger

        let flutterChannel = FlutterMethodChannel(name: "bms_video_player", binaryMessenger: messenger!)

        flutterChannel.setMethodCallHandler({ (call: FlutterMethodCall, result: FlutterResult) -> Void in
            switch call.method {
            case "pauseVideo":
                self.playerView.pause(reason: .userInteraction)
                if self.adsManager.adPlaybackInfo.isPlaying {
                    self.adsManager.pause()
                }
                result(nil)
            case "autoplay":
                self.autoplayVideo()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        })

        setUpContentPlayer(view: _view)
        setUpAdsLoader()
        createNativeView(view: _view)
        startTimer()
        controlView.onClicked_FullScreen = { [weak self] in
            guard let self = self else { return }
            self.enterFullScreen()
        }
    }

    public func view() -> UIView {
        return _view
    }

    private func setUpContentPlayer(view: UIView) {
        let url = URL(string: kTestAppContentUrl_MP4)!
        let item = AVPlayerItem(url: url)
        playerView.replaceCurrentItem(with: item)
        contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: playerView.player)
    }

    private func setUpAdsLoader() {
        let settings = IMASettings()
        settings.language = Locale.preferredLanguages.first
        adsLoader = IMAAdsLoader(settings: settings)
        adsLoader.delegate = self
    }

    private func createNativeView(view: UIView) {
        playerView.frame = view.bounds
        playerView.contentMode = .scaleAspectFit
        playerView.playbackDelegate = self
        view.addSubview(playerView)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updatePlaybackProgress()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
    }

    private func updatePlaybackProgress() {
        // Update playback progress logic
    }

    private func enterFullScreen() {
        // Fullscreen logic
    }

    private func autoplayVideo() {
        requestAds(view: _view)
        playerView.resume()
        controlView.isHidden = false
    }

    func requestAds(view _view: UIView) {
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: _view, viewController: controller, companionSlots: nil)
        let request = IMAAdsRequest(
            adTagUrl: NativeView.kTestAppAdTagUrl,
            adDisplayContainer: adDisplayContainer,
            contentPlayhead: contentPlayhead,
            userContext: controlView)

        adsLoader.requestAds(with: request)
    }

    public func adsLoader(_ loader: IMAAdsLoader, adsLoadedWith adsLoadedData: IMAAdsLoadedData) {
        adsManager = adsLoadedData.adsManager
        adsManager.delegate = self

        let adsRenderingSettings = IMAAdsRenderingSettings()
        adsRenderingSettings.linkOpenerPresentingController = controller

        adsManager.initialize(with: adsRenderingSettings)
    }

    public func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
        playerView.resume()
        controlView.isHidden = false
    }

    public func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
        if event.type == IMAAdEventType.LOADED {
            adsManager.start()
        }
        if event.type == IMAAdEventType.RESUME || event.type == IMAAdEventType.TAPPED {
            settings.isHidden = true
        }
        if event.type == IMAAdEventType.PAUSE {
            settings.isHidden = false
        }
    }

    public func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
        print("AdsManager error: \(error.message ?? "nil")")
        playerView.resume()
        controlView.isHidden = false
    }

    public func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
        playerView.pause(reason: .userInteraction)
        controlView.isHidden = true
    }

    public func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
        print("AdsManager resume: \(String(describing: error.message))")
        playerView.resume()
        controlView.isHidden = false
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
