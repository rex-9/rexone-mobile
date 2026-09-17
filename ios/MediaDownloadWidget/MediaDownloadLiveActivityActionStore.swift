//
//  MediaDownloadLiveActivityActionStore.swift
//  Shared by Runner + MediaDownloadWidget (Intent enqueue + Flutter drain).
//

import Foundation

enum MediaDownloadLiveActivityActionStore {
  static let appGroupId = "group.com.rexone.mobile"
  static let pendingActionKey = "media_download_la_pending_action"
  static let pendingAssetIdKey = "media_download_la_pending_asset_id"
  static let pendingAtKey = "media_download_la_pending_at"
  static let didEnqueueNotification = Notification.Name(
    "MediaDownloadLiveActivityActionDidEnqueue"
  )

  private static var shared: UserDefaults? {
    UserDefaults(suiteName: appGroupId)
  }

  static func enqueue(action: String, assetId: String) {
    guard let shared else { return }
    shared.set(action, forKey: pendingActionKey)
    shared.set(assetId, forKey: pendingAssetIdKey)
    shared.set(Date().timeIntervalSince1970, forKey: pendingAtKey)
    NotificationCenter.default.post(
      name: didEnqueueNotification,
      object: nil,
      userInfo: [
        "action": action,
        "assetId": assetId,
      ]
    )
  }

  static func takePending() -> [String: String]? {
    guard let shared else { return nil }
    guard let action = shared.string(forKey: pendingActionKey),
          let assetId = shared.string(forKey: pendingAssetIdKey),
          !action.isEmpty,
          !assetId.isEmpty
    else {
      return nil
    }
    shared.removeObject(forKey: pendingActionKey)
    shared.removeObject(forKey: pendingAssetIdKey)
    shared.removeObject(forKey: pendingAtKey)
    return [
      "action": action,
      "assetId": assetId,
    ]
  }
}
