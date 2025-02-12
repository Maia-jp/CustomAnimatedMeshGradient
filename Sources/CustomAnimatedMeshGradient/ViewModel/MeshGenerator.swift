import SwiftUI

public class MeshGenerator {
    public enum AnimationPattern {
        case wave
        case spiral
        case noise
        case vortex
        case kaleidoscope
    }
    
    func generateUnitPoints(N: Int) -> [SIMD2<Float>] {
        var points: [SIMD2<Float>] = []
        for row in 0..<N {
            for col in 0..<N {
                let x = Float(col) / Float(N - 1)
                let y = Float(row) / Float(N - 1)
                points.append(SIMD2<Float>(x, y))
            }
        }
        return points
    }
    
    func animatePoint(point: SIMD2<Float>, 
                     index: Int, 
                     time: Double, 
                     pattern: AnimationPattern, 
                     amplitude: Double,
                     gridSize: Int) -> SIMD2<Float> {
        let centerX = Float(0.5)
        let centerY = Float(0.5)
        let distanceFromCenter = sqrt(pow(point.x - centerX, 2) + pow(point.y - centerY, 2))
        
        switch pattern {
        case .wave:
            // Creates a rippling wave pattern
            let frequency = 5.0
            let xOffset = amplitude * sin(time + Double(distanceFromCenter) * frequency)
            let yOffset = amplitude * cos(time + Double(distanceFromCenter) * frequency)
            return SIMD2<Float>(point.x + Float(xOffset), point.y + Float(yOffset))
            
        case .spiral:
            // Creates a spinning spiral effect
            let angle = time + Double(distanceFromCenter) * 4
            let rotationX = cos(angle) * Double(distanceFromCenter) * amplitude
            let rotationY = sin(angle) * Double(distanceFromCenter) * amplitude
            return SIMD2<Float>(point.x + Float(rotationX), point.y + Float(rotationY))
            
        case .noise:
            // Creates a more chaotic, noise-like movement
            let noiseX = sin(time * 1.5 + Double(index) * 0.5) * amplitude
            let noiseY = cos(time * 2.0 + Double(index) * 0.7) * amplitude
            return SIMD2<Float>(point.x + Float(noiseX), point.y + Float(noiseY))
            
        case .vortex:
            // Creates a vortex-like spinning effect
            let angle = atan2(Double(point.y - centerY), Double(point.x - centerX))
            let rotationSpeed = (1.0 - Double(distanceFromCenter)) * 2
            let xOffset = amplitude * cos(time * rotationSpeed + angle)
            let yOffset = amplitude * sin(time * rotationSpeed + angle)
            return SIMD2<Float>(point.x + Float(xOffset), point.y + Float(yOffset))
            
        case .kaleidoscope:
            // Divide the space into quadrants
            let quadrant = Int((point.x > centerX ? 2 : 0) + (point.y > centerY ? 1 : 0))
            let angle = atan2(Double(point.y - centerY), Double(point.x - centerX))
            
            switch quadrant {
            case 0: // Bottom-left: Spiral movement
                let spiralAngle = time * 2 + Double(distanceFromCenter) * 6
                let scale = 0.3 + sin(time) * 0.1
                let spiralX = cos(spiralAngle) * Double(distanceFromCenter) * amplitude * scale
                let spiralY = sin(spiralAngle) * Double(distanceFromCenter) * amplitude * scale
                return SIMD2<Float>(point.x + Float(spiralX), point.y + Float(spiralY))
                
            case 1: // Top-left: Wave pattern
                let waveFreq = 4.0
                let xOffset = amplitude * sin(time + Double(point.y) * waveFreq)
                let yOffset = amplitude * cos(time + Double(point.x) * waveFreq) * 0.5
                return SIMD2<Float>(point.x + Float(xOffset), point.y + Float(yOffset))
                
            case 2: // Bottom-right: Pulsing movement
                let pulse = sin(time * 2 + Double(distanceFromCenter) * 8) * amplitude
                let dx = (point.x - centerX) * Float(pulse)
                let dy = (point.y - centerY) * Float(pulse)
                return SIMD2<Float>(point.x + dx, point.y + dy)
                
            default: // Top-right: Rotating circles
                let rotSpeed = (1.0 - Double(distanceFromCenter)) * 3
                let radius = Double(distanceFromCenter) * amplitude
                let rotAngle = time * rotSpeed + angle
                let dx = radius * cos(rotAngle)
                let dy = radius * sin(rotAngle)
                return SIMD2<Float>(point.x + Float(dx), point.y + Float(dy))
            }
        }
    }
} 
