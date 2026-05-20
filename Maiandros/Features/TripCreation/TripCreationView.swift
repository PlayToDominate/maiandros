import MapKit
import SwiftUI

struct TripCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: TripStore
    @StateObject private var autocomplete = DestinationAutocompleteViewModel()

    @State private var tripName = ""
    @State private var destination = ""
    @State private var startDate = Calendar.current.date(byAdding: .day, value: 30, to: .now) ?? .now
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 37, to: .now) ?? .now
    @State private var mode: TravelMode = .flying
    @State private var reason: TripReason = .vacation

    var canSave: Bool {
        !tripName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !destination.trimmingCharacters(in: .whitespaces).isEmpty &&
        endDate >= startDate
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Trip Basics") {
                    TextField("Trip Name", text: $tripName)
                    TextField("Destination", text: $destination)
                        .onChange(of: destination) { _, newValue in
                            autocomplete.update(query: newValue)
                        }

                    if !autocomplete.suggestions.isEmpty && !destination.isEmpty {
                        ForEach(autocomplete.suggestions) { suggestion in
                            Button {
                                destination = suggestion.displayText
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

                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                    Picker("Reason", selection: $reason) {
                        ForEach(TripReason.allCases) { reason in
                            Text(reason.title).tag(reason)
                        }
                    }
                    Picker("Flying or Driving", selection: $mode) {
                        ForEach(TravelMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Text("Meander will help with passport timing, booking nudges, and cozy prep from here.")
                        .font(.footnote)
                        .foregroundStyle(MaiandrosTheme.secondaryText)
                }
            }
            .navigationTitle("New Trip")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create") {
                        store.addTrip(name: tripName, destination: destination, reason: reason, startDate: startDate, endDate: endDate, mode: mode)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
        .presentationDetents([.large])
    }
}

struct DestinationSuggestion: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String

    var displayText: String {
        subtitle.isEmpty ? title : "\(title), \(subtitle)"
    }
}

final class DestinationAutocompleteViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var suggestions: [DestinationSuggestion] = []

    private let completer = MKLocalSearchCompleter()
    private var isIgnoringCompleterUpdates = false

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }

    func update(query: String) {
        if isIgnoringCompleterUpdates { return }
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count < 2 {
            suggestions = []
            return
        }
        completer.queryFragment = trimmed
    }

    func clear() {
        suggestions = []
    }

    func acceptSelection() {
        isIgnoringCompleterUpdates = true
        suggestions = []
        completer.queryFragment = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            self?.isIgnoringCompleterUpdates = false
        }
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        if isIgnoringCompleterUpdates { return }
        suggestions = completer.results.prefix(6).map {
            DestinationSuggestion(title: $0.title, subtitle: $0.subtitle)
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        suggestions = []
    }
}
