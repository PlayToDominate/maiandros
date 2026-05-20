import SwiftUI

struct AboutMeanderView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                MeanderCalloutCard(line: "Meander is your soft travel buddy: calm nudges, kind reminders, and zero judgment.")

                CozyCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("About Meander")
                            .font(.headline)
                        Text("Meander is a cozy Highland cow companion who helps keep pre-trip stress from piling up.")
                            .foregroundStyle(MaiandrosTheme.secondaryText)
                        Text("She is a little mischievous, very reassuring, and always on your side.")
                            .foregroundStyle(MaiandrosTheme.secondaryText)
                    }
                }

                CozyCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("How Maiandros Helps")
                            .font(.headline)
                        Text("- gentle countdown\n- calm readiness checklist\n- flexible Cabinet for trip snippets\n- packing progress without pressure")
                            .foregroundStyle(MaiandrosTheme.secondaryText)
                    }
                }

                CozyCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("App Philosophy")
                            .font(.headline)
                        Text("little steps now, easier travel later")
                            .italic()
                        Text("You do not need perfect planning. You just need fewer loose threads in your brain.")
                            .foregroundStyle(MaiandrosTheme.secondaryText)
                    }
                }
            }
            .padding()
        }
        .background(MaiandrosTheme.background.ignoresSafeArea())
        .navigationTitle("About Meander")
    }
}
