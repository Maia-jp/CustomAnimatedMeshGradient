//
//  MeshGradientView.swift
//  AgentBuilder
//
//  Created by Joao Maia on 30/01/25.
//

import SwiftUI
//import Noise

@available(iOS 18.0, *)
public class GradientGenerator {
    let gradientSize = 3...5
    
    
    // MARK: - Nested Types
    private struct HSL {
        var h: Double
        var s: Double
        var l: Double
    }
    
    private struct RandomNumberGeneratorWithSeed: RandomNumberGenerator {
        init(seed: Int) { srand48(seed) }
        func next() -> UInt64 { return UInt64(drand48() * Double(UInt64.max)) }
    }
    
    // MARK: - Properties
    private let stops: [Int] = [25, 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950]
    
    // MARK: - Public Methods
    
    func generateMeshColors(using baseColor: Color, size:Int = 8) -> [Color]{
        let totalSize = size * size
        let baseArray = Array(repeating: baseColor, count: totalSize)
        let pallete = Array(generatePalette(inputColor: baseColor)[5...7])

        var modifiedArray = baseArray
        
        // For any grid size, modify non-edge positions
        for row in 1..<(size-1) {
            for col in 1..<(size-1) {
                let index = row * size + col
                // Get random color from palette for inner positions
                let randomPaletteColor = pallete.randomElement() ?? baseColor
                modifiedArray[index] = randomPaletteColor
            }
        }
        
        return modifiedArray.shuffled()
    }
    
    func generateColors(using str: String) -> [Color] {
        let size = meshGradientSize(from: str)
        let allColors = meshGradientColors(from: str)
        return selectGradientColors(from: allColors, count: size)
    }
    
    public func generatePalette(inputColor: Color) -> [Color] {
        let nsColor = UIColor(inputColor)
        
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        nsColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        let inputHSL = HSL(h: Double(hue) * 360, s: Double(saturation) * 100, l: Double(brightness) * 100)
        let inputLevel = determineInputLevel(lightness: inputHSL.l)
        
        var palette: [Color] = []
        let inputLightness = stopToLightness(inputLevel)
        let midLightness = stopToLightness(500)
        let maxSaturation = 100.0
        let saturationCoefficient = 1.0

        for stop in stops {
            let targetLightness = stopToLightness(stop)
            let normalizedLightnessDiff: Double

            if targetLightness >= midLightness {
                normalizedLightnessDiff = (targetLightness - midLightness) / (100 - midLightness)
            } else {
                normalizedLightnessDiff = (midLightness - targetLightness) / midLightness
            }

            var adjustedSaturation: Double
            if targetLightness >= midLightness {
                adjustedSaturation = inputHSL.s + normalizedLightnessDiff * (maxSaturation - inputHSL.s) * saturationCoefficient
            } else {
                adjustedSaturation = inputHSL.s * (1 - normalizedLightnessDiff * saturationCoefficient)
            }

            adjustedSaturation = max(0, min(maxSaturation, adjustedSaturation))
            let adjustedHue = (adjustHue(inputHSL.h, targetLightness - inputLightness) + 360).truncatingRemainder(dividingBy: 360)
            let color = Color(hue: adjustedHue / 360, saturation: adjustedSaturation / 100, brightness: targetLightness / 100)
            palette.append(color)
        }

        return palette
    }
    
    // MARK: - Private Methods
    private func meshGradientSize(from string: String) -> Int {
        var rng = RandomNumberGeneratorWithSeed(seed: string.hash)
        return Int.random(in: gradientSize, using: &rng)
    }
    
    private func meshGradientColors(from string: String) -> [Color] {
        var rng = RandomNumberGeneratorWithSeed(seed: string.hash)
        
        let deepNavy = Color(red: 36/255, green: 29/255, blue: 108/255)
        let softCyan = Color(red: 129/255, green: 236/255, blue: 236/255)
        let peach = Color(red: 255/255, green: 176/255, blue: 97/255)
        let deepBlue = Color(red: 19/255, green: 84/255, blue: 122/255)
        let aquaMint = Color(red: 103/255, green: 230/255, blue: 220/255)
        let neonPink = Color(red: 255/255, green: 102/255, blue: 204/255)
        let rubyRed = Color(red: 194/255, green: 53/255, blue: 79/255)
        let goldenSand = Color(red: 255/255, green: 216/255, blue: 102/255)
        let customTurquoise = Color(red: 48/255, green: 213/255, blue: 200/255)
        let customViolet = Color(red: 159/255, green: 90/255, blue: 253/255)
        let customCoral = Color(red: 255/255, green: 127/255, blue: 80/255)

        let predefinedPalettes: [[Color]] = [
            // Classic neon
            [.cyan, .blue, .purple, .pink, .red],
            [.teal, .mint, .purple, .indigo, .cyan],

            // Sunrise vibes
            [.orange, .pink, .purple, .blue, .indigo],
            [.yellow, .orange, .red, .purple, .blue],

            // Deep space
            [.black, .indigo, .purple, .blue, .cyan],
            [deepNavy, .blue, .purple, customViolet, .pink],

            // Tropical ocean
            [.cyan, customTurquoise, .mint, .blue, deepBlue],
            [aquaMint, .teal, .green, customTurquoise, softCyan],

            // Fire & lava
            [.red, .orange, .yellow, peach, goldenSand],
            [customCoral, peach, .red, rubyRed, deepNavy],

            // Nature inspired
            [.green, .mint, .teal, .blue, deepBlue],
            [.yellow, .green, customTurquoise, .teal, .mint],

            // Cyberpunk neon
            [neonPink, .purple, .blue, .cyan, customTurquoise],
            [.pink, customViolet, deepNavy, .blue, .teal]
        ]
        
        return predefinedPalettes.randomElement(using: &rng) ?? predefinedPalettes[0]
    }
    
