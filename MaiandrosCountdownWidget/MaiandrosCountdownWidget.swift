import WidgetKit
import SwiftUI

private enum WidgetDepartureCopy {
    static func title(seed: String = "", compact: Bool) -> String {
        let bucket = compact ? compactTitles : titles
        return pick(from: bucket, seed: "widget-depart-title-\(seed)-\(compact)")
    }

    static func subtitle(seed: String = "", compact: Bool) -> String {
        let bucket = compact ? compactSubtitles : subtitles
        return pick(from: bucket, seed: "widget-depart-subtitle-\(seed)-\(compact)")
    }

    private static func pick(from lines: [String], seed: String) -> String {
        guard !lines.isEmpty else { return "" }
        let daySeed = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        let hashValue = abs((seed + "-\(daySeed)").hashValue)
        return lines[hashValue % lines.count]
    }

    private static let titles: [String] = [
        "Take lots of pictures",
        "Time to wander",
        "Safe travels",
        "Today's the day",
        "Off you go",
        "Adventure starts today",
        "The waiting part is over",
        "Go make some memories",
        "Hope this trip feels good",
        "Tiny adventures await",
        "Wheels up soon",
        "Your trip starts now",
        "Wander well",
        "The bags are packed",
        "Time for a change of scenery",
        "Go see something beautiful",
        "Let the wandering begin",
        "Ready or not, here comes the airport",
        "The cozy countdown is complete",
        "This one's finally happening",
        "The trip is officially real now",
        "Departure day has arrived",
        "The passport era begins",
        "You made it to travel day",
        "Time to collect little memories",
        "May your snacks survive TSA",
        "Your future memories are loading",
        "One last deep breath",
        "Airport mode activated",
        "Today belongs to wandering",
        "This chapter starts today",
        "Hope the window seat energy is strong",
        "Time to leave ordinary behind",
        "Your getaway begins today",
        "Go find some postcard moments",
        "The adventure shoes are on",
        "The suitcase has fulfilled its destiny",
        "Time to chase a little joy",
        "Go make future-you nostalgic"
    ]

    private static let subtitles: [String] = [
        "Meander hopes this becomes a favorite memory.",
        "Future-you will love looking back on this.",
        "Tiny memories count too.",
        "Meander double-checked the snacks.",
        "Meander is emotionally already at the gate.",
        "Hope the airport coffee is decent.",
        "Meander believes you remembered the charger.",
        "The suitcase is looking very official now.",
        "Tiny hoof reminder: breathe and enjoy it.",
        "Meander packed emotional support socks.",
        "The little moments matter too.",
        "Meander can't wait to hear about this one.",
        "Take pictures of the weird little things too.",
        "One less thing wandering around your brain.",
        "Meander says this trip already feels special.",
        "Tiny hoof reminder: you don't have to rush.",
        "Meander recommends a cozy travel playlist.",
        "The wandering officially begins now.",
        "Meander thinks this one will make good stories.",
        "Don't forget to look out the window sometimes.",
        "Hope something unexpectedly wonderful happens.",
        "Meander packed extra cozy energy for you.",
        "Today feels like a memory in the making.",
        "The cow believes in you. Also maybe snacks.",
        "May your gate be nearby and your seat comfortable.",
        "Meander says the best trips leave room for wandering.",
        "Tiny hoof reminder: not every good moment needs a plan.",
        "Meander hopes you find at least one place you want to revisit someday.",
        "Future-you is already grateful you took this trip.",
        "Meander thinks the tiny moments become the biggest memories.",
        "Hope the weather behaves itself.",
        "Meander says to take the scenic route if you can.",
        "The adventure officially left the group chat phase.",
        "Meander is ready for cozy travel chaos.",
        "Tiny hoof reminder: chargers first, panic second.",
        "Hope you find a really good breakfast spot.",
        "Meander recommends leaving room for surprises.",
        "Some memories sneak up on you quietly.",
        "Meander says wandering counts as productivity today.",
        "Tiny hoof reminder: the trip already started the moment you got excited about it."
    ]

    private static let compactTitles: [String] = [
        "Today's the day",
        "Time to wander",
        "Safe travels",
        "Off you go",
        "Airport mode on",
        "Trip day is here",
        "Adventure starts"
    ]

    private static let compactSubtitles: [String] = [
        "Meander is gate-ready.",
        "Tiny memories count too.",
        "Breathe, then wander.",
        "Snacks? Charger? Joy?",
        "Future-you says thanks."
    ]
}

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
    @Environment(\.widgetFamily) private var family
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
                    if entry.hasSnapshot && entry.daysUntil == 0 {
                        Text("On Vacation")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color(red: 0.35, green: 0.28, blue: 0.20))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.55))
                            .clipShape(Capsule())
                    }
                    Spacer()
                    Image("MeanderWidget")
                        .resizable()
                        .scaledToFill()
                        .frame(width: avatarSize, height: avatarSize)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                Spacer(minLength: 2)

                if entry.hasSnapshot && entry.daysUntil == 0 {
                    Text(WidgetDepartureCopy.title(seed: entry.tripName, compact: family == .systemSmall))
                        .font(.system(size: titleFontSize, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(red: 0.22, green: 0.18, blue: 0.14))
                        .minimumScaleFactor(0.50)
                        .lineLimit(family == .systemMedium ? 2 : 2)
                    Text(WidgetDepartureCopy.subtitle(seed: entry.tripName, compact: family == .systemSmall))
                        .font(subtitleFont)
                        .foregroundStyle(Color(red: 0.37, green: 0.31, blue: 0.24))
                        .lineLimit(family == .systemMedium ? 2 : 2)
                } else {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(entry.daysUntil)")
                            .font(.system(size: countFontSize, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color(red: 0.22, green: 0.18, blue: 0.14))
                            .minimumScaleFactor(0.55)
                        Text("days")
                            .font(daysLabelFont)
                            .foregroundStyle(Color(red: 0.43, green: 0.35, blue: 0.26))
                    }

                    Text(entry.tripName == "No Trips Yet" ? "Start planning your next wander." : "until \(entry.destination)")
                        .font(subtitleFont)
                        .foregroundStyle(Color(red: 0.37, green: 0.31, blue: 0.24))
                        .lineLimit(family == .systemMedium ? 2 : 3)
                }

                if !entry.hasSnapshot {
                    Text("Open the app once to sync trips.")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color(red: 0.45, green: 0.36, blue: 0.27))
                        .lineLimit(2)
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

    private var avatarSize: CGFloat {
        family == .systemMedium ? 38 : 34
    }

    private var countFontSize: CGFloat {
        family == .systemMedium ? 58 : 52
    }

    private var titleFontSize: CGFloat {
        family == .systemMedium ? 26 : 20
    }

    private var subtitleFont: Font {
        family == .systemMedium ? .footnote : .caption
    }

    private var daysLabelFont: Font {
        family == .systemMedium ? .headline.weight(.semibold) : .subheadline.weight(.semibold)
    }
}

#Preview(as: .systemSmall) {
    MaiandrosCountdownWidget()
} timeline: {
    MaiandrosCountdownEntry(date: .now, tripName: "Kauai", destination: "Kauai", daysUntil: 43, hasSnapshot: true)
}
