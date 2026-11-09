import AVFoundation
import Flutter
import UIKit

/// Emits classifications from AVAudioSession.currentRoute, not paired-device
/// or Bluetooth availability. Route-change reason is included for diagnostics.
final class AudioOutputRouteStreamHandler: NSObject, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private var routeObserver: NSObjectProtocol?

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    routeObserver = NotificationCenter.default.addObserver(
      forName: AVAudioSession.routeChangeNotification,
      object: AVAudioSession.sharedInstance(),
      queue: .main
    ) { [weak self] notification in
      self?.emitCurrentRoute(reason: notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt)
    }
    // Initial snapshot closes the gap between subscription and first change.
    emitCurrentRoute(reason: nil)
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    if let routeObserver {
      NotificationCenter.default.removeObserver(routeObserver)
      self.routeObserver = nil
    }
    eventSink = nil
    return nil
  }

  private func emitCurrentRoute(reason: UInt?) {
    let session = AVAudioSession.sharedInstance()
    let outputs = session.currentRoute.outputs
    let route: String

    if outputs.contains(where: {
      $0.portType == .bluetoothA2DP ||
      $0.portType == .bluetoothHFP ||
      $0.portType == .bluetoothLE
    }) {
      route = "bluetooth"
    } else if outputs.contains(where: {
      $0.portType == .builtInSpeaker || $0.portType == .builtInReceiver
    }) {
      route = "builtInSpeaker"
    } else if outputs.isEmpty {
      route = "unknown"
    } else {
      route = "other"
    }

    let reasonValue: Any = reason != nil ? Int(reason!) : NSNull()
    eventSink?([
      "route": route,
      "reason": reasonValue,
      "outputs": outputs.map { $0.portType.rawValue }
    ])
  }

  deinit {
    if let routeObserver {
      NotificationCenter.default.removeObserver(routeObserver)
    }
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let audioRouteChannelName = "com.example.iema/audio_output_route"
  private let audioRouteHandler = AudioOutputRouteStreamHandler()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    FlutterEventChannel(
      name: audioRouteChannelName,
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    ).setStreamHandler(audioRouteHandler)
  }
}
