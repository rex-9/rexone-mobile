//
//  MediaDownloadWidgetLiveActivity.swift
//  MediaDownloadWidget
//

import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.1, *)
struct MediaDownloadWidgetLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
      let title = Self.title(from: context.attributes)
      let progress = Self.progress(from: context.attributes)
      let paused = Self.paused(from: context.attributes)
      let assetId = Self.assetId(from: context.attributes)

      VStack(alignment: .leading, spacing: 8) {
        Text(title)
          .font(.headline)
          .lineLimit(2)

        ProgressView(value: Double(progress), total: 100)
          .tint(.accentColor)

        HStack {
          Text(paused ? "Paused · \(progress)%" : "\(progress)%")
            .font(.caption)
            .foregroundStyle(.secondary)

          Spacer()

          if !assetId.isEmpty {
            Self.controlButton(paused: paused, assetId: assetId)
          }
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .activityBackgroundTint(Color(.systemBackground).opacity(0.85))
    } dynamicIsland: { context in
      let title = Self.title(from: context.attributes)
      let progress = Self.progress(from: context.attributes)
      let paused = Self.paused(from: context.attributes)
      let assetId = Self.assetId(from: context.attributes)

      return DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Image(systemName: paused ? "pause.circle.fill" : "arrow.down.circle.fill")
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
            if !assetId.isEmpty {
              Self.controlButton(paused: paused, assetId: assetId)
            }
          }
        }
      } compactLeading: {
        Image(systemName: paused ? "pause.circle.fill" : "arrow.down.circle.fill")
      } compactTrailing: {
        Text("\(progress)%")
          .font(.caption2.monospacedDigit())
      } minimal: {
        Image(systemName: paused ? "pause.circle.fill" : "arrow.down.circle.fill")
      }
      .keylineTint(.accentColor)
    }
  }

  @ViewBuilder
  private static func controlButton(paused: Bool, assetId: String) -> some View {
    if #available(iOSApplicationExtension 17.0, *) {
      Button(
        intent: MediaDownloadControlIntent(
          assetId: assetId,
          action: paused ? "resume" : "pause"
        )
      ) {
        Text(paused ? "Resume" : "Pause")
          .font(.caption.weight(.semibold))
      }
      .buttonStyle(.plain)
    }
  }

  private static var sharedDefaults: UserDefaults? {
    UserDefaults(suiteName: MediaDownloadLiveActivityActionStore.appGroupId)
  }

  private static func title(from attributes: LiveActivitiesAppAttributes) -> String {
    sharedDefaults?.string(forKey: attributes.prefixedKey("title")) ?? "Downloading"
  }

  private static func assetId(from attributes: LiveActivitiesAppAttributes) -> String {
    sharedDefaults?.string(forKey: attributes.prefixedKey("assetId")) ?? ""
  }

  private static func paused(from attributes: LiveActivitiesAppAttributes) -> Bool {
    guard let sharedDefaults else { return false }
    let key = attributes.prefixedKey("paused")
    if let number = sharedDefaults.object(forKey: key) as? NSNumber {
      return number.boolValue
    }
    return sharedDefaults.bool(forKey: key)
  }

  private static func progress(from attributes: LiveActivitiesAppAttributes) -> Int {
    guard let sharedDefaults else { return 0 }
    let key = attributes.prefixedKey("progress")
    if let number = sharedDefaults.object(forKey: key) as? NSNumber {
      return min(100, max(0, number.intValue))
    }
    return min(100, max(0, sharedDefaults.integer(forKey: key)))
  }
}
