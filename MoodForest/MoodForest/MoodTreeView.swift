import SwiftUI

struct MoodTreeView: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("Your Mood Tree")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                ScrollView([.vertical, .horizontal]) {
                    TreeCanvas()
                        .frame(width: 600, height: 400)
                        .padding()
                }

            }
        }
    }
}

struct TreeCanvas: View {
    var body: some View {
        Canvas { context, size in
            let trunkHeight: CGFloat = 120
            let center = CGPoint(x: size.width / 2, y: size.height - trunkHeight)

            // Draw main trunk
            var trunk = Path()
            trunk.move(to: CGPoint(x: center.x, y: size.height))
            trunk.addLine(to: center)
            context.stroke(trunk, with: .color(.brown), lineWidth: 12)

            // Draw 6 main branches
            let startAngles: [Double] = [-90, -110, -70, -130, -50, -150]
            for angle in startAngles {
                drawBranch(context: &context, from: center, angle: angle, length: 80, depth: 6)
            }
        }
    }

    func drawBranch(context: inout GraphicsContext, from: CGPoint, angle: Double, length: CGFloat, depth: Int) {
        guard depth > 0 else { return }

        let radians = CGFloat(angle * .pi / 180)
        let endX = from.x + cos(radians) * length
        let endY = from.y + sin(radians) * length
        let to = CGPoint(x: endX, y: endY)

        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        context.stroke(path, with: .color(.brown), lineWidth: CGFloat(depth))

        if depth == 1 {
            let leafSize: CGFloat = 10
            let leafRect = CGRect(x: to.x - leafSize / 2, y: to.y - leafSize / 2, width: leafSize, height: leafSize)
            context.fill(Ellipse().path(in: leafRect), with: .color(.green))
        } else {
            drawBranch(context: &context, from: to, angle: angle - 20, length: length * 0.7, depth: depth - 1)
            drawBranch(context: &context, from: to, angle: angle + 20, length: length * 0.7, depth: depth - 1)
        }
    }
}
