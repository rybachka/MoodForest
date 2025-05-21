import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MoodTreeView: View {
    @State private var positivePct: Int = 0
    @State private var neutralPct: Int = 0
    @State private var negativePct: Int = 0

    struct DatedMoodTree: Identifiable {
        let id = UUID()
        let date: Date
        let positive: Int
        let neutral: Int
        let negative: Int
    }

    @State private var forestEntries: [DatedMoodTree] = []

    let positiveMoods = ["joy", "calm", "inspired", "inLove", "gratitude", "pride", "hopeful", "energetic"]
    let negativeMoods = ["sadness", "anger", "fear", "anxiety", "loneliness", "tiredness", "disappointment", "guilt"]
    let neutralMoods  = ["boredom", "confusion", "emptiness", "apathy", "surprised", "mixedFeelings"]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
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

                if !forestEntries.isEmpty {
                    Divider()
                    Text("Your Forest")
                        .font(.title2)
                        .bold()
                        .padding(.top)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(forestEntries) { tree in
                            VStack(spacing: 8) {
                                TreeCanvas(
                                    positivePct: tree.positive,
                                    neutralPct: tree.neutral,
                                    negativePct: tree.negative
                                )
                                .frame(width: 180, height: 180)

                                Text(formattedDate(tree.date))
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                Text("😊 \(tree.positive)% 😐 \(tree.neutral)% 🙁 \(tree.negative)%")
                                    .font(.caption2)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 310)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .padding(4)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .onAppear {
                fetchLastMoodEntry()
                fetchLastFiveMoodEntries()
            }
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
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

    func fetchLastFiveMoodEntries() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("moods")
            .order(by: "timestamp", descending: true)
            .limit(to: 6)
            .getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    self.forestEntries = documents.compactMap { doc in
                        let data = doc.data()
                        guard let ts = data["timestamp"] as? Timestamp,
                              let moods = data["moods"] as? [String: Int] else { return nil }

                        let total = moods.values.reduce(0, +)
                        if total == 0 { return nil }

                        let pos = positiveMoods.map { moods[$0] ?? 0 }.reduce(0, +)
                        let neg = negativeMoods.map { moods[$0] ?? 0 }.reduce(0, +)
                        let neu = neutralMoods.map { moods[$0] ?? 0 }.reduce(0, +)

                        let posPct = Int(round(Double(pos) / Double(total) * 100))
                        let neuPct = Int(round(Double(neu) / Double(total) * 100))
                        let negPct = Int(round(Double(neg) / Double(total) * 100))

                        return DatedMoodTree(date: ts.dateValue(), positive: posPct, neutral: neuPct, negative: negPct)
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
        GeometryReader { geo in
            Canvas { context, size in
                let scale: CGFloat = min(size.width / 600, size.height / 500)
                let trunkHeight: CGFloat = 180 * scale
                let center = CGPoint(x: size.width / 2, y: size.height - trunkHeight / 2)

                var trunk = Path()
                trunk.move(to: CGPoint(x: center.x, y: size.height))
                trunk.addLine(to: CGPoint(x: center.x, y: size.height - trunkHeight))
                context.stroke(trunk, with: .color(.brown), lineWidth: 12 * scale)

                let startAngles: [Double] = [-90, -110, -70, -130, -50, -150]
                var leafIndex = 0
                let totalLeaves = countTotalLeaves(depth: 6)
                let cutoffPositive = Int(Double(totalLeaves) * Double(positivePct) / 100)
                let cutoffNeutral = Int(Double(totalLeaves) * Double(neutralPct) / 100)

                for angle in startAngles {
                    drawBranch(
                        context: &context,
                        from: CGPoint(x: center.x, y: size.height - trunkHeight),
                        angle: angle,
                        length: 80 * scale,
                        depth: 6,
                        leafIndex: &leafIndex,
                        cutoffPositive: cutoffPositive,
                        cutoffNeutral: cutoffNeutral,
                        scale: scale
                    )
                }
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
        cutoffNeutral: Int,
        scale: CGFloat
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
        context.stroke(path, with: .color(.brown), lineWidth: CGFloat(depth) * scale)

        if depth == 1 {
            let color: Color
            if leafIndex < cutoffPositive {
                color = .green
            } else if leafIndex < cutoffPositive + cutoffNeutral {
                color = .brown
            } else {
                color = .black
            }

            let leafSize: CGFloat = 10 * scale
            let leafRect = CGRect(
                x: to.x - leafSize / 2,
                y: to.y - leafSize / 2,
                width: leafSize,
                height: leafSize
            )
            context.fill(Ellipse().path(in: leafRect), with: .color(color))
            leafIndex += 1
        } else {
            drawBranch(context: &context, from: to, angle: angle - 20, length: length * 0.7, depth: depth - 1, leafIndex: &leafIndex, cutoffPositive: cutoffPositive, cutoffNeutral: cutoffNeutral, scale: scale)
            drawBranch(context: &context, from: to, angle: angle + 20, length: length * 0.7, depth: depth - 1, leafIndex: &leafIndex, cutoffPositive: cutoffPositive, cutoffNeutral: cutoffNeutral, scale: scale)
        }
    }

    func countTotalLeaves(depth: Int) -> Int {
        let leavesPerBranch = Int(pow(2.0, Double(depth - 1)))
        return leavesPerBranch * 6
    }
}
