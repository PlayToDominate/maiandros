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
        let tilt = Angle(degrees: -8)

        ZStack {
            // Sticker halo
            Circle()
                .fill(Color.white.opacity(0.95))
                .frame(width: d * 1.02, height: d * 1.02)

            ZStack {
                // Soft outer fluff
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.96, green: 0.76, blue: 0.50), Color(red: 0.88, green: 0.60, blue: 0.36)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: d * 0.90, height: d * 0.90)

                // Ears, slightly asymmetric
                HStack(spacing: d * 0.28) {
                    RoundedRectangle(cornerRadius: d * 0.18, style: .continuous)
                        .fill(Color(red: 0.84, green: 0.53, blue: 0.30))
                        .frame(width: d * 0.18, height: d * 0.26)
                        .rotationEffect(.degrees(-32))
                    RoundedRectangle(cornerRadius: d * 0.18, style: .continuous)
                        .fill(Color(red: 0.86, green: 0.56, blue: 0.33))
                        .frame(width: d * 0.17, height: d * 0.24)
                        .rotationEffect(.degrees(22))
                }
                .offset(x: d * 0.02, y: -d * 0.23)

                // Face pad
                Ellipse()
                    .fill(Color(red: 0.99, green: 0.89, blue: 0.74))
                    .frame(width: d * 0.72, height: d * 0.70)
                    .offset(x: d * 0.01, y: d * 0.02)

                // Fluffy bangs (clustered blobs, not bars)
                ZStack {
                    Circle().fill(Color(red: 0.90, green: 0.62, blue: 0.36)).frame(width: d * 0.20)
                    Circle().fill(Color(red: 0.88, green: 0.59, blue: 0.34)).frame(width: d * 0.18).offset(x: -d * 0.12, y: d * 0.02)
                    Circle().fill(Color(red: 0.90, green: 0.61, blue: 0.35)).frame(width: d * 0.17).offset(x: d * 0.13, y: d * 0.03)
                    Circle().fill(Color(red: 0.92, green: 0.65, blue: 0.39)).frame(width: d * 0.16).offset(x: d * 0.02, y: d * 0.07)
                }
                .offset(x: -d * 0.03, y: -d * 0.17)

                // Eyes: larger + warmer + highlight
                HStack(spacing: d * 0.18) {
                    eye(d)
                    eye(d)
                }
                .offset(x: d * 0.015, y: -d * 0.01)

                // Snout: soft rounded oval
                Ellipse()
                    .fill(Color(red: 0.94, green: 0.80, blue: 0.65))
                    .frame(width: d * 0.30, height: d * 0.18)
                    .offset(x: d * 0.015, y: d * 0.16)

                // Nostrils + smile hint
                HStack(spacing: d * 0.08) {
                    Circle().fill(Color(red: 0.49, green: 0.34, blue: 0.24)).frame(width: d * 0.024)
                    Circle().fill(Color(red: 0.49, green: 0.34, blue: 0.24)).frame(width: d * 0.024)
                }
                .offset(x: d * 0.015, y: d * 0.16)

                Capsule()
                    .fill(Color(red: 0.64, green: 0.45, blue: 0.31).opacity(0.35))
                    .frame(width: d * 0.10, height: d * 0.016)
                    .offset(x: d * 0.015, y: d * 0.205)

                // Cozy scarf hint
                RoundedRectangle(cornerRadius: d * 0.09, style: .continuous)
                    .fill(Color(red: 0.86, green: 0.47, blue: 0.33))
                    .frame(width: d * 0.48, height: d * 0.11)
                    .offset(x: d * 0.00, y: d * 0.31)
                    .opacity(size == .small ? 0.6 : 1.0)
            }
            .rotationEffect(tilt)
        }
        .frame(width: d, height: d)
        .shadow(color: .black.opacity(0.10), radius: d * 0.08, y: d * 0.05)
    }

    private func eye(_ d: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            Circle()
                .fill(Color(red: 0.24, green: 0.18, blue: 0.13))
                .frame(width: d * 0.10, height: d * 0.10)
            Circle()
                .fill(Color.white.opacity(0.95))
                .frame(width: d * 0.026, height: d * 0.026)
                .offset(x: d * 0.018, y: d * 0.014)
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
