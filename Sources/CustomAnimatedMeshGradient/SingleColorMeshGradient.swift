//
//  SwiftUIView.swift
//  CustomAnimatedMeshGradient
//
//  Created by Joao Maia on 05/02/25.
//

import SwiftUI
import Noise

@available(iOS 18.0, *)
public struct SingleColorMeshGradient: View {
    let color: Color
    let colorGenerator = GradientGenerator()
    
    // Configuration parameters
    let animationSpeed: Double
    let animationAmplitude: Double
    let blurRadius: Double
    let noiseOpacity: Double
    let secondaryGradientOpacity: Double
    
    @State var colors: [Color] = []
    @State var points: [SIMD2<Float>] = []
    @State var n: Int
    @State private var isStatic: Bool = false
    
    /// Initialize a SingleColorMeshGradient
    /// - Parameters:
    ///   - color: The base color for the gradient
    ///   - n: Size of the mesh grid (default: 5)
    ///   - animationSpeed: Speed of the animation (default: 1.0)
    ///   - animationAmplitude: Amplitude of the wave animation (default: 0.1)
    ///   - blurRadius: Blur radius for the secondary gradient (default: 30)
    ///   - noiseOpacity: Opacity of the noise overlay (default: 0.4)
    ///   - secondaryGradientOpacity: Opacity of the blurred secondary gradient (default: 1.0)
    public init(
        color: Color,
        n: Int = 5,
        animationSpeed: Double = 1.0,
        animationAmplitude: Double = 0.1,
        blurRadius: Double = 30,
        noiseOpacity: Double = 0.4,
        secondaryGradientOpacity: Double = 1.0
    ) {
        self.color = color
        self.n = n
        self.animationSpeed = animationSpeed
        self.animationAmplitude = animationAmplitude
        self.blurRadius = blurRadius
        self.noiseOpacity = noiseOpacity
        self.secondaryGradientOpacity = secondaryGradientOpacity
    }
    
    public var body: some View {
        TimelineView(.animation) { timeline in
            ZStack {
                let date = timeline.date
                let t = isStatic ? 0 : CGFloat(date.timeIntervalSinceReferenceDate) * animationSpeed
                
                // Animate middle points
                let animatedPoints = points.enumerated().map { index, point in
                    let row = index / n
                    let col = index % n
                    
                    // Only animate non-vertex points
                    if row > 0 && row < n-1 && col > 0 && col < n-1 {
                        let xOffset = sin(t + Double(index)) * animationAmplitude
                        let yOffset = cos(t + Double(index)) * animationAmplitude
                        return SIMD2<Float>(point.x + Float(xOffset), point.y + Float(yOffset))
                    }
                    return point
                }
                
                MeshGradient(width: n, height: n, points: animatedPoints, colors: colors)
                
                MeshGradient(width: n, height: n, points: animatedPoints, colors: colors)
                    .blur(radius: blurRadius)
                    .opacity(secondaryGradientOpacity)
                    .rotationEffect(.degrees(180))
                
                
                Noise(style: .random)
                    .monochrome()
                    .opacity(noiseOpacity)
                    .blendMode(.softLight)
            }
        }
        .onAppear {
            colors = colorGenerator.generateMeshColors(using: color, size: n)
            points = colorGenerator.generateUnitPoints(N: n)
        }
    }
    
    @ViewBuilder
    var staticGradient:some View {
        ZStack{
            MeshGradient(width: n, height: n, points: points, colors: colors)
            
            MeshGradient(width: n, height: n, points: points, colors: colors)
                .blur(radius: blurRadius)
                .opacity(secondaryGradientOpacity)
                .rotationEffect(.degrees(180))
        }
    }
}


// Example usage in preview
#Preview {
    if #available(iOS 18.0, *) {
        VStack {
            SingleColorMeshGradient(color: Color(red: 0.35, green: 0.78, blue: 0.98))
                .frame(height: 200)
                .padding()
            
        }
    } else {
        EmptyView()
    }
}

extension Color {
    var id: String {
        return UUID().uuidString
    }
}
