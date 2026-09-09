import Flutter
import MediaPlayer
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    application.beginReceivingRemoteControlEvents()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: "rexone/now_playing",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
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
  }
}
