import Foundation

enum TravelMode: String, Codable, CaseIterable, Identifiable, Equatable {
    case flying
    case driving

    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

enum ChecklistStatus: String, Codable, CaseIterable, Equatable {
    case needsAction
    case upcoming
    case inProgress
    case complete
    case skipped

    var label: String {
        switch self {
        case .needsAction: return "Needs Action"
        case .upcoming: return "Upcoming"
        case .inProgress: return "In Progress"
        case .complete: return "Complete"
        case .skipped: return "Optional/Skipped"
        }
    }
}

struct ChecklistItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var detail: String
    var status: ChecklistStatus
    var canSkip: Bool

    init(id: UUID = UUID(), title: String, detail: String, status: ChecklistStatus, canSkip: Bool = false) {
        self.id = id
        self.title = title
        self.detail = detail
        self.status = status
        self.canSkip = canSkip
    }
}

struct PackingItem: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var isPacked: Bool

    init(id: UUID = UUID(), name: String, isPacked: Bool = false) {
        self.id = id
        self.name = name
        self.isPacked = isPacked
    }
}

struct CabinetEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var text: String
    var tags: [String]
    var createdAt: Date

    init(id: UUID = UUID(), text: String, tags: [String], createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.tags = tags
        self.createdAt = createdAt
    }
}

struct Trip: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var destination: String
    var startDate: Date
    var endDate: Date
    var travelMode: TravelMode
    var checklist: [ChecklistItem]
    var packing: [PackingItem]
    var cabinet: [CabinetEntry]

    init(
        id: UUID = UUID(),
        name: String,
        destination: String,
        startDate: Date,
        endDate: Date,
        travelMode: TravelMode,
        checklist: [ChecklistItem] = [],
        packing: [PackingItem] = [],
        cabinet: [CabinetEntry] = []
    ) {
        self.id = id
        self.name = name
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.travelMode = travelMode
        self.checklist = checklist
        self.packing = packing
        self.cabinet = cabinet
    }

    var daysUntilDeparture: Int {
        max(0, Calendar.current.dateComponents([.day], from: .now.startOfDay, to: startDate.startOfDay).day ?? 0)
    }

    var itemsRemaining: Int {
        checklist.filter { $0.status != .complete && $0.status != .skipped }.count
    }

    var nextImportantTask: ChecklistItem? {
        checklist.first { $0.status == .needsAction || $0.status == .upcoming || $0.status == .inProgress }
    }

    var isPast: Bool {
        endDate < .now
    }
}

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
