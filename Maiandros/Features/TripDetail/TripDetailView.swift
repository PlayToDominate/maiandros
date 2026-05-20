import PhotosUI
import SwiftUI
import UIKit

struct TripDetailView: View {
    @EnvironmentObject private var store: TripStore
    @State var trip: Trip
    @State private var newCabinetText = ""
    @State private var newCabinetTags = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedCabinetImageItem: PhotosPickerItem?

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                countdownSection
                checklistSection
                albumSection
                cabinetSection
            }
            .padding()
        }
        .background(MaiandrosTheme.background.ignoresSafeArea())
        .navigationTitle(trip.name)
        .onChange(of: trip) { _, updated in
            store.update(updated)
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                await importSelectedPhoto(newItem)
            }
        }
        .onChange(of: selectedCabinetImageItem) { _, newItem in
            guard let newItem else { return }
            Task {
                await importCabinetImage(newItem)
            }
        }
    }

    private var countdownSection: some View {
        CozyCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Countdown")
                    .font(.headline)
                Text("\(trip.daysUntilDeparture)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                Text("days until \(trip.destination)")
                    .font(.title3)
                Text("Meander is already daydreaming about this one.")
                    .foregroundStyle(MaiandrosTheme.secondaryText)
                Divider()
                Text("Weather peek: coming soon")
                    .font(.footnote)
                    .foregroundStyle(MaiandrosTheme.secondaryText)
            }
        }
    }

    private var checklistSection: some View {
        CozyCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Checklist")
                    .font(.headline)

                ForEach(trip.checklist) { item in
                    NavigationLink {
                        if item.title == "Packing List" {
                            PackingListDetailView(trip: $trip, packingChecklistItemID: item.id)
                        } else if item.title == "Home Preparation" {
                            HomePreparationDetailView(trip: $trip, homeChecklistItemID: item.id)
                        } else {
                            ChecklistItemDetailView(trip: $trip, checklistItemID: item.id)
                        }
                    } label: {
                        checklistRow(for: item)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func checklistRow(for item: ChecklistItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon(for: item.status))
                    .foregroundStyle(color(for: item.status))
                Text(item.title).fontWeight(.semibold)
                Spacer()
                Text(item.status.label)
                    .font(.footnote)
                    .foregroundStyle(MaiandrosTheme.secondaryText)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(item.detail)
                .font(.footnote)
                .foregroundStyle(MaiandrosTheme.secondaryText)
        }
        .padding(10)
        .background(MaiandrosTheme.cardAlt)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var albumSection: some View {
        CozyCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Trip Album")
                            .font(.headline)
                        Text("Screenshots, ticket snaps, little travel memories.")
                            .font(.footnote)
                            .foregroundStyle(MaiandrosTheme.secondaryText)
                    }
                    Spacer()
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label("Add", systemImage: "photo.badge.plus")
                    }
                }

                if trip.photos.isEmpty {
                    Text("No photos yet. Meander can collect your trip breadcrumbs here.")
                        .font(.footnote)
                        .foregroundStyle(MaiandrosTheme.secondaryText)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(trip.photos) { photo in
                                VStack(spacing: 6) {
                                    if let image = loadImage(fileName: photo.fileName) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 110, height: 110)
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    } else {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(MaiandrosTheme.cardAlt)
                                            .frame(width: 110, height: 110)
                                            .overlay {
                                                Image(systemName: "photo")
                                                    .foregroundStyle(.secondary)
                                            }
                                    }
                                    Button("Remove", role: .destructive) {
                                        removePhoto(photo)
                                    }
                                    .font(.caption)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var cabinetSection: some View {
        CozyCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Cabinet")
                    .font(.headline)
                Text("A cozy catch-all for notes, links, reservation numbers, and little ideas.")
                    .font(.footnote)
                    .foregroundStyle(MaiandrosTheme.secondaryText)

                TextField("Note / link / reminder", text: $newCabinetText)
                    .textFieldStyle(.roundedBorder)
                TextField("Tags (comma separated)", text: $newCabinetTags)
                    .textFieldStyle(.roundedBorder)
                PhotosPicker(selection: $selectedCabinetImageItem, matching: .images) {
                    Label("Attach Screenshot / Photo", systemImage: "paperclip")
                }
                Button("Save to Cabinet") {
                    let text = newCabinetText.trimmingCharacters(in: .whitespaces)
                    guard !text.isEmpty else { return }
                    let tags = newCabinetTags
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
                        .filter { !$0.isEmpty }
                    trip.cabinet.insert(CabinetEntry(text: text, tags: tags), at: 0)
                    newCabinetText = ""
                    newCabinetTags = ""
                }
                .buttonStyle(.borderedProminent)

                if trip.cabinet.isEmpty {
                    Text("Meander can stash your scattered travel snippets here.")
                        .font(.footnote)
                        .foregroundStyle(MaiandrosTheme.secondaryText)
                }

                ForEach(trip.cabinet) { entry in
                    VStack(alignment: .leading, spacing: 6) {
                        if let imageFileName = entry.imageFileName, let image = loadImage(fileName: imageFileName) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 160)
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                        Text(entry.text)
                        if !entry.tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(entry.tags, id: \.self) { tag in
                                        Text("#\(tag)")
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(MaiandrosTheme.cardAlt)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(MaiandrosTheme.cardAlt)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }

    private func icon(for status: ChecklistStatus) -> String {
        switch status {
        case .needsAction: return "exclamationmark.circle.fill"
        case .upcoming: return "clock.fill"
        case .inProgress: return "hourglass.circle.fill"
        case .complete: return "checkmark.circle.fill"
        case .skipped: return "minus.circle.fill"
        }
    }

    private func color(for status: ChecklistStatus) -> Color {
        switch status {
        case .needsAction: return MaiandrosTheme.warning
        case .upcoming: return .orange
        case .inProgress: return .yellow
        case .complete: return MaiandrosTheme.success
        case .skipped: return .gray
        }
    }

    private func importSelectedPhoto(_ item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let image = UIImage(data: data) else { return }
        guard let jpegData = image.jpegData(compressionQuality: 0.85) else { return }

        let fileName = "trip-photo-\(UUID().uuidString).jpg"
        let url = photoDirectoryURL().appendingPathComponent(fileName)
        do {
            try FileManager.default.createDirectory(at: photoDirectoryURL(), withIntermediateDirectories: true, attributes: nil)
            try jpegData.write(to: url, options: [.atomic])
            trip.photos.insert(TripPhoto(fileName: fileName), at: 0)
            selectedPhotoItem = nil
        } catch {
            selectedPhotoItem = nil
        }
    }

    private func importCabinetImage(_ item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let image = UIImage(data: data) else { return }
        guard let jpegData = image.jpegData(compressionQuality: 0.85) else { return }

        let fileName = "cabinet-photo-\(UUID().uuidString).jpg"
        let url = photoDirectoryURL().appendingPathComponent(fileName)
        do {
            try FileManager.default.createDirectory(at: photoDirectoryURL(), withIntermediateDirectories: true, attributes: nil)
            try jpegData.write(to: url, options: [.atomic])
            let fallbackText = "Screenshot / photo attachment"
            let text = newCabinetText.trimmingCharacters(in: .whitespacesAndNewlines)
            let tags = newCabinetTags
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
                .filter { !$0.isEmpty }
            trip.cabinet.insert(CabinetEntry(text: text.isEmpty ? fallbackText : text, tags: tags, imageFileName: fileName), at: 0)
            newCabinetText = ""
            newCabinetTags = ""
            selectedCabinetImageItem = nil
        } catch {
            selectedCabinetImageItem = nil
        }
    }

    private func removePhoto(_ photo: TripPhoto) {
        let url = photoDirectoryURL().appendingPathComponent(photo.fileName)
        try? FileManager.default.removeItem(at: url)
        trip.photos.removeAll { $0.id == photo.id }
    }

    private func loadImage(fileName: String) -> UIImage? {
        let url = photoDirectoryURL().appendingPathComponent(fileName)
        return UIImage(contentsOfFile: url.path)
    }

    private func photoDirectoryURL() -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("maiandros-trip-photos")
    }
}

private struct ChecklistItemDetailView: View {
    @Binding var trip: Trip
    let checklistItemID: UUID

    private var itemIndex: Int? {
        trip.checklist.firstIndex(where: { $0.id == checklistItemID })
    }

    var body: some View {
        Form {
            if let itemIndex {
                Section("Status") {
                    Picker("Status", selection: $trip.checklist[itemIndex].status) {
                        ForEach(ChecklistStatus.allCases, id: \.self) { status in
                            Text(status.label).tag(status)
                        }
                    }
                }

                Section("Details") {
                    TextField("Helper text", text: $trip.checklist[itemIndex].detail, axis: .vertical)
                        .lineLimit(2...5)
                }

                Section("Meander Tips") {
                    Text(contextualTip(for: trip.checklist[itemIndex].title))
                        .font(.footnote)
                        .foregroundStyle(MaiandrosTheme.secondaryText)
                }
            }
        }
        .navigationTitle(itemTitle)
    }

    private var itemTitle: String {
        trip.checklist.first(where: { $0.id == checklistItemID })?.title ?? "Checklist Item"
    }

    private func contextualTip(for title: String) -> String {
        switch title {
        case "Verify Passport":
            return "If this trip stays in the U.S., you can mark it skipped and exhale."
        case "Book Flights":
            return "A tiny goblin nudge: set one fare check reminder and walk away."
        case "Book Lodging":
            return "Pick your top 2 neighborhoods first, then compare stays there."
        case "Book Transportation":
            return "Only book this if the trip rhythm actually needs it."
        case "Home Preparation":
            return "Future-you will love simple wins: trash, thermostat, chargers, plants."
        default:
            return "Small steps count. Meander is keeping watch with you."
        }
    }
}

private struct HomePreparationDetailView: View {
    @Binding var trip: Trip
    let homeChecklistItemID: UUID
    @State private var newHomeTask = ""
    @State private var isManualStatusOverride = false

    private var doneCount: Int { trip.homePreparation.filter(\.isDone).count }

    var body: some View {
        List {
            Section {
                Text("\(doneCount)/\(trip.homePreparation.count) home prep tasks done")
                    .foregroundStyle(MaiandrosTheme.secondaryText)
                Text("Tiny goblin reminder: future-you will be so grateful for these.")
                    .font(.footnote)
                    .foregroundStyle(MaiandrosTheme.secondaryText)
            }

            Section("Tasks") {
                ForEach($trip.homePreparation) { $task in
                    HStack {
                        Toggle(isOn: $task.isDone) {
                            Text(task.name)
                        }
                        Button(role: .destructive) {
                            removeTask(task.id)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }

                HStack {
                    TextField("Add task", text: $newHomeTask)
                    Button("Add") {
                        let item = newHomeTask.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !item.isEmpty else { return }
                        trip.homePreparation.append(HomePrepItem(name: item))
                        newHomeTask = ""
                        if !isManualStatusOverride {
                            syncChecklistToHomePrepProgress()
                        }
                    }
                }
            }

            Section("Home Preparation Status") {
                Picker("Status", selection: homeStatusBinding) {
                    ForEach(ChecklistStatus.allCases, id: \.self) { status in
                        Text(status.label).tag(status)
                    }
                }
                if isManualStatusOverride {
                    Button("Use Automatic Status Again") {
                        isManualStatusOverride = false
                        syncChecklistToHomePrepProgress()
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(MaiandrosTheme.background)
        .navigationTitle("Home Preparation")
        .onAppear {
            if !isManualStatusOverride {
                syncChecklistToHomePrepProgress()
            }
        }
        .onChange(of: trip.homePreparation) { _, _ in
            if !isManualStatusOverride {
                syncChecklistToHomePrepProgress()
            }
        }
    }

    private var homeStatusBinding: Binding<ChecklistStatus> {
        Binding {
            homeChecklistItem?.status ?? .inProgress
        } set: { newStatus in
            guard let idx = trip.checklist.firstIndex(where: { $0.id == homeChecklistItemID }) else { return }
            trip.checklist[idx].status = newStatus
            isManualStatusOverride = true
        }
    }

    private var homeChecklistItem: ChecklistItem? {
        trip.checklist.first(where: { $0.id == homeChecklistItemID })
    }

    private func removeTask(_ id: UUID) {
        trip.homePreparation.removeAll { $0.id == id }
    }

    private func syncChecklistToHomePrepProgress() {
        guard let idx = trip.checklist.firstIndex(where: { $0.id == homeChecklistItemID }) else { return }
        let total = trip.homePreparation.count
        let done = doneCount
        if total > 0 && done == total {
            trip.checklist[idx].status = .complete
            trip.checklist[idx].detail = "Home is squared away. Meander approves this peaceful launch."
        } else {
            trip.checklist[idx].status = .inProgress
            trip.checklist[idx].detail = "\(done)/\(total) home tasks done. Calm and steady."
        }
    }
}

private struct PackingListDetailView: View {
    @Binding var trip: Trip
    let packingChecklistItemID: UUID
    @State private var newPackingItem = ""
    @State private var isManualStatusOverride = false

    private var packedCount: Int { trip.packing.filter(\.isPacked).count }

    var body: some View {
        List {
            Section {
                Text("\(packedCount)/\(trip.packing.count) packed")
                    .foregroundStyle(MaiandrosTheme.secondaryText)
                Text("The goblin believes in you. Also maybe pack socks.")
                    .font(.footnote)
                    .foregroundStyle(MaiandrosTheme.secondaryText)
            }

            Section("Items") {
                ForEach($trip.packing) { $item in
                    HStack {
                        Toggle(isOn: $item.isPacked) {
                            Text(item.name)
                        }
                        Button(role: .destructive) {
                            removePacking(item.id)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }

                HStack {
                    TextField("Add item", text: $newPackingItem)
                    Button("Add") {
                        let item = newPackingItem.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !item.isEmpty else { return }
                        trip.packing.append(PackingItem(name: item))
                        newPackingItem = ""
                        if !isManualStatusOverride {
                            syncChecklistToPackingProgress()
                        }
                    }
                }
            }

            Section("Packing Checklist Status") {
                Picker("Status", selection: packingStatusBinding) {
                    ForEach(ChecklistStatus.allCases, id: \.self) { status in
                        Text(status.label).tag(status)
                    }
                }
                if isManualStatusOverride {
                    Button("Use Automatic Status Again") {
                        isManualStatusOverride = false
                        syncChecklistToPackingProgress()
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(MaiandrosTheme.background)
        .navigationTitle("Packing List")
        .onAppear {
            if !isManualStatusOverride {
                syncChecklistToPackingProgress()
            }
        }
        .onChange(of: trip.packing) { _, _ in
            if !isManualStatusOverride {
                syncChecklistToPackingProgress()
            }
        }
    }

    private var packingStatusBinding: Binding<ChecklistStatus> {
        Binding {
            packingChecklistItem?.status ?? .inProgress
        } set: { newStatus in
            guard let idx = trip.checklist.firstIndex(where: { $0.id == packingChecklistItemID }) else { return }
            trip.checklist[idx].status = newStatus
            isManualStatusOverride = true
        }
    }

    private var packingChecklistItem: ChecklistItem? {
        trip.checklist.first(where: { $0.id == packingChecklistItemID })
    }

    private func removePacking(_ id: UUID) {
        trip.packing.removeAll { $0.id == id }
    }

    private func syncChecklistToPackingProgress() {
        guard let idx = trip.checklist.firstIndex(where: { $0.id == packingChecklistItemID }) else { return }

        let total = trip.packing.count
        let packed = packedCount

        if total > 0 && packed == total {
            trip.checklist[idx].status = .complete
            trip.checklist[idx].detail = "All packed. Meander is doing a tiny victory dance."
        } else {
            trip.checklist[idx].status = .inProgress
            trip.checklist[idx].detail = "\(packed)/\(total) packed. Slow and steady, cozy traveler."
        }
    }
}
