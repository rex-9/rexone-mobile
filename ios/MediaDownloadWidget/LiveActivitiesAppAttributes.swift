//
//  LiveActivitiesAppAttributes.swift
//  MediaDownloadWidget only — live_activities requires this exact type name.
//  Do not add this file to the Runner target (breaks Live Activity presentation).
//

import ActivityKit
import Foundation

struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
  public typealias LiveDeliveryData = ContentState

  public struct ContentState: Codable, Hashable {
    var appGroupId: String?
    var updateId: Double?
  }

  var id = UUID()
}

extension LiveActivitiesAppAttributes {
  func prefixedKey(_ key: String) -> String {
    "\(id)_\(key)"
  }
}
