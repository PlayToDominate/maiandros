import SwiftUI

struct SplashView: View {
    @State private var appear = false

    var body: some View {
        ZStack {
            MaiandrosTheme.background.ignoresSafeArea()
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(red: 0.98, green: 0.88, blue: 0.74))
                    .frame(width: 84, height: 84)
                    .overlay { Text("🐮").font(.system(size: 38)) }
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
