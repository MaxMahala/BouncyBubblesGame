import SwiftUI
import SpriteKit

struct GameView: View {
    @StateObject private var vm = GameViewModel()
    
    private let scene: GameScene = {
        let s = GameScene(size: UIScreen.main.bounds.size)
        s.scaleMode = .resizeFill
        return s
    }()

    var body: some View {
        ZStack {
            SpriteView(scene: scene, preferredFramesPerSecond: 60)
                .ignoresSafeArea()
                .onAppear {
                    vm.attach(scene: scene)
                    vm.startLoading()
                }
            
            HStack(spacing: 12) {
                Text("Score: \(vm.score)")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.4))
                    .clipShape(Capsule())
                    .foregroundColor(.white)
                    .padding(.leading, 16)
                
                Spacer()
                
                Button {
                    vm.togglePause()
                } label: {
                    Image(systemName: vm.isPaused ? "play.fill" : "pause.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .bold))
                        .padding(12)
                        .frame(width: 50, height: 50)
                        .background(Color.white.opacity(0.4))
                        .clipShape(Circle())
                }
                Button {
                    vm.toggleMusic()
                } label: {
                    Image(systemName: vm.musicOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .bold))
                        .padding(12)
                        .frame(width: 50, height: 50)
                        .background(Color.white.opacity(0.4))
                        .clipShape(Circle())
                }
            }
            .padding(.top, 20)
            .padding(.trailing, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            
            if vm.isLoading {
                LoadingView()
                .transition(.opacity)
            }
        }
    }
}

#Preview {
    GameView()
}

