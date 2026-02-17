import SwiftUI

struct SplashScreenView: View {
    @State private var anvilScale: CGFloat = 0.3
    @State private var anvilOpacity: Double = 0
    @State private var hammerOffset: CGFloat = -200
    @State private var hammerRotation: Double = -45
    @State private var showSparks = false
    @State private var sparkPositions: [SparkParticle] = []
    @State private var showAppName = false
    @State private var navigateToMain = false
    
    var body: some View {
        ZStack {
            // Radial gradient background (forge glow)
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(hex: "FF6B35").opacity(0.3),
                    Color(hex: "1A1D23")
                ]),
                center: .center,
                startRadius: 50,
                endRadius: 500
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                ZStack {
                    // Anvil icon
                    Image(systemName: "hammer.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .foregroundColor(Color(hex: "FF6B35"))
                        .scaleEffect(anvilScale)
                        .opacity(anvilOpacity)
                    
                    // Hammer strike
                    Image(systemName: "hammer")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color(hex: "4A90E2"))
                        .offset(y: hammerOffset)
                        .rotationEffect(.degrees(hammerRotation))
                    
                    // Spark particles
                    ForEach(sparkPositions) { spark in
                        Circle()
                            .fill(Color(hex: "FFD700"))
                            .frame(width: spark.size, height: spark.size)
                            .offset(x: spark.x, y: spark.y)
                            .opacity(spark.opacity)
                            .blur(radius: 1)
                    }
                }
                .frame(height: 200)
                
                // App name with typewriter effect
                Text("RoutineForge")
                    .font(.system(size: 42, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "FF6B35"), Color(hex: "FFD700")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(showAppName ? 1 : 0)
                    .offset(y: showAppName ? 0 : 20)
                
                Text("Forge Your Best Day")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                    .opacity(showAppName ? 1 : 0)
                
                Spacer()
            }
        }
        .onAppear {
            startAnimation()
        }
        .fullScreenCover(isPresented: $navigateToMain) {
            if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
                MainTabView()
            } else {
                OnboardingContainerView()
            }
        }
    }
    
    func startAnimation() {
        // Anvil appears
        withAnimation(.easeOut(duration: 0.6)) {
            anvilScale = 1.0
            anvilOpacity = 1.0
        }
        
        // Hammer strikes after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)) {
                hammerOffset = 20
                hammerRotation = 0
            }
            
            // Generate sparks on impact
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                generateSparks()
                showSparks = true
                
                // Haptic feedback
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
            }
        }
        
        // Show app name
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.easeInOut(duration: 0.8)) {
                showAppName = true
            }
        }
        
        // Navigate to main screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            navigateToMain = true
        }
    }
    
    func generateSparks() {
        sparkPositions = (0..<12).map { i in
            let angle = Double(i) * 30.0 * .pi / 180.0
            let distance: CGFloat = 60
            return SparkParticle(
                x: cos(angle) * distance,
                y: sin(angle) * distance,
                size: CGFloat.random(in: 3...8),
                opacity: 1.0
            )
        }
        
        // Animate sparks outward and fade
        withAnimation(.easeOut(duration: 1.0)) {
            sparkPositions = sparkPositions.map { spark in
                var newSpark = spark
                newSpark.x *= 2.5
                newSpark.y *= 2.5
                newSpark.opacity = 0
                return newSpark
            }
        }
    }
}

struct SparkParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
}

// Color extension for hex support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
