//
//  MediaDownloadWidgetLiveActivity.swift
//  MediaDownloadWidget
//
//  Live Activity UI for offline media downloads (live_activities plugin).
//  Attribute type name must stay exactly: LiveActivitiesAppAttributes
//

import ActivityKit
import SwiftUI
import WidgetKit

/// Must match the shape used by `live_activities` 2.6.x in the Runner process.
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

private let sharedDefault = UserDefaults(suiteName: "group.com.rexone.mobile")!

@available(iOSApplicationExtension 16.1, *)
struct MediaDownloadWidgetLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
      let title = Self.title(from: context.attributes)
      let progress = Self.progress(from: context.attributes)

      VStack(alignment: .leading, spacing: 8) {
        Text(title)
          .font(.headline)
          .lineLimit(2)

        ProgressView(value: Double(progress), total: 100)
          .tint(.accentColor)

        Text("\(progress)%")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .activityBackgroundTint(Color(.systemBackground).opacity(0.85))
    } dynamicIsland: { context in
      let title = Self.title(from: context.attributes)
      let progress = Self.progress(from: context.attributes)

      return DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Image(systemName: "arrow.down.circle.fill")
            .foregroundStyle(.tint)
        }
        DynamicIslandExpandedRegion(.trailing) {
          Text("\(progress)%")
            .font(.title3.monospacedDigit().weight(.semibold))
        }
        DynamicIslandExpandedRegion(.bottom) {
          VStack(alignment: .leading, spacing: 6) {
            Text(title)
              .font(.subheadline)
              .lineLimit(2)
            ProgressView(value: Double(progress), total: 100)
          }
        }
      } compactLeading: {
        Image(systemName: "arrow.down.circle.fill")
      } compactTrailing: {
        Text("\(progress)%")
          .font(.caption2.monospacedDigit())
      } minimal: {
        Image(systemName: "arrow.down.circle.fill")
      }
      .keylineTint(.accentColor)
    }
  }

  private static func title(from attributes: LiveActivitiesAppAttributes) -> String {
    sharedDefault.string(forKey: attributes.prefixedKey("title")) ?? "Downloading"
  }

  private static func progress(from attributes: LiveActivitiesAppAttributes) -> Int {
    let key = attributes.prefixedKey("progress")
    if let number = sharedDefault.object(forKey: key) as? NSNumber {
      return min(100, max(0, number.intValue))
    }
    return min(100, max(0, sharedDefault.integer(forKey: key)))
  }
}
