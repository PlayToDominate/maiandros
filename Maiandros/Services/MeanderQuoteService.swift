import Foundation

enum MeanderQuoteContext {
    case homeEmpty
    case homeActiveTrips
    case countdown
    case checklist
    case packing
    case cabinet
    case tripAlbum
    case upcomingTask
    case completeTask
    case tripFarAway
    case tripWithin30
    case tripWithin7
    case tripTomorrowOrToday
    case postTripNostalgia
}

enum MeanderQuoteService {
    static func line(for context: MeanderQuoteContext, daysUntil: Int? = nil, seed: String = "") -> String {
        let bucket: [String]

        switch context {
        case .homeEmpty:
            bucket = [
                "No trips yet. Meander is quietly waiting by the door.",
                "When you're ready to wander, Meander is already mentally at the airport.",
                "A tiny start is still a start."
            ]
        case .homeActiveTrips:
            bucket = [
                "Meander says: little steps now, easier travel later.",
                "Tiny hoof reminder: one small step is still a step.",
                "You're making room for the fun part."
            ]
        case .countdown:
            bucket = [
                "Meander is already mentally at the airport.",
                "Almost time to wander.",
                "This trip is starting to feel real in the best way."
            ]
        case .checklist:
            bucket = [
                "One gentle step, then another.",
                "No rush. Just less mental clutter.",
                "One less thing wandering around your brain."
            ]
        case .packing:
            bucket = [
                "The cow believes in you. Also maybe pack socks.",
                "The suitcase is starting to look suspicious.",
                "Future-you just sent a thank-you moo."
            ]
        case .cabinet:
            bucket = [
                "Meander tucked this away for later.",
                "Saved safely, so your brain can rest.",
                "One less loose thread to carry around."
            ]
        case .tripAlbum:
            bucket = [
                "Tiny moments count too.",
                "A little travel scrapbook is forming.",
                "These are the soft edges of the trip."
            ]
        case .upcomingTask:
            bucket = [
                "This one can be your next tiny win.",
                "Gentle nudge from Meander.",
                "Not urgent, just worth a small step soon."
            ]
        case .completeTask:
            bucket = [
                "Nicely done. That's out of your head now.",
                "One less thing to carry.",
                "Meander did a tiny proud nod."
            ]
        case .tripFarAway:
            bucket = [
                "Plenty of runway. Cozy planning is perfect here.",
                "No sprinting needed yet.",
                "Long-horizon trips love slow, kind prep."
            ]
        case .tripWithin30:
            bucket = [
                "This is the sweet spot for light prep.",
                "A little attention now goes a long way.",
                "Meander is keeping the loose pieces together."
            ]
        case .tripWithin7:
            bucket = [
                "Final-week energy: calm and simple.",
                "You've done the hard part. Now just tidy edges.",
                "Meander packed snacks and encouragement."
            ]
        case .tripTomorrowOrToday:
            bucket = [
                "Breathe first. Wander second.",
                "Today/tomorrow mode: essentials, then joy.",
                "Meander is practically at the gate."
            ]
        case .postTripNostalgia:
            bucket = [
                "That trip glow lasts a little while.",
                "Past wanderings, neatly tucked away.",
                "A small postcard from your recent self."
            ]
        }

        return pick(from: bucket, seed: "\(context)-\(daysUntil ?? -1)-\(seed)")
    }

    static func timelineLine(daysUntil: Int, seed: String = "") -> String {
        if daysUntil <= 1 { return line(for: .tripTomorrowOrToday, daysUntil: daysUntil, seed: seed) }
        if daysUntil <= 7 { return line(for: .tripWithin7, daysUntil: daysUntil, seed: seed) }
        if daysUntil <= 30 { return line(for: .tripWithin30, daysUntil: daysUntil, seed: seed) }
        return line(for: .tripFarAway, daysUntil: daysUntil, seed: seed)
    }

    static func departureDayTitle(seed: String = "") -> String {
        pick(from: departureTitles, seed: "departure-title-\(seed)")
    }

    static func departureDaySubtitle(seed: String = "") -> String {
        pick(from: departureSubtitles, seed: "departure-subtitle-\(seed)")
    }

    private static func pick(from lines: [String], seed: String) -> String {
        guard !lines.isEmpty else { return "" }
        let daySeed = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        let hashValue = abs((seed + "-\(daySeed)").hashValue)
        return lines[hashValue % lines.count]
    }

    private static let departureTitles: [String] = [
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

    private static let departureSubtitles: [String] = [
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
}
