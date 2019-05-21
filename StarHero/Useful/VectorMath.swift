//
//  VectorMath.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/17/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

// Simple vector
struct Vector: VectorMath {
    var x: CGFloat = 0
    var y: CGFloat = 0
    
    func normalize() -> Vector {
        let magnitude = ((x * x) + (y * y)).squareRoot()
        if magnitude == 0 {
            return self
        }
        else {
            return Vector(x: self.x / magnitude, y: self.y / magnitude)
        }
    }
    
    func magnitude() -> CGFloat {
        return CGFloat((x * x) + (y * y)).squareRoot()
    }
    
    func multiply(value: CGFloat) -> Vector {
        return Vector(x: x * value, y: y * value)
    }
    
    func add(vector: Vector) -> Vector {
        return Vector(x: x + vector.x, y: y + vector.y)
    }
    
    func dotProductRads(vector: Vector) -> CGFloat {
        let thisVectorNormalized = self.normalize()
        let otherVectorNormalized = vector.normalize()
        print ("\(thisVectorNormalized) and \(otherVectorNormalized)")
        return acos((thisVectorNormalized.x * otherVectorNormalized.x) + (thisVectorNormalized.y * otherVectorNormalized.y))
    }
    
    func dotProductDegrees(vector: Vector) -> CGFloat {
        let thisVectorNormalized = self.normalize()
        let otherVectorNormalized = vector.normalize()
        return RadsToDegrees(rads: acos((thisVectorNormalized.x * otherVectorNormalized.x) + (thisVectorNormalized.y * otherVectorNormalized.y)))
    }
}

// Inheritable class that appends some useful math functions to any class that inherits it
protocol VectorMath { }

extension VectorMath {
    // Reusable function for taking separated coordinates and returning a CGPoint object
    func coordToCGPoint(x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint(x: x, y: y)
    }
    
    // Convert the heading direction to the sprite's necessary rotation
    func ConvertHeadingToSpriteRotation(heading: CGFloat) -> CGFloat {
        return self.DegreesToRads(degrees: heading + 90.0)
    }
    
    // Converts degrees to radians
    func DegreesToRads(degrees: CGFloat) -> CGFloat {
        return -degrees * (.pi / 180.0)
    }
    
    // Converts radians to degrees
    func RadsToDegrees(rads: CGFloat) -> CGFloat {
        return -rads * (180.0 / .pi)
    }
    
    // Finds the angle between 2 points
    func GetDirection(firstPoint: CGPoint, secondPoint: CGPoint) -> CGFloat {
        return self.RadsToDegrees(rads: atan2(secondPoint.y - firstPoint.y, secondPoint.x - firstPoint.x))
    }
}
