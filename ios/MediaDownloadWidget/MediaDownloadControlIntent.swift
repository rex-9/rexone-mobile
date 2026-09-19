//
//  MediaDownloadControlIntent.swift
//  LiveActivityIntent runs in the app process without opening the UI (iOS 17+).
//  Must be in Runner + MediaDownloadWidget targets.
//

import AppIntents
import Foundation

@available(iOS 17.0, *)
struct MediaDownloadControlIntent: LiveActivityIntent {
  static var title: LocalizedStringResource = "Media Download Control"
  static var description = IntentDescription("Pause or resume an offline media download.")
  static var openAppWhenRun: Bool = false

  @Parameter(title: "Asset ID")
  var assetId: String

  @Parameter(title: "Action")
  var action: String

  init() {
    assetId = ""
    action = "pause"
  }

  init(assetId: String, action: String) {
    self.assetId = assetId
    self.action = action
  }

  func perform() async throws -> some IntentResult {
    let normalized = action.lowercased()
    guard normalized == "pause" || normalized == "resume", !assetId.isEmpty else {
      return .result()
    }

    MediaDownloadLiveActivityActionStore.enqueue(
      action: normalized,
      assetId: assetId
    )
    return .result()
  }
}
