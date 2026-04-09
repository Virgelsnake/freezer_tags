import SwiftUI

struct TagWritingView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "iphone.radiowaves.left.and.right")
                .font(.system(size: 64))
                .foregroundStyle(Color.blue)
                .accessibilityHidden(true)

            VStack(spacing: 12) {
                Text("Hold your phone near the tag")
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)

                Text("Keep the top of your iPhone close to the container tag until you feel confirmation.")
                    .font(.body)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }

            ProgressView()
                .controlSize(.large)

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    TagWritingView()
}
