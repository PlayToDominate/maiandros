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
}

enum MeanderQuoteService {
    static func line(for context: MeanderQuoteContext, daysUntil: Int? = nil, seed: String = "") -> String {
        let bucket: [String]

        switch context {
        case .homeEmpty:
            bucket = [
                "Meander is ready whenever your next wander appears.",
                "No trips yet. That just means fresh adventures are still simmering.",
                "Soft nudge from Meander: planning can start tiny."
            ]
        case .homeActiveTrips:
            bucket = [
                "Meander says: little steps now, easier travel later.",
                "Your future self is quietly cheering for this prep.",
                "Tiny hoof reminder: one small step is still a step."
            ]
        case .countdown:
            bucket = [
                "Meander is already daydreaming about this one.",
                "Almost time to wander.",
                "This trip is warming up nicely."
            ]
        case .checklist:
            bucket = [
                "One gentle checkbox at a time.",
                "No rush, no panic. Meander likes steady progress.",
                "One less thing moving around in your brain."
            ]
        case .packing:
            bucket = [
                "The cow believes in you. Also maybe pack socks.",
                "Your suitcase is starting to look suspiciously organized.",
                "Pack calm now, thank yourself later."
            ]
        case .cabinet:
            bucket = [
                "Meander tucked this away for later.",
                "Cabinet mode: safely stashing brain clutter.",
                "Saved. One fewer loose thought to carry."
            ]
        case .tripAlbum:
            bucket = [
                "Tiny moments count too.",
                "Trip memories, neatly corralled.",
                "Meander likes these breadcrumbs."
            ]
        case .upcomingTask:
            bucket = [
                "A gentle nudge for your next step.",
                "This one can wait, but not forever.",
                "Meander circled this so you don't have to hold it in your head."
            ]
        case .completeTask:
            bucket = [
                "Done and dusted. Nicely handled.",
                "That task is fully out of your mental backpack.",
                "Meander approves this tidy win."
            ]
        case .tripFarAway:
            bucket = [
                "Plenty of runway. Cozy planning mode is perfect.",
                "Far-away trip energy: light prep, low stress.",
                "No need to sprint yet."
            ]
        case .tripWithin30:
            bucket = [
                "Now we're in the useful prep window.",
                "A little focus now will feel great later.",
                "Meander has entered friendly reminder mode."
            ]
        case .tripWithin7:
            bucket = [
                "Final stretch. Keep it simple and kind.",
                "This week is for calm finishing touches.",
                "You've got this. Meander is on snack-and-checklist duty."
            ]
        case .tripTomorrowOrToday:
            bucket = [
                "It's go-time. Breathe first, then wander.",
                "Today/tomorrow energy: essentials, then excitement.",
                "Meander did a tiny happy spin for this."
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
