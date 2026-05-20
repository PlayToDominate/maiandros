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

    func addTrip(name: String, destination: String, reason: TripReason, startDate: Date, endDate: Date, mode: TravelMode) {
        let checklist = Self.defaultChecklist(destination: destination, startDate: startDate, endDate: endDate)
        let packing = Self.defaultPacking(destination: destination, startDate: startDate)
        let homePreparation = Self.defaultHomePreparation()
        let trip = Trip(name: name, destination: destination, reason: reason, startDate: startDate, endDate: endDate, travelMode: mode, checklist: checklist, packing: packing, homePreparation: homePreparation)
        trips.append(trip)
    }

    func update(_ trip: Trip) {
        guard let index = trips.firstIndex(where: { $0.id == trip.id }) else { return }
        trips[index] = trip
    }

    func deleteTrip(id: UUID) {
        trips.removeAll { $0.id == id }
    }

    private func load() -> [Trip] {
        guard let data = try? Data(contentsOf: saveURL) else { return [] }
        let decoded = (try? JSONDecoder().decode([Trip].self, from: data)) ?? []
        return decoded.map { trip in
            var updated = trip
            if updated.homePreparation.isEmpty {
                updated.homePreparation = Self.defaultHomePreparation()
            }
            return updated
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(trips) else { return }
        try? data.write(to: saveURL, options: [.atomic])
    }

    private static func defaultChecklist(destination: String, startDate: Date, endDate: Date) -> [ChecklistItem] {
        let requiredPassportDate = Calendar.current.date(byAdding: .month, value: 6, to: endDate) ?? endDate
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let isDomesticUS = isLikelyUSDomesticDestination(destination)

        let daysToTrip = Calendar.current.dateComponents([.day], from: .now.startOfDay, to: startDate.startOfDay).day ?? 0
        let flightStatus: ChecklistStatus = daysToTrip > 90 ? .upcoming : .needsAction

        let passportStatus: ChecklistStatus = isDomesticUS ? .skipped : .needsAction
        let passportDetail: String = isDomesticUS
            ? "Meander checked: no passport needed for this U.S. trip."
            : "Valid through at least \(formatter.string(from: requiredPassportDate))."

        return [
            ChecklistItem(title: "Verify Passport", detail: passportDetail, status: passportStatus, canSkip: true),
            ChecklistItem(title: "Book Flights", detail: flightStatus == .upcoming ? "Tiny hoof reminder: flights are often friendlier around this window ✈️" : "Booking window is open.", status: flightStatus),
            ChecklistItem(title: "Book Lodging", detail: "Find a cozy place to land each night.", status: .needsAction),
            ChecklistItem(title: "Book Transportation", detail: "Rental car, train, shuttle, or skip if not needed.", status: .inProgress, canSkip: true),
            ChecklistItem(title: "Packing List", detail: "Start with essentials; add special items as you wander.", status: .inProgress),
            ChecklistItem(title: "Home Preparation", detail: "Mail, plants, chargers, and one last Meander walk-through.", status: .upcoming)
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

    private static func defaultHomePreparation() -> [HomePrepItem] {
        [
            HomePrepItem(name: "Hold mail"),
            HomePrepItem(name: "Pet sitter / pet care"),
            HomePrepItem(name: "Adjust thermostat"),
            HomePrepItem(name: "Take out trash"),
            HomePrepItem(name: "Water plants"),
            HomePrepItem(name: "Pack chargers"),
            HomePrepItem(name: "Unplug non-essential appliances")
        ]
    }

    private static func isLikelyUSDomesticDestination(_ destination: String) -> Bool {
        let lowered = destination.lowercased()
        let directUSMatches = [
            "usa", "u.s.a", "united states", "us ", " u.s.", "america",
            "new york", "nyc", "los angeles", "chicago", "san francisco", "seattle", "austin", "miami", "boston"
        ]
        if directUSMatches.contains(where: { lowered.contains($0) }) {
            return true
        }

        let stateCodes = [
            "al","ak","az","ar","ca","co","ct","de","fl","ga","hi","id","il","in","ia","ks","ky","la","me","md",
            "ma","mi","mn","ms","mo","mt","ne","nv","nh","nj","nm","ny","nc","nd","oh","ok","or","pa","ri","sc",
            "sd","tn","tx","ut","vt","va","wa","wv","wi","wy","dc"
        ]
        for code in stateCodes {
            if lowered.contains(", \(code)") || lowered.hasSuffix(" \(code)") {
                return true
            }
        }
        return false
    }
}
