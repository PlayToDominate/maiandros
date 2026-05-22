import PhotosUI
import SwiftUI
import UIKit

struct TripDetailView: View {
    @EnvironmentObject private var store: TripStore
    @StateObject private var weatherViewModel = TripWeatherViewModel()
    @State var trip: Trip
    @State private var newCabinetText = ""
    @State private var newCabinetTags = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedCabinetImageItem: PhotosPickerItem?
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                MeanderCalloutCard(line: MeanderQuoteService.timelineLine(daysUntil: trip.daysUntilDeparture, seed: trip.id.uuidString))
                countdownSection
                checklistSection
                albumSection
                cabinetSection
            }
            .padding()
        }
        .background(MaiandrosTheme.background.ignoresSafeArea())
        .navigationTitle(trip.name)
        .onAppear {
            weatherViewModel.loadWeather(for: trip)
            weatherViewModel.loadTenDay(for: trip)
        }
        .onChange(of: trip.startDate) { _, _ in
            weatherViewModel.loadWeather(for: trip)
            weatherViewModel.loadTenDay(for: trip)
        }
        .onChange(of: trip.destination) { _, _ in
            weatherViewModel.loadWeather(for: trip)
            weatherViewModel.loadTenDay(for: trip)
        }
        .onChange(of: trip) { _, updated in
            store.update(updated)
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task { await importTripAlbumImage(newItem) }
        }
        .onChange(of: selectedCabinetImageItem) { _, newItem in
            guard let newItem else { return }
            Task { await importGlobalCabinetImage(newItem) }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink("Edit Trip") {
                    TripBasicsEditView(trip: $trip)
                }
            }
        }
    }

    private var countdownSection: some View {
        CozyCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Countdown")
                    .font(.headline)
                if trip.daysUntilDeparture == 0 {
                    Text("Today is the day")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                    Text("Meander says: breathe, wander, enjoy \(trip.destination).")
                        .font(.title3)
                } else {
                    Text("\(trip.daysUntilDeparture)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                    Text("days until \(trip.destination)")
                        .font(.title3)
                }
                Text(MeanderQuoteService.line(for: .countdown, daysUntil: trip.daysUntilDeparture, seed: trip.id.uuidString))
                    .foregroundStyle(MaiandrosTheme.secondaryText)
                Divider()
                Text(weatherViewModel.weatherLine)
                    .font(.footnote)
                    .foregroundStyle(MaiandrosTheme.secondaryText)
                HStack(spacing: 10) {
                    NavigationLink("See 10-Day Forecast") {
                        TenDayForecastView(
                            locationTitle: weatherViewModel.tenDayLocationName ?? trip.destination,
                            days: weatherViewModel.tenDayForecast,
                            departureDate: trip.startDate
                        )
                    }
                    .buttonStyle(.bordered)

                    Button("Open Weather App") {
                        if let url = URL(string: "weather://") {
                            openURL(url)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top, 2)
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
                            ChecklistItemDetailView(
                                trip: $trip,
                                checklistItemID: item.id,
                                sectionTag: sectionTag(for: item.title)
                            )
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
            Text(summaryText(for: item))
                .font(.footnote)
                .foregroundStyle(MaiandrosTheme.secondaryText)
        }
        .padding(10)
        .background(MaiandrosTheme.cardAlt)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func summaryText(for item: ChecklistItem) -> String {
        let tag = sectionTag(for: item.title)
        guard let tag else { return item.detail }
        let tagged = trip.cabinet.filter { $0.tags.contains(tag) }
        guard let latest = tagged.first else { return item.detail }

        switch tag {
        case "flights": return "Flights tucked here: \(latest.text)"
        case "lodging": return "Lodging tucked here: \(latest.text)"
        case "transportation": return "Transport tucked here: \(latest.text)"
        case "passport": return "Passport note tucked here: \(latest.text)"
        default: return latest.text
        }
    }

    private func sectionTag(for title: String) -> String? {
        switch title {
        case "Verify Passport": return "passport"
        case "Book Flights": return "flights"
        case "Book Lodging": return "lodging"
        case "Book Transportation": return "transportation"
        case "Packing List": return "packing"
        case "Home Preparation": return "home"
        default: return nil
        }
    }

    private var albumSection: some View {
        CozyCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Trip Album")
                            .font(.headline)
                        Text(MeanderQuoteService.line(for: .tripAlbum, seed: trip.id.uuidString))
                            .font(.footnote)
                            .foregroundStyle(MaiandrosTheme.secondaryText)
                    }
                    Spacer()
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label("Add", systemImage: "photo.badge.plus")
                    }
                }

                if trip.photos.isEmpty {
                    HStack {
                        Text("No photos yet.")
                            .font(.footnote)
                            .foregroundStyle(MaiandrosTheme.secondaryText)
                        Spacer()
                        MeanderBadge()
                    }
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(trip.photos) { photo in
                                VStack(spacing: 6) {
                                    if let image = LocalImageStore.loadImage(fileName: photo.fileName) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 110, height: 110)
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    }
                                    Button("Remove", role: .destructive) {
                                        LocalImageStore.delete(fileName: photo.fileName)
                                        trip.photos.removeAll { $0.id == photo.id }
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
                Text(MeanderQuoteService.line(for: .cabinet, seed: trip.id.uuidString))
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
                    let text = newCabinetText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty else { return }
                    let tags = parseTags(newCabinetTags)
                    trip.cabinet.insert(CabinetEntry(text: text, tags: tags), at: 0)
                    newCabinetText = ""
                    newCabinetTags = ""
                }
                .buttonStyle(.borderedProminent)

                if trip.cabinet.isEmpty {
                    HStack {
                        Text("No snippets tucked away yet.")
                            .font(.footnote)
                            .foregroundStyle(MaiandrosTheme.secondaryText)
                        Spacer()
                        MeanderBadge()
                    }
                }

                ForEach(trip.cabinet) { entry in
                    CabinetEntryCard(entry: entry)
                }
            }
        }
    }

    private func parseTags(_ raw: String) -> [String] {
        raw.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
    }

    private func importTripAlbumImage(_ item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data),
              let jpegData = image.jpegData(compressionQuality: 0.85),
              let fileName = LocalImageStore.save(jpegData: jpegData, prefix: "trip-photo") else {
            selectedPhotoItem = nil
            return
        }

        trip.photos.insert(TripPhoto(fileName: fileName), at: 0)
        selectedPhotoItem = nil
    }

    private func importGlobalCabinetImage(_ item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data),
              let jpegData = image.jpegData(compressionQuality: 0.85),
              let fileName = LocalImageStore.save(jpegData: jpegData, prefix: "cabinet-photo") else {
            selectedCabinetImageItem = nil
            return
        }

        let text = newCabinetText.trimmingCharacters(in: .whitespacesAndNewlines)
        let tags = parseTags(newCabinetTags)
        trip.cabinet.insert(CabinetEntry(text: text.isEmpty ? "Screenshot / photo attachment" : text, tags: tags, imageFileName: fileName), at: 0)
        newCabinetText = ""
        newCabinetTags = ""
        selectedCabinetImageItem = nil
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
}

