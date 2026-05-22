import Foundation

enum TravelMode: String, Codable, CaseIterable, Identifiable, Equatable {
    case flying
    case driving

    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

enum TripReason: String, Codable, CaseIterable, Identifiable, Equatable {
    case vacation
    case family
    case weddingEvent
    case work
    case natureReset
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .vacation: return "Vacation"
        case .family: return "Family"
        case .weddingEvent: return "Wedding/Event"
        case .work: return "Work"
        case .natureReset: return "Nature Reset"
        case .other: return "Other"
        }
    }
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

struct HomePrepItem: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var isDone: Bool

    init(id: UUID = UUID(), name: String, isDone: Bool = false) {
        self.id = id
        self.name = name
        self.isDone = isDone
    }
}

struct CabinetEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var text: String
    var tags: [String]
    var imageFileName: String?
    var createdAt: Date

    init(id: UUID = UUID(), text: String, tags: [String], imageFileName: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.tags = tags
        self.imageFileName = imageFileName
        self.createdAt = createdAt
    }
}

struct TripPhoto: Identifiable, Codable, Equatable {
    let id: UUID
    var fileName: String
    var createdAt: Date

    init(id: UUID = UUID(), fileName: String, createdAt: Date = Date()) {
        self.id = id
        self.fileName = fileName
        self.createdAt = createdAt
    }
}

struct Trip: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var destination: String
    var reason: TripReason
    var startDate: Date
    var endDate: Date
    var travelMode: TravelMode
    var checklist: [ChecklistItem]
    var packing: [PackingItem]
    var homePreparation: [HomePrepItem]
    var cabinet: [CabinetEntry]
    var photos: [TripPhoto]

    enum CodingKeys: String, CodingKey {
        case id, name, destination, reason, startDate, endDate, travelMode, checklist, packing, homePreparation, cabinet, photos
    }

    init(
        id: UUID = UUID(),
        name: String,
        destination: String,
        reason: TripReason,
        startDate: Date,
        endDate: Date,
        travelMode: TravelMode,
        checklist: [ChecklistItem] = [],
        packing: [PackingItem] = [],
        homePreparation: [HomePrepItem] = [],
        cabinet: [CabinetEntry] = [],
        photos: [TripPhoto] = []
    ) {
        self.id = id
        self.name = name
        self.destination = destination
        self.reason = reason
        self.startDate = startDate
        self.endDate = endDate
        self.travelMode = travelMode
        self.checklist = checklist
        self.packing = packing
        self.homePreparation = homePreparation
        self.cabinet = cabinet
        self.photos = photos
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.destination = try container.decode(String.self, forKey: .destination)
        self.reason = try container.decodeIfPresent(TripReason.self, forKey: .reason) ?? .vacation
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        self.endDate = try container.decode(Date.self, forKey: .endDate)
        self.travelMode = try container.decode(TravelMode.self, forKey: .travelMode)
        self.checklist = try container.decode([ChecklistItem].self, forKey: .checklist)
        self.packing = try container.decode([PackingItem].self, forKey: .packing)
        self.homePreparation = try container.decodeIfPresent([HomePrepItem].self, forKey: .homePreparation) ?? []
        self.cabinet = try container.decode([CabinetEntry].self, forKey: .cabinet)
        self.photos = try container.decodeIfPresent([TripPhoto].self, forKey: .photos) ?? []
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
        endDate.startOfDay < Date().startOfDay
    }

    var isOnTrip: Bool {
        let today = Date().startOfDay
        return startDate.startOfDay <= today && endDate.startOfDay >= today
    }

    var isUpcoming: Bool {
        startDate.startOfDay > Date().startOfDay
    }
}

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
