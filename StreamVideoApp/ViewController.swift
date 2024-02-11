//
//  ViewController.swift
//  StreamVideoApp
//
//  Created by iMad on 09/02/2024.
//

import AVFoundation
import GoogleInteractiveMediaAds
import UIKit

class ViewController: UIViewController, IMAAdsLoaderDelegate, IMAAdsManagerDelegate {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var videoVw: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var fastForwardButton: UIButton!
    @IBOutlet weak var timelineSlider: UISlider!
    @IBOutlet weak var closeButton: UIButton!
    
    private var playerTimeObserver: Any?
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var contentPlayhead: IMAAVPlayerContentPlayhead?
    private let adsLoader = IMAAdsLoader(settings: nil)
    private var adsManager: IMAAdsManager?
    
    var videoModel: MediaContent?
    var isSubscriber: Bool?

  // MARK: - View controller lifecycle methods

  override func viewDidLoad() {
    super.viewDidLoad()
      setupPlayerControls()
    playButton.layer.zPosition = CGFloat.greatestFiniteMagnitude

    setUpContentPlayer()
    adsLoader.delegate = self
  }

  override func viewDidAppear(_ animated: Bool) {
    playerLayer?.frame = self.videoVw.layer.bounds
  }

    @IBAction func onPlayButtonTouch(_ sender: Any) {
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        let isSubscriber = UserDefaults.standard.bool(forKey: "isSubscriber")
        if isSubscriber{
            // If the user is a subscriber, play the content directly
            playContent()
        } else {
            // If not a subscriber, request ads and then play the content
            requestAds()
        }
        playButton.isHidden = true
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupPlayer() {
           // Initialize AVPlayer with your video URL
           guard let videoURL = Bundle.main.url(forResource: "example_video", withExtension: "mp4") else { return }
           let playerItem = AVPlayerItem(url: videoURL)
           player = AVPlayer(playerItem: playerItem)
           let playerLayer = AVPlayerLayer(player: player)
           playerLayer.frame = videoVw.bounds
           videoVw.layer.addSublayer(playerLayer)
            addTimeObserverToPlayer()
           player?.play()
       }
    
    private func setupPlayerControls() {
            playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped(_:)), for: .touchUpInside)
            rewindButton.addTarget(self, action: #selector(rewindButtonTapped(_:)), for: .touchUpInside)
            fastForwardButton.addTarget(self, action: #selector(fastForwardButtonTapped(_:)), for: .touchUpInside)
            timelineSlider.addTarget(self, action: #selector(timelineSliderValueChanged(_:)), for: .valueChanged)
        }
    
    @objc private func playPauseButtonTapped(_ sender: UIButton) {
        playButton.isHidden = true
            if player?.rate == 0 {
                player?.play()
                playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            } else {
                player?.pause()
                playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
        }

        @objc private func rewindButtonTapped(_ sender: UIButton) {
            let currentTime = player?.currentTime()
            let newTime = CMTimeSubtract(currentTime ?? CMTime.zero, CMTime(seconds: 10, preferredTimescale: 1))
            player?.seek(to: newTime)
        }

        @objc private func fastForwardButtonTapped(_ sender: UIButton) {
            let currentTime = player?.currentTime()
            let newTime = CMTimeAdd(currentTime ?? CMTime.zero, CMTime(seconds: 10, preferredTimescale: 1))
            player?.seek(to: newTime)
        }

        @objc private func timelineSliderValueChanged(_ sender: UISlider) {
            let duration = player?.currentItem?.duration.seconds ?? 0
            let timeToSeek = duration * Double(sender.value)
            player?.seek(to: CMTime(seconds: timeToSeek, preferredTimescale: 1))
        }
    
    private func addTimeObserverToPlayer() {
           guard let player = player else { return }

           // Add time observer to update timelineSlider
           let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
           playerTimeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
               guard let duration = self?.player?.currentItem?.duration.seconds else { return }
               let currentTime = time.seconds
               let sliderValue = Float(currentTime / duration)
               self?.timelineSlider.value = sliderValue
           }
        addPeriodicTimeObserver()
       }
    
    func addPeriodicTimeObserver() {
           guard let player = player else { return }
           
           // Calculate the interval for updating the slider position (e.g., every 1 second)
           let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
           
           // Add a time observer to update the slider position
           player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
               // Update the slider value based on the current playback time
               guard let duration = self?.player?.currentItem?.duration.seconds else { return }
               let currentTime = time.seconds
               self?.timelineSlider.value = Float(currentTime / duration)
           }
       }
    
    private func playContent() {
        // Play the content directly without ads
        player?.play()
    }

  // MARK: Content player methods

  private func setUpContentPlayer() {
    // Load AVPlayer with path to our content.
      guard let contentURL = URL(string: videoModel!.hlsMediaURL) else {
      print("ERROR: use a valid URL for the content URL")
      return
    }
    self.player = AVPlayer(url: contentURL)
    guard let contentPlayer = self.player else { return }

    // Create a player layer for the player.
    self.playerLayer = AVPlayerLayer(player: contentPlayer)
    guard let playerLayer = self.playerLayer else { return }

    // Size, position, and display the AVPlayer.
    playerLayer.frame = videoVw.layer.bounds
      videoVw.layer.addSublayer(playerLayer)

    // Set up our content playhead and contentComplete callback.
    contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: contentPlayer)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(ViewController.contentDidFinishPlaying(_:)),
      name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
      object: contentPlayer.currentItem)
  }

  @objc func contentDidFinishPlaying(_ notification: Notification) {
    // Make sure we don't call contentComplete as a result of an ad completing.
    if (notification.object as! AVPlayerItem) == player?.currentItem {
      adsLoader.contentComplete()
    }
  }

  // MARK: IMA integration methods

  private func requestAds() {
    // Create ad display container for ad rendering.
    let adDisplayContainer = IMAAdDisplayContainer(
      adContainer: videoVw, viewController: self, companionSlots: nil)
    // Create an ad request with our ad tag, display container, and optional user context.
    let request = IMAAdsRequest(
        adTagUrl: videoModel!.adsTagURL,
      adDisplayContainer: adDisplayContainer,
      contentPlayhead: contentPlayhead,
      userContext: nil)

    adsLoader.requestAds(with: request)
  }

  // MARK: - IMAAdsLoaderDelegate

  func adsLoader(_ loader: IMAAdsLoader, adsLoadedWith adsLoadedData: IMAAdsLoadedData) {
    // Grab the instance of the IMAAdsManager and set ourselves as the delegate.
    adsManager = adsLoadedData.adsManager
    adsManager?.delegate = self

    // Create ads rendering settings and tell the SDK to use the in-app browser.
    let adsRenderingSettings = IMAAdsRenderingSettings()
    adsRenderingSettings.linkOpenerPresentingController = self

    // Initialize the ads manager.
    adsManager?.initialize(with: adsRenderingSettings)
  }

  func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
    print("Error loading ads: \(adErrorData.adError.message ?? "nil")")
      player?.play()
  }

  // MARK: - IMAAdsManagerDelegate

  func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
    if event.type == IMAAdEventType.LOADED {
      // When the SDK notifies us that ads have been loaded, play them.
      adsManager.start()
    }
  }

  func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
    // Something went wrong with the ads manager after ads were loaded. Log the error and play the
    // content.
    print("AdsManager error: \(error.message ?? "nil")")
      player?.play()
  }

  func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
    // The SDK is going to play ads, so pause the content.
      player?.pause()
  }

  func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
    // The SDK is done playing ads (at least for now), so resume the content.
      player?.play()
  }
}
