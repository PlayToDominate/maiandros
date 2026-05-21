import Foundation

struct WidgetTripSnapshot: Codable, Equatable {
    let tripName: String
    let destination: String
    let startDate: Date
    let daysUntil: Int
}

enum WidgetSnapshotStore {
    // Keep both likely IDs so local setups keep working without manual edits.
    private static let candidateAppGroupIDs = [
        "group.com.playtodominate.maiandros",
        "group.com.example.Maiandros"
    ]
    static let nextTripKey = "maiandros.widget.nextTrip"

    static func writeNextTrip(_ trip: Trip?) {
        let suites = candidateAppGroupIDs.compactMap { UserDefaults(suiteName: $0) }
        guard !suites.isEmpty else { return }

        guard let trip else {
            suites.forEach { $0.removeObject(forKey: nextTripKey) }
            return
        }

        let snapshot = WidgetTripSnapshot(tripName: trip.name, destination: trip.destination, startDate: trip.startDate, daysUntil: trip.daysUntilDeparture)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        suites.forEach { $0.set(data, forKey: nextTripKey) }
    }
}
