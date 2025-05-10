import SwiftUI

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MoodTreeView: View {
    @State private var positivePct: Int = 0
    @State private var neutralPct: Int = 0
    @State private var negativePct: Int = 0

    var body: some View {
        ScrollView {
            VStack {
                Text("Your Mood Tree")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                ScrollView([.vertical, .horizontal]) {
                    TreeCanvas(
                        positivePct: positivePct,
                        neutralPct: neutralPct,
                        negativePct: negativePct
                    )
                    .frame(width: 600, height: 500)
                    .padding()
                }

                Text("Last mood entry: negativePct \(negativePct)%, neutralPct \(neutralPct)%, positivePct \(positivePct)%")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom)
            }
            .onAppear {
                fetchLastMoodEntry()
            }
        }
    }

    func fetchLastMoodEntry() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("moods")
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let doc = snapshot?.documents.first {
                    if let moods = doc.data()["moods"] as? [String: Int] {
                        let total = moods.values.reduce(0, +)
                        if total > 0 {
                            let positiveMoods = ["joy", "calm", "inspired", "inLove", "gratitude", "pride", "hopeful", "energetic"]
                            let negativeMoods = ["sadness", "anger", "fear", "anxiety", "loneliness", "tiredness", "disappointment", "guilt"]
                            let neutralMoods = ["boredom", "confusion", "emptiness", "apathy", "surprised", "mixedFeelings"]

                            let pos = positiveMoods.map { moods[$0] ?? 0 }.reduce(0, +)
                            let neg = negativeMoods.map { moods[$0] ?? 0 }.reduce(0, +)
                            let neu = neutralMoods.map { moods[$0] ?? 0 }.reduce(0, +)

                            positivePct = Int(round(Double(pos) / Double(total) * 100))
                            neutralPct = Int(round(Double(neu) / Double(total) * 100))
                            negativePct = Int(round(Double(neg) / Double(total) * 100))
                        }
                    }
                }
            }
    }
}

struct TreeCanvas: View {
    let positivePct: Int
    let neutralPct: Int
    let negativePct: Int

    var body: some View {
        Canvas { context, size in
            let trunkHeight: CGFloat = 180
            let center = CGPoint(x: size.width / 2, y: size.height - trunkHeight)

            // Draw trunk
            var trunk = Path()
            trunk.move(to: CGPoint(x: center.x, y: size.height))
            trunk.addLine(to: center)
            context.stroke(trunk, with: .color(.brown), lineWidth: 12)

            // Draw 6 main branches
            let startAngles: [Double] = [-90, -110, -70, -130, -50, -150]
            var leafIndex = 0
            let totalLeaves = countTotalLeaves(depth: 6)

            let cutoffPositive = Int(round(Double(totalLeaves) * Double(positivePct) / 100))
            let cutoffNeutral = Int(round(Double(totalLeaves) * Double(neutralPct) / 100))

            for angle in startAngles {
                drawBranch(
                    context: &context,
                    from: center,
                    angle: angle,
                    length: 80,
                    depth: 6,
                    leafIndex: &leafIndex,
                    cutoffPositive: cutoffPositive,
                    cutoffNeutral: cutoffNeutral
                )
            }
        }
    }

    func drawBranch(
        context: inout GraphicsContext,
        from: CGPoint,
        angle: Double,
        length: CGFloat,
        depth: Int,
        leafIndex: inout Int,
        cutoffPositive: Int,
        cutoffNeutral: Int
    ) {
        guard depth > 0 else { return }

        let radians = CGFloat(angle * .pi / 180)
        let to = CGPoint(
            x: from.x + cos(radians) * length,
            y: from.y + sin(radians) * length
        )

        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        context.stroke(path, with: .color(.brown), lineWidth: CGFloat(depth))

        if depth == 1 {
            // Color leaves based on leafIndex boundaries
            let color: Color
            if leafIndex < cutoffPositive {
                color = .green
            } else if leafIndex < cutoffPositive + cutoffNeutral {
                color = .brown
            } else {
                color = .black
            }

            let leafSize: CGFloat = 10
            let leafRect = CGRect(
                x: to.x - leafSize / 2,
                y: to.y - leafSize / 2,
                width: leafSize,
                height: leafSize
            )
            context.fill(Ellipse().path(in: leafRect), with: .color(color))
            leafIndex += 1
        } else {
            drawBranch(context: &context, from: to, angle: angle - 20, length: length * 0.7, depth: depth - 1, leafIndex: &leafIndex, cutoffPositive: cutoffPositive, cutoffNeutral: cutoffNeutral)
            drawBranch(context: &context, from: to, angle: angle + 20, length: length * 0.7, depth: depth - 1, leafIndex: &leafIndex, cutoffPositive: cutoffPositive, cutoffNeutral: cutoffNeutral)
        }
    }

    func countTotalLeaves(depth: Int) -> Int {
        // Binary tree leaf count: 2^(depth - 1)
        // Each main branch has this many leaves at the bottom
        let leavesPerBranch = Int(pow(2.0, Double(depth - 1)))
        return leavesPerBranch * 6 // 6 branches
    }
}
