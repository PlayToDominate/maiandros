import SwiftUI

enum MaiandrosTheme {
    static let background = Color(red: 0.98, green: 0.96, blue: 0.92)
    static let card = Color(red: 1.0, green: 0.99, blue: 0.96)
    static let cardAlt = Color(red: 0.95, green: 0.93, blue: 0.88)
    static let primaryText = Color(red: 0.20, green: 0.20, blue: 0.18)
    static let secondaryText = Color(red: 0.42, green: 0.40, blue: 0.35)
    static let accent = Color(red: 0.85, green: 0.49, blue: 0.35)
    static let success = Color(red: 0.25, green: 0.56, blue: 0.36)
    static let warning = Color(red: 0.79, green: 0.31, blue: 0.27)
}

struct CozyCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(MaiandrosTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.06), radius: 8, y: 4)
    }
}