    private func selectGradientColors(from palette: [Color], count n: Int, seed: String = "Maia") -> [Color] {
        var colorsToPaint: [Color] = []
        
        for i in 0..<3 {
            var rng = RandomNumberGeneratorWithSeed(seed: seed.hash + i)
            let color = palette.randomElement(using: &rng) ?? Color.primary
            colorsToPaint.append(color)
        }
        
        var selectedColors: [Color] = []
        for i in 0..<n*n {
            var rng = RandomNumberGeneratorWithSeed(seed: seed.hash + i)
            let color = colorsToPaint.randomElement(using: &rng) ?? Color.primary
            selectedColors.append(color)
        }
        
        return selectedColors
    }
    
    public func generateUnitPoints(N: Int) -> [SIMD2<Float>] {
        var points: [SIMD2<Float>] = []
        let step = 1.0 / Float(N - 1)
        
        for i in 0..<N {
            for j in 0..<N {
                let x = Float(j) * step
                let y = Float(i) * step
                points.append(SIMD2<Float>(x: x, y: y))
            }
        }
        
        return points
    }
    
    private func stopToLightness(_ stop: Int) -> Double {
        let stopLightnessMap: [Int: Double] = [
            25: 99,
            50: 97,
            100: 95,
            200: 90,
            300: 82,
            400: 64,
            500: 44,
            600: 28,
            700: 15,
            800: 12,
            900: 8,
            950: 4
        ]
        return stopLightnessMap[stop] ?? 0
    }
    
    private func determineInputLevel(lightness: Double) -> Int {
        var closestLevel = stops[0]
        var minDiff = abs(lightness - stopToLightness(stops[0]))
        
        for stop in stops.dropFirst() {
            let stopLightness = stopToLightness(stop)
            let diff = abs(lightness - stopLightness)
            if diff < minDiff {
                minDiff = diff
                closestLevel = stop
            }
        }
        
        return closestLevel
    }
    
    private func adjustHue(_ hue: Double, _ lightnessDiff: Double) -> Double {
        return hue + lightnessDiff
    }
}

//struct SeededMeshGradientView: View {
//    @Binding var str: String
//    
//    private let generator = GradientGenerator()
//    
//    var body: some View {
//        RoundedRectangle(cornerRadius: 12)
//            .foregroundStyle(.clear)
//            .background {
//                generator.generateMeshView(using: str)
//                    .blur(radius: 1)
//                    .opacity(0.8)
//                
//                Noise(style: .smooth)
//                    .seed(str.hash)
//                    .monochrome()
//                    .blendMode(.softLight)
//                
//            }
//            .overlay {
//                RoundedRectangle(cornerRadius: 12)
//                    .strokeBorder(.white.opacity(0.3), lineWidth: 1)
//            }
//            .overlay {
//                RoundedRectangle(cornerRadius: 12)
//                    .foregroundStyle(.ultraThinMaterial.opacity(0.5))
//            }
//        
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//    }
//}
//
//
//// MARK: - Preview View
//struct MeshGradientView: View {
//    @State var str: String = "Mersenne Twiste"
//    @State var colors: [Color] = []
//    private let generator = GradientGenerator()
//    
//    var body: some View {
//        ScrollView {
//            TextField("Seed", text: $str)
//                
//            SeededMeshGradientView(str: $str)
//                .frame(height: 150)
//                .frame(width: 150)
//                .aspectRatio(1, contentMode: .fill)
//                .padding()
//            
//            
//            SeededMeshGradientView(str:.constant("123"))
//                .frame(height: 150)
//                .frame(width: 150)
//                .aspectRatio(1, contentMode: .fill)
//                .padding()
//        }
//    }
//}
//
//#Preview {
//    MeshGradientView()
//}
