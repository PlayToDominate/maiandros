import SwiftUI

struct TripDetailView: View {
    @EnvironmentObject private var store: TripStore
    @State var trip: Trip
    @State private var newCabinetText = ""
    @State private var newCabinetTags = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                countdownSection
                checklistSection
                cabinetSection
            }
            .padding()
        }
        .background(MaiandrosTheme.background.ignoresSafeArea())
        .navigationTitle(trip.name)
        .onChange(of: trip) { _, updated in
            store.update(updated)
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
                    if item.title == "Packing List" {
                        NavigationLink {
                            PackingListDetailView(trip: $trip, packingChecklistItemID: item.id)
                        } label: {
                            checklistRow(for: item, showChevron: true)
                        }
                        .buttonStyle(.plain)
                    } else {
                        checklistRow(for: item, showChevron: false)
                    }
                }
            }
        }
    }

    private func checklistRow(for item: ChecklistItem, showChevron: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon(for: item.status))
                    .foregroundStyle(color(for: item.status))
                Text(item.title).fontWeight(.semibold)
                Spacer()
                if showChevron {
                    Text(item.status.label)
                        .font(.footnote)
                        .foregroundStyle(MaiandrosTheme.secondaryText)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Menu(item.status.label) {
                        ForEach(ChecklistStatus.allCases, id: \.self) { status in
                            Button(status.label) { updateChecklist(item, status: status) }
                        }
                    }
                }
            }
            Text(item.detail)
                .font(.footnote)
                .foregroundStyle(MaiandrosTheme.secondaryText)
        }
        .padding(10)
        .background(MaiandrosTheme.cardAlt)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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

    private func updateChecklist(_ item: ChecklistItem, status: ChecklistStatus) {
        guard let index = trip.checklist.firstIndex(where: { $0.id == item.id }) else { return }
        trip.checklist[index].status = status
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

private struct PackingListDetailView: View {
    @Binding var trip: Trip
    let packingChecklistItemID: UUID
    @State private var newPackingItem = ""

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
                        syncChecklistToPackingProgress()
                    }
                }
            }

            Section("Packing Checklist Status") {
                Picker("Status", selection: packingStatusBinding) {
                    ForEach(ChecklistStatus.allCases, id: \.self) { status in
                        Text(status.label).tag(status)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(MaiandrosTheme.background)
        .navigationTitle("Packing List")
        .onAppear {
            syncChecklistToPackingProgress()
        }
        .onChange(of: trip.packing) { _, _ in
            syncChecklistToPackingProgress()
        }
    }

    private var packingStatusBinding: Binding<ChecklistStatus> {
        Binding {
            packingChecklistItem?.status ?? .inProgress
        } set: { newStatus in
            guard let idx = trip.checklist.firstIndex(where: { $0.id == packingChecklistItemID }) else { return }
            trip.checklist[idx].status = newStatus
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
