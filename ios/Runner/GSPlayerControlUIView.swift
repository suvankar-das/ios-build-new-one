//
//  GSPlayerControlUIView.swift
//  Spotlighter
//
//

import UIKit
import CoreMedia
import GSPlayer
import Flutter
import MediaPlayer


protocol fullScreeenDelegate: class {
    func fullScreenTap()
    func normalScreenTap()
    func backButtonTap()
    
}


@IBDesignable
class GSPlayerControlUIView: UIView {
    
    // MARK: IBOutlet
    @IBOutlet weak var play_Button: UIButton!
    @IBOutlet weak var duration_Slider: UISlider!
    @IBOutlet weak var currentDuration_Label: UILabel!
    @IBOutlet weak var totalDuration_Label: UILabel!
    @IBOutlet weak var fullscreen_Button : UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    weak var delegate: fullScreeenDelegate?
    var isFullScreen = false

    
    // MARK: Variables
    private var videoPlayer: VideoPlayerView!
    
    //MARK: Skip Intro and Recap
    var skipIntroStartTime: String = ""
    var skipIntroEndTime: String = ""
    private var skipIntroButton: UIButton!
    
    var skipRecapStartTime: String = ""
    var skipRecapEndTime: String = ""
    private var skipRecapButton: UIButton!
    
    //start play from specific time
    var startPlayFromTime = ""
    
    // MARK: Listeners
    var onStateDidChanged: ((VideoPlayerView.State) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.commonInit()
    }
    
    
    func commonInit() {
        guard let view = Bundle(for: GSPlayerControlUIView.self).loadNibNamed("GSPlayerControlUIView", owner: self, options: nil)?.first as? UIView else { return }
        
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.isUserInteractionEnabled = false
        
        self.addSubview(view)
        
        //skip Intro
        createSkipIntroButton()
        // skip recap
        createSkipRecapButton()
    }
}

// MARK: Functions
extension GSPlayerControlUIView {
    
    func populate(with videoPlayer: VideoPlayerView, skipIntroStartTime: String, skipIntroEndTime: String,skipRecapStartTime:String,skipRecapEndTime:String,
                  startPlayFromTime:String) {
        self.videoPlayer = videoPlayer
        self.isUserInteractionEnabled = true
        self.skipIntroStartTime = skipIntroStartTime
        self.skipIntroEndTime = skipIntroEndTime
        self.skipRecapStartTime = skipRecapStartTime
        self.skipRecapEndTime = skipRecapEndTime
        self.startPlayFromTime = startPlayFromTime
        
        setPeriodicTimer()
        setOnClicked_VideoPlayer()
        setStateDidChangedListener()
        
        duration_Slider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSlider(_:))))
    }
    
    private func setStateDidChangedListener()  {
        videoPlayer.stateDidChanged = { [weak self] state in
            guard let self = self else { return }
            
            if case .playing = state {
                self.setOnStartPlaying()
            }
            
            switch state {
            case .playing, .paused: self.duration_Slider.isEnabled = true
            default: self.duration_Slider.isEnabled = false
            }
            
            self.play_Button.setImage(state == .playing ? UIImage(named: "pause_48px") : UIImage(named: "play_48px"), for: .normal)
            
            if let listener = self.onStateDidChanged { listener(state) }
        }
        
        videoPlayer.replay = { [weak self] in
            if self != nil
            {
                self!.currentDuration_Label.text = "00:00"
                self!.duration_Slider.setValue(0, animated: false)
            }
        }
    }
    
    private func setOnStartPlaying() {
        let totalDuration = videoPlayer.totalDuration
        
        duration_Slider.maximumValue = Float(totalDuration)
        totalDuration_Label.text = getTimeString(seconds: Int(totalDuration))
        
        
        // Start playback from a specified time or from the beginning
        
        /*
               if let startTime = Int(startPlayFromTime), !startPlayFromTime.isEmpty {
                   videoPlayer.seek(to: CMTime(seconds: Double(startTime), preferredTimescale: 60))
               } else {
                   videoPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 60))
               }
         
         */
    }
    
    private func setPeriodicTimer() {
        videoPlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 60), using: { [weak self] _ in
            if self != nil
            {
                let currentDuration = self!.videoPlayer.currentDuration
                self!.currentDuration_Label.text = self!.getTimeString(seconds: Int(currentDuration))
                self!.duration_Slider.setValue(Float(currentDuration), animated: true)
                
                let currentDurationInt = Int(currentDuration)                
                //skip Intro Button show/hide
                if let skipIntroStartTimeStr = self?.skipIntroStartTime,
                   let skipIntroEndTimeStr = self?.skipIntroEndTime,
                   let skipIntroStartTimeInt = Int(skipIntroStartTimeStr),
                   let skipIntroEndTimeInt = Int(skipIntroEndTimeStr) {
                       
                       self?.skipIntroButton.isHidden = currentDurationInt == nil || !(currentDurationInt >= skipIntroStartTimeInt && currentDurationInt <= skipIntroEndTimeInt)
                } else {
                    self?.skipIntroButton.isHidden = true
                }
                
                //skip Recap Button show/hide
                if let skipRecapStartTimeStr = self?.skipRecapStartTime,
                   let skipRecapEndTimeStr = self?.skipRecapEndTime,
                   let skipRecapStartTimeInt = Int(skipRecapStartTimeStr),
                   let skipRecapEndTimeInt = Int(skipRecapEndTimeStr) {
                       
                       self?.skipRecapButton.isHidden = currentDurationInt == nil || !(currentDurationInt >= skipRecapStartTimeInt && currentDurationInt <= skipRecapEndTimeInt)
                } else {
                    self?.skipRecapButton.isHidden = true
                }            
            }
        })
    }
    
    private func getTimeString(seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
    
    //MARK: skip button design section
    private func createSkipIntroButton() {
        skipIntroButton = UIButton(type: .custom)
        skipIntroButton.setTitle("Skip Intro", for: .normal)
        skipIntroButton.addTarget(self, action: #selector(onClicked_SkipIntro(_:)), for: .touchUpInside)
        skipIntroButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(skipIntroButton)
        
        NSLayoutConstraint.activate([
            skipIntroButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
                skipIntroButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -80)
        ])
    }
    
    private func createSkipRecapButton() {
        skipRecapButton = UIButton(type: .custom)
        skipRecapButton.setTitle("Skip Recap", for: .normal)
        skipRecapButton.addTarget(self, action: #selector(onClicked_SkipRecap(_:)), for: .touchUpInside)
        skipRecapButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(skipRecapButton)
        
        NSLayoutConstraint.activate([
            skipRecapButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            skipRecapButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -80)
        ])
    }}


