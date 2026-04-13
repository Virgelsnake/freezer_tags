import SwiftUI

struct TagWritingView: View {
    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion
    let language: AppLanguage

    private var strings: AppStrings {
        language.strings
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "iphone.radiowaves.left.and.right")
                .font(.system(size: 64))
                .foregroundStyle(Color.blue)
                .accessibilityHidden(true)

            VStack(spacing: 12) {
                Text(strings.holdPhoneNearTag)
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)

                Text(strings.holdPhoneNearTagSubtitle)
                    .font(.body)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }

            if accessibilityReduceMotion {
                Label(strings.writingInProgress, systemImage: "hourglass")
                    .font(.headline)
                    .foregroundStyle(Color.secondary)
                    .accessibilityHint(strings.reducedMotionWritingHint)
            } else {
                ProgressView()
                    .controlSize(.large)
                    .accessibilityLabel(strings.writingInProgress)
            }

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("addContainer.writing.screen")
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    TagWritingView(language: .english)
}
