import SwiftUI

struct AboutMeanderView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 14) {
                    MeanderAvatar(size: .large)
                    Text("Welcome to Maiandros")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                    Text("Maiandros is a quiet little travel companion designed to make trips feel lighter before they even begin.")
                        .font(.title3)
                        .foregroundStyle(MaiandrosTheme.secondaryText)
                }
                .padding(.top, 10)

                MeanderCalloutCard(line: "Meander keeps an eye on the little things so excitement doesn't get buried under mental clutter.")

                VStack(alignment: .leading, spacing: 12) {
                    Text("little steps now, easier travel later")
                        .font(.title3.italic())
                    Text("Trips are full of tiny loose ends: chargers, screenshots, reservations, socks. Maiandros helps gather those little pieces gently, one at a time.")
                        .foregroundStyle(MaiandrosTheme.secondaryText)
                }
                .padding(.horizontal, 2)

                CozyCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("What Lives Here")
                            .font(.headline)
                        Text("Trips. Countdowns. Cabinet snippets. Packing. Little memories.")
                            .foregroundStyle(MaiandrosTheme.secondaryText)
                    }
                }
            }
            .padding()
        }
        .background(MaiandrosTheme.background.ignoresSafeArea())
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}
