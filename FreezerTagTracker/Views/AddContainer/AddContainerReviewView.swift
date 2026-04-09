import SwiftUI

struct AddContainerReviewView: View {
    let draft: AddContainerDraft
    let isSubmitting: Bool
    let onWrite: () -> Void
    let onGoBack: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Step 2 of 2")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.secondary)

                    Text("Review and write")
                        .font(.largeTitle.weight(.bold))

                    Text("Check these details, then hold your iPhone near the tag.")
                        .font(.body)
                        .foregroundStyle(Color.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Step 2 of 2. Review and write. Check these details, then hold your iPhone near the tag.")
                .accessibilitySortPriority(3)

                VStack(alignment: .leading, spacing: 12) {
                    Text("What will be saved")
                        .font(.headline)

                    ContainerSummaryCard(items: draft.summaryItems())
                }
                .accessibilityElement(children: .contain)
                .accessibilitySortPriority(2)

                VStack(alignment: .leading, spacing: 14) {
                    Button(action: onWrite) {
                        HStack(spacing: 12) {
                            if isSubmitting {
                                ProgressView()
                                    .tint(Color.white)
                            }

                            Text(isSubmitting ? "Writing to tag..." : "Write to tag")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, minHeight: 60)
                    }
                    .buttonStyle(ReviewPrimaryActionButtonStyle())
                    .disabled(isSubmitting)
                    .accessibilityHint("Starts the tag writing step.")
                    .accessibilityIdentifier("addContainer.writeButton")

                    Button("Go back and change", action: onGoBack)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibilityHint("Returns to the previous screen to edit the details.")
                        .accessibilityIdentifier("addContainer.goBackAndChangeButton")
                }
                .accessibilityElement(children: .contain)
                .accessibilitySortPriority(1)
            }
            .padding(20)
        }
        .accessibilityIdentifier("addContainer.review.screen")
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

private struct ReviewPrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.white)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(configuration.isPressed ? Color.blue.opacity(0.85) : Color.blue)
            )
            .opacity(configuration.isPressed ? 0.92 : 1)
    }
}

#Preview {
    AddContainerReviewView(
        draft: AddContainerDraft(
            foodName: "Beef stew",
            foodCategory: .beef,
            bestQualityDate: Date(),
            notes: "Family dinner leftovers"
        ),
        isSubmitting: false,
        onWrite: {},
        onGoBack: {}
    )
}
