import Foundation

@MainActor
final class TripStore: ObservableObject {
    @Published var trips: [Trip] = [] {
        didSet { save() }
    }

    private let saveURL: URL

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.saveURL = docs.appendingPathComponent("maiandros-trips.json")
        self.trips = load()
    }

    func addTrip(name: String, destination: String, startDate: Date, endDate: Date, mode: TravelMode) {
        let checklist = Self.defaultChecklist(startDate: startDate, endDate: endDate)
        let packing = Self.defaultPacking(destination: destination, startDate: startDate)
        let trip = Trip(name: name, destination: destination, startDate: startDate, endDate: endDate, travelMode: mode, checklist: checklist, packing: packing)
        trips.append(trip)
    }

    func update(_ trip: Trip) {
        guard let index = trips.firstIndex(where: { $0.id == trip.id }) else { return }
        trips[index] = trip
    }

    private func load() -> [Trip] {
        guard let data = try? Data(contentsOf: saveURL) else { return [] }
        return (try? JSONDecoder().decode([Trip].self, from: data)) ?? []
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(trips) else { return }
        try? data.write(to: saveURL, options: [.atomic])
    }

    private static func defaultChecklist(startDate: Date, endDate: Date) -> [ChecklistItem] {
        let requiredPassportDate = Calendar.current.date(byAdding: .month, value: 6, to: endDate) ?? endDate
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        let daysToTrip = Calendar.current.dateComponents([.day], from: .now.startOfDay, to: startDate.startOfDay).day ?? 0
        let flightStatus: ChecklistStatus = daysToTrip > 90 ? .upcoming : .needsAction

        return [
            ChecklistItem(title: "Verify Passport", detail: "Valid through at least \(formatter.string(from: requiredPassportDate)).", status: .needsAction),
            ChecklistItem(title: "Book Flights", detail: flightStatus == .upcoming ? "Tiny goblin reminder: flights are usually cheapest around now in a few weeks ✈️" : "Booking window is open.", status: flightStatus),
            ChecklistItem(title: "Book Lodging", detail: "Find a cozy place to land each night.", status: .needsAction),
            ChecklistItem(title: "Book Transportation", detail: "Rental car, train, shuttle, or skip if not needed.", status: .inProgress, canSkip: true),
            ChecklistItem(title: "Packing List", detail: "Start with essentials; add special items as you wander.", status: .inProgress),
            ChecklistItem(title: "Home Preparation", detail: "Mail, plants, chargers, and one last goblin walk-through.", status: .upcoming)
        ]
    }

    private static func defaultPacking(destination: String, startDate: Date) -> [PackingItem] {
        let month = Calendar.current.component(.month, from: startDate)
        let coldSeason = month <= 3 || month >= 11
        var base = ["Passport/ID", "Phone charger", "Medications", "Socks", "Toiletries", "Comfy outfit"]
        if destination.lowercased().contains("beach") {
            base += ["Swimsuit", "Sunscreen"]
        }
        if coldSeason {
            base += ["Warm layer", "Jacket"]
        }
        return base.map { PackingItem(name: $0) }
    }
}
