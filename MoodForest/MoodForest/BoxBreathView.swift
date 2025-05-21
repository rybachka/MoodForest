import SwiftUI

struct BoxBreathView: View {
    @State private var phase = 0
    @State private var progress: CGFloat = 0.0
    @State private var currentCycle = 0
    @State private var showCompletionMessage = false
    @State private var timer: Timer?

    let phases = ["Inhale", "Hold", "Exhale", "Hold"]
    let totalPhases = 12 // 3 full boxes = 12 phases (4 phases per box)

    var body: some View {
        VStack(spacing: 30) {
            Text("Box Breathing")
                .font(.largeTitle)
                .bold()

            ZStack {
                Rectangle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                    .frame(width: 200, height: 200)

                GeometryReader { geo in
                    Path { path in
                        let size = min(geo.size.width, geo.size.height)
                        let length = size
                        switch phase {
                        case 0: // top
                            path.move(to: .zero)
                            path.addLine(to: CGPoint(x: length * progress, y: 0))
                        case 1: // right
                            path.move(to: CGPoint(x: length, y: 0))
                            path.addLine(to: CGPoint(x: length, y: length * progress))
                        case 2: // bottom
                            path.move(to: CGPoint(x: length, y: length))
                            path.addLine(to: CGPoint(x: length - length * progress, y: length))
                        case 3: // left
                            path.move(to: CGPoint(x: 0, y: length))
                            path.addLine(to: CGPoint(x: 0, y: length - length * progress))
                        default:
                            break
                        }
                    }
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                }
                .frame(width: 200, height: 200)
            }
            .frame(width: 200, height: 200)

            Text(phases[phase])
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.blue)

            ProgressView(value: Double(currentCycle), total: Double(totalPhases))
                .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                .frame(width: 200)

            if showCompletionMessage {
                Text("The exercise is over, well done.")
                    .font(.headline)
                    .foregroundColor(.green)
                    .transition(.opacity)
                    .padding(.top, 10)

                Button("Restart") {
                    resetExercise()
                }
                .font(.headline)
                .padding()
                .frame(width: 140)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else {
                Button("Start") {
                    startBreathing()
                }
                .font(.headline)
                .padding()
                .frame(width: 140)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .onDisappear {
            timer?.invalidate()
        }
    }

    func startBreathing() {
        progress = 0.0
        phase = 0
        currentCycle = 0
        showCompletionMessage = false
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            progress += 0.0125 // ≈ 80 steps * 0.05s = 4s
            if progress >= 1.0 {
                progress = 0.0
                phase = (phase + 1) % 4
                currentCycle += 1

                if currentCycle >= totalPhases {
                    timer?.invalidate()
                    showCompletionMessage = true
                }
            }
        }
    }

    func resetExercise() {
        progress = 0.0
        phase = 0
        currentCycle = 0
        showCompletionMessage = false
        startBreathing()
    }
}
