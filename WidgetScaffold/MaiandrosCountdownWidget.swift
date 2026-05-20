import WidgetKit
import SwiftUI

struct MaiandrosCountdownEntry: TimelineEntry {
    let date: Date
    let tripName: String
    let destination: String
    let daysUntil: Int
}

struct MaiandrosCountdownProvider: TimelineProvider {
    func placeholder(in context: Context) -> MaiandrosCountdownEntry {
        MaiandrosCountdownEntry(date: Date(), tripName: "Kauai", destination: "Kauai", daysUntil: 43)
    }

    func getSnapshot(in context: Context, completion: @escaping (MaiandrosCountdownEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MaiandrosCountdownEntry>) -> Void) {
        // TODO: Read next trip from shared App Group store (see WidgetScaffold/README.md).
        let entry = placeholder(in: context)
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date().addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}

struct MaiandrosCountdownWidgetView: View {
    var entry: MaiandrosCountdownProvider.Entry

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.99, green: 0.96, blue: 0.90), Color(red: 0.98, green: 0.92, blue: 0.82)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 6) {
                Text("Maiandros")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text("\(entry.daysUntil)")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                Text("days until \(entry.destination)")
                    .font(.footnote)
                    .lineLimit(2)
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .containerBackground(.clear, for: .widget)
    }
}

struct MaiandrosCountdownWidget: Widget {
    let kind: String = "MaiandrosCountdownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MaiandrosCountdownProvider()) { entry in
            MaiandrosCountdownWidgetView(entry: entry)
        }
        .configurationDisplayName("Trip Countdown")
        .description("Shows days until your next Maiandros trip.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    MaiandrosCountdownWidget()
} timeline: {
    MaiandrosCountdownEntry(date: .now, tripName: "Kauai", destination: "Kauai", daysUntil: 43)
}
