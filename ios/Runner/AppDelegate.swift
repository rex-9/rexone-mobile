import Flutter
import MediaPlayer
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var mediaDownloadLiveActivityChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    application.beginReceivingRemoteControlEvents()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let nowPlayingChannel = FlutterMethodChannel(
      name: "rexone/now_playing",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    nowPlayingChannel.setMethodCallHandler { call, result in
      let center = MPNowPlayingInfoCenter.default()
      switch call.method {
      case "setPlaybackState":
        let playing = (call.arguments as? [String: Any])?["playing"] as? Bool ?? false
        if #available(iOS 13.0, *) {
          center.playbackState = playing ? .playing : .paused
        }
        if var info = center.nowPlayingInfo {
          info[MPNowPlayingInfoPropertyPlaybackRate] = playing ? 1.0 : 0.0
          center.nowPlayingInfo = info
        }
        result(nil)
      case "clear":
        center.nowPlayingInfo = nil
        if #available(iOS 13.0, *) {
          center.playbackState = .stopped
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    let mediaChannel = FlutterMethodChannel(
      name: "rexone/media_download_live_activity",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    mediaDownloadLiveActivityChannel = mediaChannel
    mediaChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "takePending":
        result(MediaDownloadLiveActivityActionStore.takePending())
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    NotificationCenter.default.addObserver(
      forName: MediaDownloadLiveActivityActionStore.didEnqueueNotification,
      object: nil,
      queue: .main
    ) { [weak self] notification in
      self?.mediaDownloadLiveActivityChannel?.invokeMethod(
        "action",
        arguments: notification.userInfo
      )
    }
  }
}
