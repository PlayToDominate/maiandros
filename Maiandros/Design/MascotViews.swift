import SwiftUI

enum MeanderAvatarSize {
    case small
    case medium
    case large

    var dimension: CGFloat {
        switch self {
        case .small: return 34
        case .medium: return 54
        case .large: return 86
        }
    }
}

struct MeanderAvatar: View {
    var size: MeanderAvatarSize = .medium

    var body: some View {
        let d = size.dimension

        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.99, green: 0.91, blue: 0.78), Color(red: 0.93, green: 0.72, blue: 0.49)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Ears
            HStack(spacing: d * 0.32) {
                RoundedRectangle(cornerRadius: d * 0.14, style: .continuous)
                    .fill(Color(red: 0.84, green: 0.56, blue: 0.32))
                    .frame(width: d * 0.18, height: d * 0.22)
                    .rotationEffect(.degrees(-22))
                RoundedRectangle(cornerRadius: d * 0.14, style: .continuous)
                    .fill(Color(red: 0.84, green: 0.56, blue: 0.32))
                    .frame(width: d * 0.18, height: d * 0.22)
                    .rotationEffect(.degrees(22))
            }
            .offset(y: -d * 0.26)

            // Face
            Circle()
                .fill(Color(red: 0.98, green: 0.88, blue: 0.72))
                .frame(width: d * 0.78, height: d * 0.78)

            // Fluffy bangs
            HStack(spacing: d * 0.04) {
                ForEach(0..<4, id: \.self) { idx in
                    Capsule()
                        .fill(Color(red: 0.88, green: 0.62, blue: 0.37))
                        .frame(width: d * 0.12, height: d * 0.16)
                        .rotationEffect(.degrees(Double(idx) * 6 - 9))
                }
            }
            .offset(y: -d * 0.17)

            // Eyes
            HStack(spacing: d * 0.22) {
                Circle().fill(Color(red: 0.29, green: 0.22, blue: 0.16)).frame(width: d * 0.07)
                Circle().fill(Color(red: 0.29, green: 0.22, blue: 0.16)).frame(width: d * 0.07)
            }
            .offset(y: -d * 0.02)

            // Nose
            RoundedRectangle(cornerRadius: d * 0.08, style: .continuous)
                .fill(Color(red: 0.92, green: 0.78, blue: 0.61))
                .frame(width: d * 0.28, height: d * 0.14)
                .offset(y: d * 0.14)

            // Travel scarf accent
            RoundedRectangle(cornerRadius: d * 0.09, style: .continuous)
                .fill(Color(red: 0.87, green: 0.49, blue: 0.34))
                .frame(width: d * 0.48, height: d * 0.12)
                .offset(y: d * 0.32)
        }
        .frame(width: d, height: d)
        .overlay {
            Circle().stroke(Color.black.opacity(0.06), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.08), radius: d * 0.07, y: d * 0.05)
    }
}

struct MeanderBadge: View {
    var body: some View {
        HStack(spacing: 8) {
            MeanderAvatar(size: .small)
            Text("Meander")
                .font(.caption.weight(.semibold))
                .foregroundStyle(MaiandrosTheme.secondaryText)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(MaiandrosTheme.cardAlt)
        .clipShape(Capsule())
    }
}

struct MeanderCalloutCard: View {
    let line: String

    var body: some View {
        CozyCard {
            HStack(alignment: .top, spacing: 12) {
                MeanderAvatar(size: .medium)
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

struct MeanderEmptyState: View {
    let line: String

    var body: some View {
        VStack(spacing: 10) {
            MeanderAvatar(size: .large)
            Text(line)
                .font(.footnote)
                .foregroundStyle(MaiandrosTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 260)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}
