import Foundation

struct WidgetTripSnapshot: Codable, Equatable {
    let tripName: String
    let destination: String
    let startDate: Date
    let daysUntil: Int
}

enum WidgetSnapshotStore {
    // TODO: Replace with your production App Group in both app + widget targets.
    static let appGroupID = "group.com.playtodominate.maiandros"
    static let nextTripKey = "maiandros.widget.nextTrip"

    static func writeNextTrip(_ trip: Trip?) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }

        guard let trip else {
            defaults.removeObject(forKey: nextTripKey)
            return
        }

        let snapshot = WidgetTripSnapshot(
            tripName: trip.name,
            destination: trip.destination,
            startDate: trip.startDate,
            daysUntil: trip.daysUntilDeparture
        )

        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: nextTripKey)
    }
}
