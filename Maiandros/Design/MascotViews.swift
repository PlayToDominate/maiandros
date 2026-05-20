import SwiftUI

enum MeanderAvatarSize {
    case small
    case medium
    case large

    var dimension: CGFloat {
        switch self {
        case .small: return 34
        case .medium: return 54
        case .large: return 96
        }
    }

    var imageName: String {
        switch self {
        case .small: return "Meander128"
        case .medium: return "Meander256"
        case .large: return "Meander512"
        }
    }
}

struct MeanderAvatar: View {
    var size: MeanderAvatarSize = .medium

    var body: some View {
        Image(size.imageName)
            .resizable()
            .interpolation(.high)
            .antialiased(true)
            .scaledToFill()
            .frame(width: size.dimension, height: size.dimension)
            .clipShape(RoundedRectangle(cornerRadius: size.dimension * 0.26, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: size.dimension * 0.26, style: .continuous)
                    .stroke(Color.white.opacity(0.85), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.12), radius: size.dimension * 0.08, y: size.dimension * 0.05)
    }
}

struct MeanderAvatarWithBadge: View {
    var size: MeanderAvatarSize = .medium
    var count: Int

    var body: some View {
        ZStack(alignment: .topTrailing) {
            MeanderAvatar(size: size)

            if count > 0 {
                Text("\(min(count, 99))")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.red)
                    .clipShape(Capsule())
                    .offset(x: 6, y: -6)
                    .accessibilityLabel("\(count) notifications")
            }
        }
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
