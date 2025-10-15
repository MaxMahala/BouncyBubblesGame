import SwiftUI

struct LoadingView: View {
    var title: String = "Bouncy Bubbles"
    var subtitle: String = "Preparing the galaxy..."

    @State private var appear = false

    var body: some View {
        ZStack {
            Image(.loadingBack)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            LinearGradient(
                colors: [.black.opacity(0.65), .black.opacity(0.3), .black.opacity(0.65)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 42, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.6), radius: 10, x: 0, y: 4)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 10)
                    .animation(.easeOut(duration: 0.5), value: appear)

                Text(subtitle)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.bottom, 10)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 8)
                    .animation(.easeOut(duration: 0.6).delay(0.1), value: appear)

                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.2)
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.2), value: appear)
            }
            .padding(.horizontal, 24)
        }
        .onAppear { appear = true }
    }
}
