import SwiftUI

@main
struct MaiandrosApp: App {
    @StateObject private var store = TripStore()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                HomeView()
                    .environmentObject(store)
                    .preferredColorScheme(.light)
                    .opacity(showSplash ? 0 : 1)

                if showSplash {
                    SplashView()
                        .transition(.opacity)
                }
            }
            .task {
                try? await Task.sleep(for: .milliseconds(1200))
                withAnimation(.easeOut(duration: 0.35)) {
                    showSplash = false
                }
            }
        }
    }
}