// MARK: onClicked
extension GSPlayerControlUIView {
    @IBAction func backButtonTapped(_ sender: UIButton) {
        delegate?.backButtonTap()
    }
    
    @IBAction func onClicked_Play(_ sender: Any) {
        if (videoPlayer.state == .playing) {
            videoPlayer.pause(reason: .userInteraction)
        } else {
            videoPlayer.resume()
        }
    }
    
    @IBAction func onClicked_Backward(_ sender: Any) {
        videoPlayer.seek(to: CMTime(seconds: Double(max(videoPlayer.currentDuration - 10, 0)), preferredTimescale: 60))
    }
    
    @IBAction func onClicked_Forward(_ sender: Any) {
        videoPlayer.seek(to: CMTime(seconds: Double(min(videoPlayer.currentDuration + 10, videoPlayer.totalDuration)), preferredTimescale: 60))
    }
    
    @IBAction func onClicked_FullScreen(_ sender: Any) {
        
        if isFullScreen == false{
        delegate?.fullScreenTap()
            isFullScreen = true
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.myOrientation = .landscapeLeft
                   UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
                    UIView.setAnimationsEnabled(true)
            self.fullscreen_Button.setImage(UIImage(named: "normal_screen"), for: .normal)
        }else{
            isFullScreen = false
            delegate?.normalScreenTap()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.myOrientation = .portrait
            self.fullscreen_Button.setImage(UIImage(named: "full_screen"), for: .normal)
        }
    }
    

    
    private func setOnClicked_VideoPlayer() {
        videoPlayer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClicked_Video(_:))))
    }
    
    @objc private func onClicked_SkipIntro(_ sender: UIButton) {
        
            if let startTime = Int(skipIntroStartTime), let endTime = Int(skipIntroEndTime) {
                videoPlayer.seek(to: CMTime(seconds: Double(endTime), preferredTimescale: 60))
            }
        }
    
    @objc private func onClicked_SkipRecap(_ sender: UIButton) {
        
            if let startTime = Int(skipRecapStartTime), let endTime = Int(skipRecapEndTime) {
                videoPlayer.seek(to: CMTime(seconds: Double(endTime), preferredTimescale: 60))
            }
        }
    
    @IBAction func onClicked_Video(_ sender: Any) {
        UIView.animate(withDuration: 0.2) {
            self.alpha = self.alpha == 0 ? 1 : 0
        }
    }
    
    @IBAction func tapSlider(_ gestureRecognizer: UIGestureRecognizer) {
        let pointTapped: CGPoint = gestureRecognizer.location(in: self)
        
        let positionOfSlider: CGPoint = duration_Slider.frame.origin
        let widthOfSlider: CGFloat = duration_Slider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(duration_Slider.maximumValue) / widthOfSlider)
        
        duration_Slider.setValue(Float(newValue), animated: false)
        onValueChanged_DurationSlider(duration_Slider)
    }
    
    @IBAction func onValueChanged_DurationSlider(_ sender: UISlider) {
        videoPlayer.seek(to: CMTime(seconds: Double(sender.value), preferredTimescale: 60))
    }
}

