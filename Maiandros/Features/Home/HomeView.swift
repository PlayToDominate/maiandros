import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: TripStore
    @State private var showingCreate = false
    @State private var showingAboutMeander = false

    var currentTrips: [Trip] {
        store.trips.filter { !$0.isPast }.sorted { $0.startDate < $1.startDate }
    }

    var pastTrips: [Trip] {
        store.trips.filter { $0.isPast }.sorted { $0.startDate > $1.startDate }
    }

    var body: some View {
        NavigationStack {
            List {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Maiandros")
                                .font(.system(size: 38, weight: .bold, design: .rounded))
                            Text("little steps now, easier travel later")
                                .font(.footnote.italic())
                                .foregroundStyle(MaiandrosTheme.secondaryText)
                        }
                        Spacer()
                        Button {
                            showingAboutMeander = true
                        } label: {
                            MeanderAvatar(size: .medium)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("About Meander")
                    }

                    Text(MeanderQuoteService.line(for: currentTrips.isEmpty ? .homeEmpty : .homeActiveTrips, seed: "home-header"))
                        .font(.footnote)
                        .foregroundStyle(MaiandrosTheme.secondaryText)
                }
                .listRowInsets(EdgeInsets(top: 14, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

                Section {
                    if currentTrips.isEmpty {
                        CozyCard {
                            MeanderEmptyState(line: MeanderQuoteService.line(for: .homeEmpty, seed: "home-empty"))
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
                        VStack(alignment: .leading, spacing: 8) {
                            Text(pastTrips.isEmpty ? "Past trips will gather here like happy postcards." : "\(pastTrips.count) past trip(s)")
                                .foregroundStyle(MaiandrosTheme.secondaryText)
                            if !pastTrips.isEmpty {
                                Text(MeanderQuoteService.line(for: .postTripNostalgia, seed: "past-trips"))
                                    .font(.footnote)
                                    .foregroundStyle(MaiandrosTheme.secondaryText)
                            }
                        }
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
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: UUID.self) { id in
                if let trip = store.trips.first(where: { $0.id == id }) {
                    TripDetailView(trip: trip)
                }
            }
            .sheet(isPresented: $showingCreate) {
                TripCreationView()
            }
            .navigationDestination(isPresented: $showingAboutMeander) {
                AboutMeanderView()
            }
        }
    }
}

private struct TripCard: View {
    let trip: Trip

    var body: some View {
        CozyCard {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(trip.destination)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(MaiandrosTheme.primaryText)
                        Text(trip.reason.title)
                            .font(.caption)
                            .foregroundStyle(MaiandrosTheme.secondaryText)
                    }
                    Spacer()
                    MeanderAvatar(size: .small)
                }
                Text("\(trip.daysUntilDeparture) days left")
                    .foregroundStyle(MaiandrosTheme.secondaryText)
                Text("\(trip.itemsRemaining) items remaining")
                    .font(.subheadline)
                Text("Next: \(trip.nextImportantTask?.title ?? MeanderQuoteService.line(for: .upcomingTask, seed: trip.id.uuidString))")
                    .font(.footnote)
                    .foregroundStyle(MaiandrosTheme.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
