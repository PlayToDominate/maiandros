import SwiftUI

struct TripCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: TripStore

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
