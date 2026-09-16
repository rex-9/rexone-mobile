//
//  MediaDownloadWidgetBundle.swift
//  MediaDownloadWidget
//

import SwiftUI
import WidgetKit

@main
struct MediaDownloadWidgetBundle: WidgetBundle {
  var body: some Widget {
    if #available(iOSApplicationExtension 16.1, *) {
      MediaDownloadWidgetLiveActivity()
    }
  }
}
