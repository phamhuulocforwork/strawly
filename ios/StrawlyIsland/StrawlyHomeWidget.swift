import SwiftUI
import WidgetKit

let homeWidgetKind = "StrawlyHomeWidget"

struct CycleWidgetEntry: TimelineEntry {
  let date: Date
  let phaseKey: String
  let phaseLabel: String
  let digit: String
}

struct CycleWidgetProvider: TimelineProvider {
  func placeholder(in context: Context) -> CycleWidgetEntry {
    CycleWidgetEntry(
      date: Date(),
      phaseKey: "follicular",
      phaseLabel: "Follicular",
      digit: "12"
    )
  }

  func getSnapshot(
    in context: Context,
    completion: @escaping (CycleWidgetEntry) -> Void
  ) {
    completion(loadEntries().first ?? placeholder(in: context))
  }

  func getTimeline(
    in context: Context,
    completion: @escaping (Timeline<CycleWidgetEntry>) -> Void
  ) {
    completion(Timeline(entries: loadEntries(), policy: .atEnd))
  }

  private func fallbackEntry() -> CycleWidgetEntry {
    CycleWidgetEntry(
      date: Date(),
      phaseKey: "none",
      phaseLabel: "",
      digit: "—"
    )
  }

  /// Reads the day-by-day timeline written by the Flutter app and turns it
  /// into one WidgetKit entry per day, so the widget rolls over at midnight
  /// without needing the app to be opened.
  private func loadEntries() -> [CycleWidgetEntry] {
    guard
      let raw = sharedDefault.string(forKey: "widget_timeline"),
      let data = raw.data(using: .utf8),
      let decoded = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
      !decoded.isEmpty
    else {
      return [fallbackEntry()]
    }

    let entries: [CycleWidgetEntry] = decoded.compactMap { item in
      guard let millis = (item["d"] as? NSNumber)?.doubleValue else { return nil }
      return CycleWidgetEntry(
        date: Date(timeIntervalSince1970: millis / 1000),
        phaseKey: item["k"] as? String ?? "none",
        phaseLabel: item["l"] as? String ?? "",
        digit: item["n"] as? String ?? "—"
      )
    }

    let today = Calendar.current.startOfDay(for: Date())
    let remaining = entries.filter { $0.date >= today }
    guard remaining.isEmpty else { return remaining }

    // Timeline is stale (app not opened for > horizon). Only keep the last
    // entry if it is close enough to today; otherwise show the empty state.
    guard let last = entries.last else { return [fallbackEntry()] }
    let daysOld = Calendar.current.dateComponents([.day], from: last.date, to: today).day ?? .max
    return daysOld <= 3 ? [last] : [fallbackEntry()]
  }
}

struct StrawlyHomeWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: homeWidgetKind, provider: CycleWidgetProvider()) { entry in
      StrawlyHomeWidgetView(entry: entry)
        .widgetBackground()
    }
    .configurationDisplayName("Strawly")
    .description("Current cycle phase and days.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

struct StrawlyHomeWidgetView: View {
  @Environment(\.widgetFamily) private var family
  let entry: CycleWidgetEntry

  var body: some View {
    if family == .systemMedium {
      mediumView
    } else {
      smallView
    }
  }

  private var smallView: some View {
    VStack(spacing: 4) {
      sticker(size: 44)
      Text(entry.phaseLabel)
        .font(.footnote.weight(.semibold))
        .lineLimit(1)
        .minimumScaleFactor(0.7)
      Text(entry.digit)
        .font(.title.bold())
        .monospacedDigit()
    }
    .padding(8)
  }

  private var mediumView: some View {
    HStack(spacing: 12) {
      sticker(size: 40)
      Text(entry.phaseLabel)
        .font(.headline)
        .lineLimit(1)
      Spacer()
      Text(entry.digit)
        .font(.title.bold())
        .monospacedDigit()
    }
    .padding(.horizontal, 4)
  }

  private func sticker(size: CGFloat) -> some View {
    Image(stickerName)
      .resizable()
      .scaledToFit()
      .frame(width: size, height: size)
  }

  private var stickerName: String {
    switch entry.phaseKey {
    case "period": return "sticker_period"
    case "fertile": return "sticker_fertile"
    case "luteal": return "sticker_luteal"
    default: return "sticker_follicular"
    }
  }
}

private extension View {
  @ViewBuilder
  func widgetBackground() -> some View {
    if #available(iOSApplicationExtension 17.0, *) {
      containerBackground(for: .widget) { Color(.systemBackground) }
    } else {
      background(Color(.systemBackground))
    }
  }
}
