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

    private static func pick(from lines: [String], seed: String) -> String {
        guard !lines.isEmpty else { return "" }
        let daySeed = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        let hashValue = abs((seed + "-\(daySeed)").hashValue)
        return lines[hashValue % lines.count]
    }
}
