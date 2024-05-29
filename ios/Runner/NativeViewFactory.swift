//
//  NativeViewFactory.swift
//  Runner
//
//

import Foundation
import GoogleInteractiveMediaAds
import GSPlayer
import Flutter

class NativeViewFactory : NSObject, FlutterPlatformViewFactory {
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

public class NativeView : NSObject, FlutterPlatformView, fullScreeenDelegate, IMAAdsLoaderDelegate, IMAAdsManagerDelegate {

    deinit {
        stopTimer()
        playerView.pause()
    }

    private var _view: UIView
    var kTestAppContentUrl_MP4 = ""

    var settings = UIButton()
    var playerView = VideoPlayerView()
    var controlView = GSPlayerControlUIView()

    var contentPlayhead: IMAAVPlayerContentPlayhead?
    var adsLoader: IMAAdsLoader!
    var adsManager: IMAAdsManager!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let controller = UIApplication.topViewController()

    var item: AVPlayerItem!

    var message: FlutterBinaryMessenger!
    weak var timer: Timer?

    static let kTestAppAdTagUrl =
        "https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/vmap_ad_samples&sz=640x480&cust_params=sample_ar%3Dpreonly&ciu_szs=300x250%2C728x90&gdfp_req=1&ad_rule=1&output=vmap&unviewed_position_start=1&env=vp&impl=s&correlator="

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView()
        super.init()

        if let argumentsDictionary = args as? [String: Any] {
            self.kTestAppContentUrl_MP4 = argumentsDictionary["videoURL"] as! String
            print("test URL:", kTestAppContentUrl_MP4)
        }
        message = messenger

        let flutterChannel = FlutterMethodChannel(name: "bms_video_player",
                                                  binaryMessenger: messenger!)
        flutterChannel.setMethodCallHandler { (call: FlutterMethodCall, result: FlutterResult) -> Void in
            switch call.method {
            case "pauseVideo":
                self.playerView.pause(reason: .userInteraction)
                if self.adsManager.adPlaybackInfo.isPlaying {
                    self.adsManager.pause()
                }
                return

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        setUpContentPlayer(view: _view)
        setUpAdsLoader()
        createNativeView(view: _view)
        startTimer()
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { [weak self] _ in
            self?.controlView.isHidden = true
        }
    }

    func stopTimer() {
        timer?.invalidate()
        playerView.pause()
    }

    func fullScreenTap() {
        print("fullScreen tapped!!")
        let flutterChannel = FlutterMethodChannel(name: "bms_video_player",
                                                  binaryMessenger: message!)
        flutterChannel.invokeMethod("fullScreen", arguments: 0)

        playerView.frame = UIScreen.main.bounds
        controlView.frame = UIScreen.main.bounds
    }

    func normalScreenTap() {
        print("normalScreen tapped!!")
        let flutterChannel = FlutterMethodChannel(name: "bms_video_player",
                                                  binaryMessenger: message!)
        flutterChannel.invokeMethod("normalScreen", arguments: 0)

        playerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 400)
        controlView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 400)
    }

    func backButtonTap() {
        playerView.pause(reason: .userInteraction)
        if adsManager.adPlaybackInfo.isPlaying {
            adsManager.pause()
        }
        let flutterChannel = FlutterMethodChannel(name: "bms_video_player", binaryMessenger: message!)
        flutterChannel.invokeMethod("onBackButtonClicked", arguments: nil)
    }

    func setUpContentPlayer(view _view: UIView) {
        print("test URL1:", kTestAppContentUrl_MP4)

        guard let contentURL = URL(string: kTestAppContentUrl_MP4) else {
            print("ERROR: please use a valid URL for the content URL")
            return
        }

        let controller = AVPlayerViewController()
        let player = AVPlayer(url: contentURL)
        controller.player = player

        playerView.translatesAutoresizingMaskIntoConstraints = false
        controlView.translatesAutoresizingMaskIntoConstraints = false

        playerView.contentMode = .scaleAspectFill
        playerView.play(for: contentURL)

        controlView.delegate = self
        controlView.populate(with: playerView)

        _view.addSubview(playerView)
        _view.addSubview(controlView)

        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: _view.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: _view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: _view.trailingAnchor),
            playerView.bottomAnchor.constraint(equalTo: _view.bottomAnchor),

