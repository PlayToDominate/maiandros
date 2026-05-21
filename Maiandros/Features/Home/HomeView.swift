import SwiftUI
import UIKit
import UserNotifications

struct HomeView: View {
    @EnvironmentObject private var store: TripStore
    @State private var showingCreate = false
    @State private var showingMeanderHub = false
    @StateObject private var notificationCenter = MeanderNotificationCenter()

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
                            showingMeanderHub = true
                        } label: {
                            MeanderAvatarWithBadge(size: .medium, count: notificationCenter.unreadCount)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Open Meander")
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
            .sheet(isPresented: $showingMeanderHub) {
                MeanderHubView(center: notificationCenter)
            }
            .task {
                await notificationCenter.refresh()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                Task { await notificationCenter.refresh() }
            }
        }
    }
}

private struct MeanderHubView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var center: MeanderNotificationCenter
    @State private var tab: MeanderHubTab = .about

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                Picker("Meander", selection: $tab) {
                    Text("About").tag(MeanderHubTab.about)
                    Text("Notifications").tag(MeanderHubTab.notifications)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)

                if tab == .about {
                    AboutMeanderContent()
                } else {
                    NotificationsTabView(center: center)
                }
            }
            .background(MaiandrosTheme.background.ignoresSafeArea())
            .navigationTitle("Meander")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                await center.refresh()
                if center.unreadCount > 0 {
                    tab = .notifications
                }
            }
        }
    }
}

private enum MeanderHubTab {
    case about
    case notifications
}

private struct NotificationsTabView: View {
    @ObservedObject var center: MeanderNotificationCenter

    var body: some View {
        List {
            if center.delivered.isEmpty {
                VStack(spacing: 10) {
                    MeanderAvatar(size: .medium)
                    Text("No notifications right now.")
                        .font(.subheadline.weight(.semibold))
                    Text("Meander will tuck reminders here when they arrive.")
                        .font(.footnote)
                        .foregroundStyle(MaiandrosTheme.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .listRowBackground(Color.clear)
            } else {
                ForEach(center.delivered) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.title)
                            .font(.subheadline.weight(.semibold))
                        Text(item.body)
                            .font(.footnote)
                            .foregroundStyle(MaiandrosTheme.secondaryText)
                        Text(item.date, format: .dateTime.month(.abbreviated).day().hour().minute())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { offsets in
                    let ids = offsets.map { center.delivered[$0].id }
                    Task { await center.clear(ids: ids) }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .safeAreaInset(edge: .bottom) {
            if !center.delivered.isEmpty {
                Button("Clear All") {
                    Task { await center.clearAll() }
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 8)
            }
        }
    }
}

struct MeanderNotificationItem: Identifiable, Equatable {
    let id: String
    let title: String
    let body: String
    let date: Date
}

@MainActor
final class MeanderNotificationCenter: ObservableObject {
    @Published var delivered: [MeanderNotificationItem] = []

    var unreadCount: Int { delivered.count }

    private let center = UNUserNotificationCenter.current()

    func refresh() async {
        let notifications = await center.deliveredNotifications()
        let items = notifications
            .filter { $0.request.identifier.hasPrefix("maiandros-trip-reminder") }
            .map {
                MeanderNotificationItem(
                    id: $0.request.identifier,
                    title: $0.request.content.title,
                    body: $0.request.content.body,
                    date: $0.date
                )
            }
            .sorted { $0.date > $1.date }
        delivered = items
        UIApplication.shared.applicationIconBadgeNumber = items.count
    }

    func clear(ids: [String]) async {
        center.removeDeliveredNotifications(withIdentifiers: ids)
        await refresh()
    }

    func clearAll() async {
        center.removeDeliveredNotifications(withIdentifiers: delivered.map(\.id))
        await refresh()
    }
}

private extension UNUserNotificationCenter {
    func deliveredNotifications() async -> [UNNotification] {
        await withCheckedContinuation { continuation in
            getDeliveredNotifications { notifications in
                continuation.resume(returning: notifications)
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
