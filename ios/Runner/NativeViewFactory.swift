

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
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    private var _view: UIView
    var kTestAppContentUrl_MP4 = ""
    var videoId: String = ""
    var skipIntroStartTime: String = ""
    var skipIntroEndTime:String = ""
    var skipRecapStartTime:String = ""
    var skipRecapEndTime:String = ""
    var startPlayFromTime:String = ""
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

    static var kTestAppAdTagUrl = ""

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView()
        
        if let args = args as? [String: Any],
                   let videoId = args["videoId"] as? String {
                    self.videoId = videoId
                }

        NativeView.kTestAppAdTagUrl = "https://indimuse.in/api/v1/vmap/\(self.videoId)";
        super.init()
        //start
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(deviceOrientationDidChange),
                name: UIDevice.orientationDidChangeNotification,
                object: nil
            )        //end
        
        if let argumentsDictionary = args as? [String: Any] {
            self.kTestAppContentUrl_MP4 = argumentsDictionary["videoURL"] as! String
            self.skipIntroStartTime = argumentsDictionary["skipIntroStartTime"] as! String
            self.skipIntroEndTime = argumentsDictionary["skipIntroEndTime"] as! String
            self.skipRecapStartTime = argumentsDictionary["skipRecapStartTime"] as! String
            self.skipRecapEndTime = argumentsDictionary["skipRecapEndTime"] as! String
            self.startPlayFromTime = argumentsDictionary["startPlayFromTime"] as! String
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.touchedSet(sender: self?.settings)
        }
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
    
    @objc func deviceOrientationDidChange() {
        let orientation = UIDevice.current.orientation
        switch orientation {
        case .landscapeLeft:
            switchToFullScreen(isReversed: false)
        case .landscapeRight:
            switchToFullScreen(isReversed: true)
        case .portrait, .portraitUpsideDown:
            switchToNormalScreen()
        default:
            break
        }
    }
    

    func switchToFullScreen(isReversed: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        if isReversed {
            appDelegate.myOrientation = .landscapeRight
        } else {
            appDelegate.myOrientation = .landscapeLeft
        }

        UIView.animate(withDuration: 0.3) {
            // Use appropriate rotation angles for landscape orientations
            let angle: CGFloat = isReversed ? 0  : -.pi
            self.playerView.transform = CGAffineTransform(rotationAngle: angle)
            self.controlView.transform = CGAffineTransform(rotationAngle: angle)

            self.playerView.frame = UIScreen.main.bounds
            self.controlView.frame = UIScreen.main.bounds

            // Ensure the subviews are correctly laid out
            self.controlView.layoutIfNeeded()
        }
    }
    
    
    func switchToNormalScreen() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.myOrientation = .portrait
        playerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 400)
        controlView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 400)
    }
    
    
    func fullScreenTap() {
        let flutterChannel = FlutterMethodChannel(name: "bms_video_player", binaryMessenger: message!)
                flutterChannel.invokeMethod("fullScreen", arguments: 0)

                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.myOrientation = .landscape
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
                UIView.setAnimationsEnabled(true)

                playerView.frame = UIScreen.main.bounds
                controlView.frame = UIScreen.main.bounds
    }

    func normalScreenTap() {
                let flutterChannel = FlutterMethodChannel(name: "bms_video_player", binaryMessenger: message!)
                flutterChannel.invokeMethod("normalScreen", arguments: 0)

                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.myOrientation = .portrait
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                UIView.setAnimationsEnabled(true)

                playerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 400)
                controlView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 400)
    }

    func backButtonTap() {
        do {
            defer {
                let flutterChannel = FlutterMethodChannel(name: "bms_video_player", binaryMessenger: message!)
                flutterChannel.invokeMethod("onBackButtonClicked", arguments: nil)
            }

            playerView.pause(reason: .userInteraction)

            if let adsManager = adsManager, adsManager.adPlaybackInfo.isPlaying {
                adsManager.pause()
            }
        } catch {
            print("An error occurred: \(error)")
        }
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
        controlView.populate(with: playerView,skipIntroStartTime: self.skipIntroStartTime,skipIntroEndTime:self.skipIntroEndTime,skipRecapStartTime:self.skipRecapStartTime,skipRecapEndTime:self.skipRecapEndTime,
                             startPlayFromTime: self.startPlayFromTime
        )
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: playerView.player?.currentItem)
    }
    
    
    @objc func playerDidFinishPlaying(_ notification: Notification) {
        controlView.isHidden = false
        //requestAds(view: playerView)
        playerView.pause(reason: .userInteraction)
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
        //settings.setImage(UIImage(named: "play_48px"), for: .normal)
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
        controlView.onClicked_FullScreen(self)
    }

    // MARK: - IMAAdsLoaderDelegate

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