private struct TenDayForecastView: View {
    let locationTitle: String
    let days: [WeatherForecastDay]
    let departureDate: Date

    var body: some View {
        List {
            if days.isEmpty {
                Text("Meander tried peeking at the weather, but the clouds were shy.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(days) { day in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(day.date, format: .dateTime.weekday(.abbreviated).day())
                                .fontWeight(.semibold)
                            Text(day.condition)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if Calendar.current.isDate(day.date, inSameDayAs: departureDate) {
                            Text("Departure")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(MaiandrosTheme.cardAlt)
                                .clipShape(Capsule())
                        }
                        Text("\(day.high)°")
                            .fontWeight(.semibold)
                        Text("\(day.low)°")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(locationTitle)
    }
}

private struct TripBasicsEditView: View {
    @Binding var trip: Trip
    @StateObject private var autocomplete = DestinationAutocompleteViewModel()

    var body: some View {
        Form {
            Section("Trip Basics") {
                TextField("Trip Name", text: $trip.name)

                TextField("Destination", text: $trip.destination)
                    .onChange(of: trip.destination) { _, newValue in
                        autocomplete.update(query: newValue)
                    }

                if !autocomplete.suggestions.isEmpty && !trip.destination.isEmpty {
                    ForEach(autocomplete.suggestions) { suggestion in
                        Button {
                            trip.destination = suggestion.displayText
                            autocomplete.acceptSelection()
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(suggestion.title)
                                    .foregroundStyle(.primary)
                                if !suggestion.subtitle.isEmpty {
                                    Text(suggestion.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                DatePicker("Start Date", selection: $trip.startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $trip.endDate, in: trip.startDate..., displayedComponents: .date)

                Picker("Reason", selection: $trip.reason) {
                    ForEach(TripReason.allCases) { reason in
                        Text(reason.title).tag(reason)
                    }
                }

                Picker("Flying or Driving", selection: $trip.travelMode) {
                    ForEach(TravelMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle("Edit Trip")
    }
}

private struct CabinetEntryCard: View {
    let entry: CabinetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let imageFileName = entry.imageFileName, let image = LocalImageStore.loadImage(fileName: imageFileName) {
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

private struct ChecklistItemDetailView: View {
    @Binding var trip: Trip
    let checklistItemID: UUID
    let sectionTag: String?
    @State private var sectionNote = ""
    @State private var sectionTags = ""
    @State private var selectedSectionImageItem: PhotosPickerItem?

    private var itemIndex: Int? { trip.checklist.firstIndex(where: { $0.id == checklistItemID }) }

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

                if let sectionTag {
                    Section("Section Cabinet") {
                        TextField("Add a note for this section", text: $sectionNote)
                        TextField("Extra tags (comma separated)", text: $sectionTags)
                        PhotosPicker(selection: $selectedSectionImageItem, matching: .images) {
                            Label("Attach Screenshot / Photo", systemImage: "paperclip")
                        }
                        Button("Save to Cabinet") {
                            let text = sectionNote.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !text.isEmpty else { return }
                            var tags = parseTags(sectionTags)
                            tags.append(sectionTag)
                            trip.cabinet.insert(CabinetEntry(text: text, tags: Array(Set(tags))), at: 0)
                            sectionNote = ""
                            sectionTags = ""
                        }

                        ForEach(trip.cabinet.filter { $0.tags.contains(sectionTag) }) { entry in
                            CabinetEntryCard(entry: entry)
                        }
                    }
                }

                Section("Meander Tips") {
                    Text(contextualTip(for: trip.checklist[itemIndex].title))
                        .font(.footnote)
                        .foregroundStyle(MaiandrosTheme.secondaryText)
                }
            }
        }
        .navigationTitle(itemTitle)
        .onChange(of: selectedSectionImageItem) { _, newItem in
            guard let newItem, let sectionTag else { return }
            Task { await saveSectionImage(item: newItem, sectionTag: sectionTag) }
        }
    }

    private var itemTitle: String {
        trip.checklist.first(where: { $0.id == checklistItemID })?.title ?? "Checklist Item"
    }

    private func parseTags(_ raw: String) -> [String] {
        raw.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
    }

    private func saveSectionImage(item: PhotosPickerItem, sectionTag: String) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data),
              let jpegData = image.jpegData(compressionQuality: 0.85),
              let fileName = LocalImageStore.save(jpegData: jpegData, prefix: "cabinet-photo") else {
            selectedSectionImageItem = nil
            return
        }

        let text = sectionNote.trimmingCharacters(in: .whitespacesAndNewlines)
        var tags = parseTags(sectionTags)
        tags.append(sectionTag)
        trip.cabinet.insert(CabinetEntry(text: text.isEmpty ? "Section screenshot / photo" : text, tags: Array(Set(tags)), imageFileName: fileName), at: 0)
        sectionNote = ""
        sectionTags = ""
        selectedSectionImageItem = nil
    }

    private func contextualTip(for title: String) -> String {
        switch title {
        case "Verify Passport": return "If this trip stays in the U.S., you can mark it skipped and exhale."
        case "Book Flights": return "A tiny nudge: store flight number and confirmation here."
        case "Book Lodging": return "Save confirmation and check-in details while they're fresh."
        case "Book Transportation": return "Store pickup point or platform notes for easy departure day."
        default: return MeanderQuoteService.line(for: .checklist, seed: title)
        }
    }
}

private struct HomePreparationDetailView: View {
    @Binding var trip: Trip
    let homeChecklistItemID: UUID
    @State private var newHomeTask = ""
    @State private var isManualStatusOverride = false
    @State private var sectionNote = ""
    @State private var sectionTags = ""
    @State private var selectedSectionImageItem: PhotosPickerItem?

    private var doneCount: Int { trip.homePreparation.filter(\.isDone).count }

    var body: some View {
        List {
            Section {
                Text("\(doneCount)/\(trip.homePreparation.count) home prep tasks done")
                    .foregroundStyle(MaiandrosTheme.secondaryText)
                Text(MeanderQuoteService.line(for: .checklist, seed: "home"))
                    .font(.footnote)
                    .foregroundStyle(MaiandrosTheme.secondaryText)
            }

            Section("Tasks") {
                ForEach($trip.homePreparation) { $task in
                    HStack {
                        Toggle(isOn: $task.isDone) { Text(task.name) }
                        Button(role: .destructive) { removeTask(task.id) } label: { Image(systemName: "trash") }
                    }
                }

                HStack {
                    TextField("Add task", text: $newHomeTask)
                    Button("Add") {
                        let item = newHomeTask.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !item.isEmpty else { return }
                        trip.homePreparation.append(HomePrepItem(name: item))
                        newHomeTask = ""
                        if !isManualStatusOverride { syncChecklistToHomePrepProgress() }
                    }
                }
            }

            Section("Home Preparation Status") {
                Picker("Status", selection: homeStatusBinding) {
                    ForEach(ChecklistStatus.allCases, id: \.self) { status in Text(status.label).tag(status) }
                }
                if isManualStatusOverride {
                    Button("Use Automatic Status Again") {
                        isManualStatusOverride = false
                        syncChecklistToHomePrepProgress()
                    }
                }
            }

            Section("Section Cabinet") {
                TextField("Add home prep note", text: $sectionNote)
                TextField("Extra tags (comma separated)", text: $sectionTags)
                PhotosPicker(selection: $selectedSectionImageItem, matching: .images) {
                    Label("Attach Screenshot / Photo", systemImage: "paperclip")
                }
                Button("Save to Cabinet") {
                    let text = sectionNote.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty else { return }
                    var tags = parseTags(sectionTags)
                    tags.append("home")
                    trip.cabinet.insert(CabinetEntry(text: text, tags: Array(Set(tags))), at: 0)
                    sectionNote = ""
                    sectionTags = ""
                }
                ForEach(trip.cabinet.filter { $0.tags.contains("home") }) { entry in
                    CabinetEntryCard(entry: entry)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(MaiandrosTheme.background)
        .navigationTitle("Home Preparation")
        .onAppear { if !isManualStatusOverride { syncChecklistToHomePrepProgress() } }
        .onChange(of: trip.homePreparation) { _, _ in
            if !isManualStatusOverride { syncChecklistToHomePrepProgress() }
        }
        .onChange(of: selectedSectionImageItem) { _, newItem in
            guard let newItem else { return }
            Task { await saveSectionImage(item: newItem) }
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
            trip.checklist[idx].detail = MeanderQuoteService.line(for: .completeTask, seed: "home-complete")
        } else {
            trip.checklist[idx].status = .inProgress
            trip.checklist[idx].detail = "\(done)/\(total) home tasks done."
        }
    }

    private func parseTags(_ raw: String) -> [String] {
        raw.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
    }

    private func saveSectionImage(item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data),
              let jpegData = image.jpegData(compressionQuality: 0.85),
              let fileName = LocalImageStore.save(jpegData: jpegData, prefix: "cabinet-photo") else {
            selectedSectionImageItem = nil
            return
        }

        let text = sectionNote.trimmingCharacters(in: .whitespacesAndNewlines)
        var tags = parseTags(sectionTags)
        tags.append("home")
        trip.cabinet.insert(CabinetEntry(text: text.isEmpty ? "Home preparation attachment" : text, tags: Array(Set(tags)), imageFileName: fileName), at: 0)
        sectionNote = ""
        sectionTags = ""
        selectedSectionImageItem = nil
    }
}

private struct PackingListDetailView: View {
    @Binding var trip: Trip
    let packingChecklistItemID: UUID
    @State private var newPackingItem = ""
    @State private var isManualStatusOverride = false
    @State private var sectionNote = ""
    @State private var sectionTags = ""
    @State private var selectedSectionImageItem: PhotosPickerItem?

    private var packedCount: Int { trip.packing.filter(\.isPacked).count }

    var body: some View {
        List {
            Section {
                Text("\(packedCount)/\(trip.packing.count) packed")
                    .foregroundStyle(MaiandrosTheme.secondaryText)
                Text(MeanderQuoteService.line(for: .packing, seed: "packing"))
                    .font(.footnote)
                    .foregroundStyle(MaiandrosTheme.secondaryText)
            }

            Section("Items") {
                ForEach($trip.packing) { $item in
                    HStack {
                        Toggle(isOn: $item.isPacked) { Text(item.name) }
                        Button(role: .destructive) { removePacking(item.id) } label: { Image(systemName: "trash") }
                    }
                }

                HStack {
                    TextField("Add item", text: $newPackingItem)
                    Button("Add") {
                        let item = newPackingItem.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !item.isEmpty else { return }
                        trip.packing.append(PackingItem(name: item))
                        newPackingItem = ""
                        if !isManualStatusOverride { syncChecklistToPackingProgress() }
                    }
                }
            }

            Section("Packing Checklist Status") {
                Picker("Status", selection: packingStatusBinding) {
                    ForEach(ChecklistStatus.allCases, id: \.self) { status in Text(status.label).tag(status) }
                }
                if isManualStatusOverride {
                    Button("Use Automatic Status Again") {
                        isManualStatusOverride = false
                        syncChecklistToPackingProgress()
                    }
                }
            }

            Section("Section Cabinet") {
                TextField("Add packing note", text: $sectionNote)
                TextField("Extra tags (comma separated)", text: $sectionTags)
                PhotosPicker(selection: $selectedSectionImageItem, matching: .images) {
                    Label("Attach Screenshot / Photo", systemImage: "paperclip")
                }
                Button("Save to Cabinet") {
                    let text = sectionNote.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty else { return }
                    var tags = parseTags(sectionTags)
                    tags.append("packing")
                    trip.cabinet.insert(CabinetEntry(text: text, tags: Array(Set(tags))), at: 0)
                    sectionNote = ""
                    sectionTags = ""
                }
                ForEach(trip.cabinet.filter { $0.tags.contains("packing") }) { entry in
                    CabinetEntryCard(entry: entry)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(MaiandrosTheme.background)
        .navigationTitle("Packing List")
        .onAppear { if !isManualStatusOverride { syncChecklistToPackingProgress() } }
        .onChange(of: trip.packing) { _, _ in
            if !isManualStatusOverride { syncChecklistToPackingProgress() }
        }
        .onChange(of: selectedSectionImageItem) { _, newItem in
            guard let newItem else { return }
            Task { await saveSectionImage(item: newItem) }
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
            trip.checklist[idx].detail = MeanderQuoteService.line(for: .completeTask, seed: "packing-complete")
        } else {
            trip.checklist[idx].status = .inProgress
            trip.checklist[idx].detail = "\(packed)/\(total) packed."
        }
    }

    private func parseTags(_ raw: String) -> [String] {
        raw.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
    }

    private func saveSectionImage(item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data),
              let jpegData = image.jpegData(compressionQuality: 0.85),
              let fileName = LocalImageStore.save(jpegData: jpegData, prefix: "cabinet-photo") else {
            selectedSectionImageItem = nil
            return
        }

        let text = sectionNote.trimmingCharacters(in: .whitespacesAndNewlines)
        var tags = parseTags(sectionTags)
        tags.append("packing")
        trip.cabinet.insert(CabinetEntry(text: text.isEmpty ? "Packing attachment" : text, tags: Array(Set(tags)), imageFileName: fileName), at: 0)
        sectionNote = ""
        sectionTags = ""
        selectedSectionImageItem = nil
    }
}

private enum LocalImageStore {
    static func directoryURL() -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("maiandros-trip-photos")
    }

    static func save(jpegData: Data, prefix: String) -> String? {
        let fileName = "\(prefix)-\(UUID().uuidString).jpg"
        let url = directoryURL().appendingPathComponent(fileName)
        do {
            try FileManager.default.createDirectory(at: directoryURL(), withIntermediateDirectories: true, attributes: nil)
            try jpegData.write(to: url, options: [.atomic])
            return fileName
        } catch {
            return nil
        }
    }

    static func loadImage(fileName: String) -> UIImage? {
        UIImage(contentsOfFile: directoryURL().appendingPathComponent(fileName).path)
    }

    static func delete(fileName: String) {
        try? FileManager.default.removeItem(at: directoryURL().appendingPathComponent(fileName))
    }
}