            controlView.topAnchor.constraint(equalTo: _view.topAnchor),
            controlView.leadingAnchor.constraint(equalTo: _view.leadingAnchor),
            controlView.trailingAnchor.constraint(equalTo: _view.trailingAnchor),
            controlView.bottomAnchor.constraint(equalTo: _view.bottomAnchor)
        ])

        playerView.pause(reason: .userInteraction)
        controlView.isHidden = true
        controlView.bringSubviewToFront(_view)

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.touchHappen(_:)))
        playerView.addGestureRecognizer(tap)
        playerView.isUserInteractionEnabled = true

        contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: playerView.player!)
    }

    @objc func touchHappen(_ sender: UITapGestureRecognizer) {
        print("touchHappen")
        self.controlView.isHidden = false
    }

    @objc func applicationDidEnterBackground(_ notification: NSNotification) {
        playerView.pause(reason: .userInteraction)
    }

    func setUpAdsLoader() {
        adsLoader = IMAAdsLoader(settings: nil)
        adsLoader.delegate = self
    }

    func requestAds(view _view: UIView) {
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: _view, viewController: controller, companionSlots: nil)
        let request = IMAAdsRequest(adTagUrl: NativeView.kTestAppAdTagUrl, adDisplayContainer: adDisplayContainer, contentPlayhead: contentPlayhead, userContext: controlView)

        adsLoader.requestAds(with: request)
    }

    public func view() -> UIView {
        return _view
    }

    func createNativeView(view _view: UIView) {
        _view.backgroundColor = UIColor.black

        settings.addTarget(self, action: #selector(touchedSet), for: .touchUpInside)
        settings.setImage(UIImage(named: "play_48px"), for: .normal)
        settings.translatesAutoresizingMaskIntoConstraints = false
        _view.addSubview(settings)
        _view.bringSubviewToFront(controlView)
        _view.bringSubviewToFront(settings)

        NSLayoutConstraint.activate([
            settings.widthAnchor.constraint(equalToConstant: 50),
            settings.heightAnchor.constraint(equalToConstant: 50),
            settings.centerXAnchor.constraint(equalTo: _view.centerXAnchor),
            settings.centerYAnchor.constraint(equalTo: _view.centerYAnchor)
        ])
    }

    @objc func touchedSet(sender: UIButton!) {
        print("You tapped the button")
        requestAds(view: _view)
        settings.isHidden = true
    }

    // MARK: - IMAAdsLoaderDelegate

    public func adsLoader(_ loader: IMAAdsLoader, adsLoadedWith adsLoadedData: IMAAdsLoadedData) {
        adsManager = adsLoadedData.adsManager
        adsManager.delegate = self

        let adsRenderingSettings = IMAAdsRenderingSettings()
        adsRenderingSettings.linkOpenerPresentingController = controller

        adsManager.initialize(with: adsRenderingSettings)
        controlView.onClicked_FullScreen(self)
    }

    public func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
        playerView.resume()
        controlView.isHidden = false
    }

    // MARK: - IMAAdsManagerDelegate

    public func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
        if event.type == .LOADED {
            adsManager.start()
        }
        if event.type == .RESUME {
            settings.isHidden = false
        }
        if event.type == .PAUSE {
            if adsManager.adPlaybackInfo.isPlaying {
                adsManager.pause()
            }
            settings.isHidden = false
        }
        if event.type == .TAPPED {
            if !adsManager.adPlaybackInfo.isPlaying {
                adsManager.resume()
            }
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
        print("AdsManager resume: \("nil")")
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
