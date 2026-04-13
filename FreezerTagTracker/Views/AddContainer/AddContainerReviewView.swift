import SwiftUI

struct AddContainerReviewView: View {
    let draft: AddContainerDraft
    let language: AppLanguage
    let isSubmitting: Bool
    let canReadDetailsAgain: Bool
    let onReadDetailsAgain: () -> Void
    let onWrite: () -> Void
    let onGoBack: () -> Void
    let onAppear: () -> Void

    private var strings: AppStrings {
        language.strings
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(strings.step2Of2)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.secondary)

                    Text(strings.reviewAndWrite)
                        .font(.largeTitle.weight(.bold))

                    Text(strings.reviewSubtitle)
                        .font(.body)
                        .foregroundStyle(Color.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(strings.reviewAccessibilityHeader)
                .accessibilitySortPriority(3)

                VStack(alignment: .leading, spacing: 12) {
                    Text(strings.whatWillBeSaved)
                        .font(.headline)

                    ContainerSummaryCard(items: draft.summaryItems(in: language))
                }
                .accessibilityElement(children: .contain)
                .accessibilitySortPriority(2)

                VStack(alignment: .leading, spacing: 12) {
                    if canReadDetailsAgain {
                        Button(action: onReadDetailsAgain) {
                            reviewSecondaryActionLabel(
                                title: strings.readDetailsAgain,
                                systemImage: "speaker.wave.2.fill"
                            )
                        }
                            .buttonStyle(ReviewSecondaryActionButtonStyle())
                            .accessibilityHint(strings.readDetailsAgainHint)
                            .accessibilityIdentifier("addContainer.reviewReadDetailsAgainButton")
                    }

                    Button(action: onWrite) {
                        HStack(spacing: 12) {
                            if isSubmitting {
                                ProgressView()
                                    .tint(Color.white)
                            }

                            Text(isSubmitting ? strings.writingToTag : strings.writeToTag)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, minHeight: 60)
                    }
                    .buttonStyle(ReviewPrimaryActionButtonStyle())
                    .disabled(isSubmitting)
                    .accessibilityHint(strings.writeToTagHint)
                    .accessibilityIdentifier("addContainer.writeButton")

                    Button(action: onGoBack) {
                        reviewSecondaryActionLabel(
                            title: strings.goBackAndChange,
                            systemImage: "arrow.uturn.backward"
                        )
                    }
                        .buttonStyle(ReviewSecondaryActionButtonStyle())
                        .accessibilityHint(strings.goBackHint)
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
        .onAppear(perform: onAppear)
    }

    @ViewBuilder
    private func reviewSecondaryActionLabel(title: String, systemImage: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))

            Text(title)
                .font(.headline)
        }
        .foregroundStyle(Color.blue)
        .frame(maxWidth: .infinity, minHeight: 60)
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

private struct ReviewSecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.blue.opacity(configuration.isPressed ? 0.18 : 0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.blue.opacity(0.35), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.9 : 1)
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
        language: .english,
        isSubmitting: false,
        canReadDetailsAgain: true,
        onReadDetailsAgain: {},
        onWrite: {},
        onGoBack: {},
        onAppear: {}
    )
    .environmentObject(SettingsViewModel())
}
