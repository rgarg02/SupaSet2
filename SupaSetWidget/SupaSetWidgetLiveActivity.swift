//
//  SupaSetWidgetLiveActivity.swift
//  SupaSetWidget
//
//  Created by Rishi Garg on 11/8/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct SupaSetWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct SupaSetWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SupaSetWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension SupaSetWidgetAttributes {
    fileprivate static var preview: SupaSetWidgetAttributes {
        SupaSetWidgetAttributes(name: "World")
    }
}

extension SupaSetWidgetAttributes.ContentState {
    fileprivate static var smiley: SupaSetWidgetAttributes.ContentState {
        SupaSetWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: SupaSetWidgetAttributes.ContentState {
         SupaSetWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: SupaSetWidgetAttributes.preview) {
   SupaSetWidgetLiveActivity()
} contentStates: {
    SupaSetWidgetAttributes.ContentState.smiley
    SupaSetWidgetAttributes.ContentState.starEyes
}
