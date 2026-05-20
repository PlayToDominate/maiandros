import WidgetKit
import SwiftUI

private struct WidgetTripSnapshot: Codable {
    let tripName: String
    let destination: String
    let startDate: Date
    let daysUntil: Int
}

private enum WidgetSnapshotStore {
    static let appGroupID = "group.com.playtodominate.maiandros"
    static let nextTripKey = "maiandros.widget.nextTrip"

    static func loadNextTrip() -> WidgetTripSnapshot? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: nextTripKey) else { return nil }
        return try? JSONDecoder().decode(WidgetTripSnapshot.self, from: data)
    }
}

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
        let entry: MaiandrosCountdownEntry

        if let snapshot = WidgetSnapshotStore.loadNextTrip() {
            entry = MaiandrosCountdownEntry(
                date: Date(),
                tripName: snapshot.tripName,
                destination: snapshot.destination,
                daysUntil: max(0, snapshot.daysUntil)
            )
        } else {
            entry = MaiandrosCountdownEntry(date: Date(), tripName: "No Trips Yet", destination: "somewhere cozy", daysUntil: 0)
        }

        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date().addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
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

struct MaiandrosCountdownWidgetView: View {
    var entry: MaiandrosCountdownEntry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.96, blue: 0.87),
                    Color(red: 0.97, green: 0.90, blue: 0.76)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Maiandros")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(red: 0.44, green: 0.35, blue: 0.25))
                    Spacer()
                    Text("Meander 🐮")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color(red: 0.50, green: 0.36, blue: 0.24))
                }

                Spacer(minLength: 2)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(entry.daysUntil)")
                        .font(.system(size: 54, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(red: 0.22, green: 0.18, blue: 0.14))
                        .minimumScaleFactor(0.7)
                    Text("days")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color(red: 0.43, green: 0.35, blue: 0.26))
                }

                Text(entry.tripName == "No Trips Yet" ? "Start planning your next wander." : "until \(entry.destination)")
                    .font(.footnote)
                    .foregroundStyle(Color(red: 0.37, green: 0.31, blue: 0.24))
                    .lineLimit(2)
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .containerBackground(.clear, for: .widget)
    }
}

#Preview(as: .systemSmall) {
    MaiandrosCountdownWidget()
} timeline: {
    MaiandrosCountdownEntry(date: .now, tripName: "Kauai", destination: "Kauai", daysUntil: 43)
}
