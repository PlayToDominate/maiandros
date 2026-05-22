import WidgetKit
import SwiftUI

private struct WidgetTripSnapshot: Codable {
    let tripName: String
    let destination: String
    let startDate: Date
    let daysUntil: Int
}

private enum WidgetSnapshotStore {
    private static let candidateAppGroupIDs = [
        "group.com.playtodominate.maiandros",
        "group.com.example.Maiandros"
    ]
    static let nextTripKey = "maiandros.widget.nextTrip"

    static func loadNextTrip() -> WidgetTripSnapshot? {
        for id in candidateAppGroupIDs {
            if let defaults = UserDefaults(suiteName: id),
               let data = defaults.data(forKey: nextTripKey),
               let snapshot = try? JSONDecoder().decode(WidgetTripSnapshot.self, from: data) {
                return snapshot
            }
        }
        return nil
    }
}

struct MaiandrosCountdownEntry: TimelineEntry {
    let date: Date
    let tripName: String
    let destination: String
    let daysUntil: Int
    let hasSnapshot: Bool
}

struct MaiandrosCountdownProvider: TimelineProvider {
    func placeholder(in context: Context) -> MaiandrosCountdownEntry {
        MaiandrosCountdownEntry(date: Date(), tripName: "Kauai", destination: "Kauai", daysUntil: 43, hasSnapshot: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (MaiandrosCountdownEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MaiandrosCountdownEntry>) -> Void) {
        let entry: MaiandrosCountdownEntry

        if let snapshot = WidgetSnapshotStore.loadNextTrip() {
            let computedDays = max(0, Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: snapshot.startDate)).day ?? 0)
            entry = MaiandrosCountdownEntry(
                date: Date(),
                tripName: snapshot.tripName,
                destination: snapshot.destination,
                daysUntil: computedDays,
                hasSnapshot: true
            )
        } else {
            entry = MaiandrosCountdownEntry(date: Date(), tripName: "No Trips Yet", destination: "Open Maiandros to sync", daysUntil: 0, hasSnapshot: false)
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
        .contentMarginsDisabled()
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
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Spacer()
                    Image("MeanderWidget")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 34, height: 34)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                Spacer(minLength: 2)

                if entry.hasSnapshot && entry.daysUntil == 0 {
                    Text("Today is the day")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(red: 0.22, green: 0.18, blue: 0.14))
                        .minimumScaleFactor(0.7)
                    Text("Meander says: time to wander.")
                        .font(.footnote)
                        .foregroundStyle(Color(red: 0.37, green: 0.31, blue: 0.24))
                        .lineLimit(2)
                } else {
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

                if !entry.hasSnapshot {
                    Text("Open the app once to sync trips.")
                        .font(.caption2)
                        .foregroundStyle(Color(red: 0.45, green: 0.36, blue: 0.27))
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.96, blue: 0.87),
                    Color(red: 0.97, green: 0.90, blue: 0.76)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

#Preview(as: .systemSmall) {
    MaiandrosCountdownWidget()
} timeline: {
    MaiandrosCountdownEntry(date: .now, tripName: "Kauai", destination: "Kauai", daysUntil: 43, hasSnapshot: true)
}
