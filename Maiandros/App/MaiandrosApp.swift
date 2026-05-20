import SwiftUI

@main
struct MaiandrosApp: App {
    @StateObject private var store = TripStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(store)
                .preferredColorScheme(.light)
        }
    }
}
