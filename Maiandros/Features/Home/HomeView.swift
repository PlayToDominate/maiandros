import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: TripStore
    @State private var showingCreate = false

    var currentTrips: [Trip] {
        store.trips.filter { !$0.isPast }.sorted { $0.startDate < $1.startDate }
    }

    var pastTrips: [Trip] {
        store.trips.filter { $0.isPast }.sorted { $0.startDate > $1.startDate }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    CozyCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Maiandros")
                                .font(.title2.weight(.bold))
                            Text("Meander says: little steps now, easier travel later.")
                                .foregroundStyle(MaiandrosTheme.secondaryText)
                        }
                    }

                    sectionHeader("Current Trips")
                    if currentTrips.isEmpty {
                        CozyCard {
                            Text("No trips yet. Meander is ready when you are.")
                                .foregroundStyle(MaiandrosTheme.secondaryText)
                        }
                    } else {
                        ForEach(currentTrips) { trip in
                            NavigationLink(value: trip.id) {
                                TripCard(trip: trip)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    sectionHeader("Past Trips")
                    CozyCard {
                        Text(pastTrips.isEmpty ? "Past trips will gather here like happy postcards." : "\(pastTrips.count) past trip(s)")
                            .foregroundStyle(MaiandrosTheme.secondaryText)
                    }

                    Button {
                        showingCreate = true
                    } label: {
                        Text("+ Start Planning a Trip")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(MaiandrosTheme.accent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
                .padding()
            }
            .background(MaiandrosTheme.background.ignoresSafeArea())
            .navigationDestination(for: UUID.self) { id in
                if let trip = store.trips.first(where: { $0.id == id }) {
                    TripDetailView(trip: trip)
                }
            }
            .sheet(isPresented: $showingCreate) {
                TripCreationView()
            }
            .navigationTitle("Your Wander Shelf")
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(MaiandrosTheme.primaryText)
            .padding(.top, 4)
    }
}

private struct TripCard: View {
    let trip: Trip

    var body: some View {
        CozyCard {
            VStack(alignment: .leading, spacing: 6) {
                Text(trip.destination)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(MaiandrosTheme.primaryText)
                Text(trip.reason.title)
                    .font(.caption)
                    .foregroundStyle(MaiandrosTheme.secondaryText)
                Text("\(trip.daysUntilDeparture) days left")
                    .foregroundStyle(MaiandrosTheme.secondaryText)
                Text("\(trip.itemsRemaining) items remaining")
                    .font(.subheadline)
                Text("Next: \(trip.nextImportantTask?.title ?? "Take a cozy breath")")
                    .font(.footnote)
                    .foregroundStyle(MaiandrosTheme.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
