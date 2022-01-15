//
//  Helpers.swift
//  LIDAR Scanner
//
//  Created by Zihang Jin on 17/12/21.
//

import ARKit

enum XError : Error {
    case noScanDone
    case alreadyExporting
    case exportingFailed
}

typealias Float2 = SIMD2<Float>
typealias Float3 = SIMD3<Float>

extension Float {
    static let degreesToRadian = Float.pi / 180
}

extension matrix_float3x3 {
    mutating func copy(from affine: CGAffineTransform) {
        columns.0 = Float3(Float(affine.a), Float(affine.c), Float(affine.tx))
        columns.1 = Float3(Float(affine.b), Float(affine.d), Float(affine.ty))
        columns.2 = Float3(0, 0, 1)
    }
}

final class CPUParticle {
    var position: simd_float3
    var color: simd_float3
    var confidence: Float
    
    init(position: simd_float3, color: simd_float3, confidence: Float) {
        self.position = position
        self.color = color * 255
        self.confidence = confidence
    }
}

