//
//  MathAndConversions.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/17/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit


// Singleton class for useful and repeatable conversions
class Conversions {
    // Singelton
    static let sharedInstance: Conversions = Conversions()
    
    // Private initializer so the class can not be instantiated
    private init() {
        
    }
    
    func coordToCGPoint(x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint(x: x, y: y)
    }
}

// Singleton class for useful and repeatable 2D vector math
class VectorMath {
    // Singelton
    static let sharedInstance: VectorMath = VectorMath()
    
    // Private initializer so the class can not be instantiated
    private init() {
        
    }
}
