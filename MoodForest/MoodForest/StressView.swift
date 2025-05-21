import SwiftUI

struct StressView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                Group {
                    Text("📘 What Is *Full Catastrophe Living* About?")
                        .font(.title3)
                        .bold()
                    
                    Text("""
_All of the following information is taken from the book_ **\"Full Catastrophe Living: Using the Wisdom of Your Body and Mind to Face Stress, Pain, and Illness\"** _by Jon Kabat-Zinn._

In *Full Catastrophe Living*, Kabat-Zinn introduces the **Mindfulness-Based Stress Reduction (MBSR)** program, an eight-week course developed at the University of Massachusetts Medical Center.  
The book provides a comprehensive guide to mindfulness practices, including **meditation, body scanning, and gentle yoga**, aimed at helping individuals cope with stress, chronic pain, and other health challenges.
""")
                }

                Group {
                    Text("🧠 What Is Mindfulness?")
                        .font(.title3)
                        .bold()
                    
                    Text("Kabat-Zinn defines mindfulness as:")
                        .italic()
                    
                    Text("“The awareness that arises by paying attention on purpose, in the present moment, and non-judgmentally.”")
                        .padding(.vertical, 5)
                        .italic()
                    
                    Text("This practice involves cultivating a **moment-to-moment awareness** of one’s experiences **without judgment**, allowing for a deeper understanding and acceptance of the present.")
                }

                Group {
                    Text("💡 How Mindfulness Helps with Stress")
                        .font(.title3)
                        .bold()

                    Text("""
The book outlines how mindfulness can transform one’s relationship with stress by:

• **Reducing Reactivity** – by observing thoughts and emotions without immediate reaction, individuals can respond to stressors more thoughtfully.  
• **Enhancing Clarity** – mindfulness fosters a clearer understanding of stress triggers and personal responses.  
• **Building Resilience** – regular practice strengthens the ability to remain centered amidst life’s challenges.

Kabat-Zinn emphasizes that mindfulness doesn’t eliminate stress but changes how one relates to it, leading to improved well-being.
""")
                }

                Group {
                    Text("📖 Excerpt from *Full Catastrophe Living*")
                        .font(.title3)
                        .bold()
                    
                    Text("“Life only unfolds in moments. The healing power of mindfulness lies in living each of those moments as fully as we can, accepting it as it is as we open to what comes next—in the next moment of now.”")
                        .italic()
                        .padding(.vertical, 5)

                    Text("This passage encapsulates the **essence of mindfulness** as a practice of embracing each moment with **openness and acceptance**.")
                }

                Spacer()
            }
            .padding()
            .navigationTitle("How to Deal with Stress?")
        }
    }
}
