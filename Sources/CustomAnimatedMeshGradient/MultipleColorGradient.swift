//
//  SwiftUIView.swift
//  CustomAnimatedMeshGradient
//
//  Created by Joao Maia on 12/02/25.
//

import SwiftUI
import Noise

@available(iOS 18.0, *)
public struct MutipleColorGradient: View {
    let colorGenerator = GradientGenerator()
    let meshGenerator = MeshGenerator()
    
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
    private(set) public var showPoints: Bool
    
    
    public init(
        color: [Color],
        n: Int = 5,
        animationSpeed: Double = 1.0,
        animationAmplitude: Double = 0.1,
        blurRadius: Double = 30,
        noiseOpacity: Double = 0.4,
        secondaryGradientOpacity: Double = 0,
        showPoints: Bool = false
    ) {
        self.colors = color
        self.n = n ?? color.count
        self.animationSpeed = animationSpeed
        self.animationAmplitude = animationAmplitude
        self.blurRadius = blurRadius
        self.noiseOpacity = noiseOpacity
        self.secondaryGradientOpacity = secondaryGradientOpacity
        self.showPoints = showPoints
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
                        return meshGenerator.animatePoint(point: point, index: index, time: t, pattern: .noise, amplitude: animationAmplitude, gridSize: n)
                        
                    }
                    return point
                }
                
                MeshGradient(width: n, height: n, points: animatedPoints, colors: colors)
                
                MeshGradient(width: n, height: n, points: animatedPoints, colors: colors)
                    .blur(radius: blurRadius)
                    .opacity(secondaryGradientOpacity)
                    .rotationEffect(.degrees(180))
                
                if showPoints {
                    Canvas { context, size in
                        for (index, point) in animatedPoints.enumerated() {
                            let x = CGFloat(point.x) * size.width
                            let y = CGFloat(point.y) * size.height
                
                            // Draw point
                            context.stroke(
                                Circle().path(in: CGRect(x: x, y: y, width: 20, height: 20)),
                                with: .color(.black)
                            )
                
                            // Draw index number
                            let text = Text("  \(index)")
                                .font(.system(size: 12))
                                .foregroundColor(.black)
                            context.draw(text, at: CGPoint(x: x+6, y: y+10))
                        }
                    }
                }
                
                Noise(style: .random)
                    .monochrome()
                    .opacity(noiseOpacity)
                    .blendMode(.softLight)
            }
        }
        .onAppear {
            let gridDimension = self.n
            let totalPoints = gridDimension * gridDimension
            if self.colors.count != totalPoints {
                self.colors = (0..<totalPoints).map { _ in colors.randomElement() ?? .clear }
            }
            points = colorGenerator.generateUnitPoints(N: gridDimension)
        }
    }
    
    public func showPoints(_ show: Bool = true) -> MutipleColorGradient {
        MutipleColorGradient(
            color: self.colors,
            n: self.n,
            animationSpeed: self.animationSpeed,
            animationAmplitude: self.animationAmplitude,
            blurRadius: self.blurRadius,
            noiseOpacity: self.noiseOpacity,
            secondaryGradientOpacity: self.secondaryGradientOpacity,
            showPoints: show
        )
    }
}

#Preview {
    if #available(iOS 18.0, *) {
        MutipleColorGradient(
            color: ColorPalletes.darkRoastCoffee.colors,
            n: 5,
            animationSpeed: 0.2,
            animationAmplitude: 0.1
        )
        .showPoints()
    } else {
        EmptyView()
    }
}
