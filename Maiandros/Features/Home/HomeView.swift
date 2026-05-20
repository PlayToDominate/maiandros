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
            List {
                CozyCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Maiandros")
                            .font(.title2.weight(.bold))
                        Text("Meander says: little steps now, easier travel later.")
                            .foregroundStyle(MaiandrosTheme.secondaryText)
                    }
                }
                .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

                Section {
                    if currentTrips.isEmpty {
                        CozyCard {
                            Text("No trips yet. Meander is ready when you are.")
                                .foregroundStyle(MaiandrosTheme.secondaryText)
                        }
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    } else {
                        ForEach(currentTrips) { trip in
                            NavigationLink(value: trip.id) {
                                TripCard(trip: trip)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    store.deleteTrip(id: trip.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                } header: {
                    Text("Current Trips")
                }

                Section {
                    CozyCard {
                        Text(pastTrips.isEmpty ? "Past trips will gather here like happy postcards." : "\(pastTrips.count) past trip(s)")
                            .foregroundStyle(MaiandrosTheme.secondaryText)
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } header: {
                    Text("Past Trips")
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
                .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 20, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .background(MaiandrosTheme.background.ignoresSafeArea())
            .scrollContentBackground(.hidden)
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
