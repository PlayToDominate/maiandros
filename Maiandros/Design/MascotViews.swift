import SwiftUI

struct MeanderBadge: View {
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(red: 0.98, green: 0.88, blue: 0.74))
                .frame(width: 38, height: 38)
                .overlay {
                    Text("🐮")
                        .font(.system(size: 20))
                }
            Text("Meander")
                .font(.caption.weight(.semibold))
                .foregroundStyle(MaiandrosTheme.secondaryText)
        }
        .padding(8)
        .background(MaiandrosTheme.cardAlt)
        .clipShape(Capsule())
    }
}

struct MeanderCalloutCard: View {
    let line: String

    var body: some View {
        CozyCard {
            HStack(alignment: .top, spacing: 12) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(red: 0.98, green: 0.88, blue: 0.74))
                    .frame(width: 52, height: 52)
                    .overlay { Text("🐮").font(.title3) }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Meander")
                        .font(.subheadline.weight(.semibold))
                    Text(line)
                        .font(.footnote)
                        .foregroundStyle(MaiandrosTheme.secondaryText)
                }
                Spacer()
            }
        }
    }
}
