import ActivityKit
import SwiftUI
import WidgetKit

@main
struct StrawlyIslandBundle: WidgetBundle {
  var body: some Widget {
    if #available(iOS 16.1, *) {
      StrawlyIslandLiveActivity()
    }
  }
}

struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
  public typealias LiveDeliveryData = ContentState

  public struct ContentState: Codable, Hashable {}

  var id = UUID()
}

let sharedDefault = UserDefaults(suiteName: "group.com.example.strawly")!

@available(iOSApplicationExtension 16.1, *)
struct StrawlyIslandLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
      islandContent(context: context)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Text("🍓")
            .font(.title2)
        }
        DynamicIslandExpandedRegion(.trailing) {
          Text(readString(context, key: "compactDigit"))
            .font(.title2.bold())
            .monospacedDigit()
        }
        DynamicIslandExpandedRegion(.bottom) {
          VStack(alignment: .leading, spacing: 4) {
            Text(readString(context, key: "phaseLabel"))
              .font(.subheadline.weight(.semibold))
            if let predicted = readPredictedDate(context) {
              Text(predicted)
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
          }
        }
      } compactLeading: {
        Text("🍓")
          .font(.caption)
      } compactTrailing: {
        Text(readString(context, key: "compactDigit"))
          .font(.caption.bold())
          .monospacedDigit()
      } minimal: {
        Text("🍓")
          .font(.caption2)
      }
    }
  }

  @ViewBuilder
  private func islandContent(context: ActivityViewContext<LiveActivitiesAppAttributes>) -> some View {
    HStack(spacing: 12) {
      Text("🍓")
        .font(.title)
      VStack(alignment: .leading, spacing: 2) {
        Text(readString(context, key: "phaseLabel"))
          .font(.headline)
        if let predicted = readPredictedDate(context) {
          Text(predicted)
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
      }
      Spacer()
      Text(readString(context, key: "compactDigit"))
        .font(.title.bold())
        .monospacedDigit()
    }
  }

  private func readString(
    _ context: ActivityViewContext<LiveActivitiesAppAttributes>,
    key: String
  ) -> String {
    sharedDefault.string(forKey: context.attributes.prefixedKey(key)) ?? "—"
  }

  private func readPredictedDate(
    _ context: ActivityViewContext<LiveActivitiesAppAttributes>
  ) -> String? {
    let ms = sharedDefault.double(forKey: context.attributes.prefixedKey("predictedDateMs"))
    guard ms > 0 else { return nil }
    let date = Date(timeIntervalSince1970: ms / 1000)
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter.string(from: date)
  }
}

extension LiveActivitiesAppAttributes {
  func prefixedKey(_ key: String) -> String {
    return "\(id)_\(key)"
  }
}
