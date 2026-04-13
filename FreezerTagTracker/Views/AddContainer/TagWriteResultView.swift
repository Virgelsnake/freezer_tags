import SwiftUI

struct TagWriteResultView: View {
    let language: AppLanguage
    let result: TagWriteResult
    let canReadDetailsAgain: Bool
    let onReadDetailsAgain: () -> Void
    let onDone: () -> Void
    let onTryAgain: () -> Void
    let onGoBack: () -> Void

    private var strings: AppStrings {
        language.strings
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                statusHeader

                if case .failure(let message) = result {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                }

                actionSection
            }
            .padding(24)
        }
        .accessibilityIdentifier("addContainer.result.screen")
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    @ViewBuilder
    private var statusHeader: some View {
        switch result {
        case .success(let record):
            VStack(alignment: .leading, spacing: 16) {
                statusBadge(title: strings.saved, systemImage: "checkmark.circle.fill", color: .green)

                Text(strings.savedToContainerTitle)
                    .font(.largeTitle.weight(.bold))

                Text(strings.savedToContainerMessage(foodName: record.foodName))
                    .font(.body)
                    .foregroundStyle(Color.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(strings.savedToContainerMessage(foodName: record.foodName))
        case .failure:
            VStack(alignment: .leading, spacing: 16) {
                statusBadge(title: strings.needsAttention, systemImage: "xmark.circle.fill", color: .red)

                Text(strings.saveFailedTitle)
                    .font(.largeTitle.weight(.bold))

                Text(strings.saveFailedMessage)
                    .font(.body)
                    .foregroundStyle(Color.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(strings.saveFailedTitle). \(strings.saveFailedMessage)")
        }
    }

    private func statusBadge(title: String, systemImage: String, color: Color) -> some View {
        Label(title, systemImage: systemImage)
            .font(.headline.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(color.opacity(0.12))
            )
    }

    @ViewBuilder
    private var actionSection: some View {
        switch result {
        case .success:
            VStack(alignment: .leading, spacing: 14) {
                Button(action: onDone) {
                    Text(strings.done)
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 60)
                }
                .buttonStyle(ResultPrimaryActionButtonStyle())
                .accessibilityIdentifier("addContainer.doneButton")

                if canReadDetailsAgain {
                    Button(action: onReadDetailsAgain) {
                        Text(strings.readDetailsAgain)
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .foregroundStyle(Color.blue)
                    .accessibilityHint(strings.replaySavedDetailsHint)
                    .accessibilityIdentifier("addContainer.readDetailsAgainButton")
                }
            }
        case .failure:
            VStack(alignment: .leading, spacing: 14) {
                Button(action: onTryAgain) {
                    Text(strings.tryAgain)
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 60)
                }
                .buttonStyle(ResultPrimaryActionButtonStyle())
                .accessibilityIdentifier("addContainer.tryAgainButton")

                Button(strings.goBack, action: onGoBack)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibilityHint(strings.goBackToReviewHint)
                    .accessibilityIdentifier("addContainer.goBackButton")
            }
        }
    }
}

private struct ResultPrimaryActionButtonStyle: ButtonStyle {
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
    TagWriteResultView(
        language: .english,
        result: .success(record: ContainerRecord(tagID: "preview-tag", foodName: "Beef stew", dateFrozen: Date())),
        canReadDetailsAgain: true,
        onReadDetailsAgain: {},
        onDone: {},
        onTryAgain: {},
        onGoBack: {}
    )
}
