import SwiftUI

struct SplashView: View {
    @State private var appear = false

    var body: some View {
        ZStack {
            MaiandrosTheme.background.ignoresSafeArea()
            VStack(spacing: 16) {
                MeanderAvatar(size: .large)
                    .scaleEffect(appear ? 1.0 : 0.92)
                Text("Maiandros")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                Text("little steps now, easier travel later")
                    .font(.footnote.italic())
                    .foregroundStyle(MaiandrosTheme.secondaryText)
            }
            .opacity(appear ? 1 : 0.7)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                appear = true
            }
        }
    }
}
