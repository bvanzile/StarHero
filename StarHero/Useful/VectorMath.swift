//
//  VectorMath.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/17/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

// Simple 2D vector
struct Vector: VectorMath {
    // Properties used in a 2D vector
    var x: CGFloat = 0
    var y: CGFloat = 0
    
    // Initialize a vector with 2 values
    init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
    
    // Initialize a vector from a CGPoint
    init(_ point: CGPoint) {
        x = point.x
        y = point.y
    }
    
    // Initialize based on degrees
    init(degrees: CGFloat) {
        x = cos(degreesToRads(degrees: degrees))
        y = sin(degreesToRads(degrees: degrees))
    }
    
    // Initialize based on degrees
    init(rads: CGFloat) {
        x = cos(rads)
        y = sin(rads)
    }
    
    // Default to 0, 0
    init() { }
    
    // The vector magnitude
    func length() -> CGFloat {
        return CGFloat((x * x) + (y * y)).squareRoot()
    }
    
    // Normalize vector to length of 1
    func normalize() -> Vector {
        let magnitude = self.length()
        if magnitude == 0 {
            // Return 0 vector, keep in mind to avoid divide by 0 later on
            return self
        }
        else {
            return Vector(x: self.x / magnitude, y: self.y / magnitude)
        }
    }
    
    // Overload the * operator for multiplication
    static func *(left: Vector, right: CGFloat) -> Vector {
        return Vector(x: left.x * right, y: left.y * right)
    }
    
    // Overload the * operator for multiplication
    static func /(left: Vector, right: CGFloat) -> Vector {
        return Vector(x: left.x / right, y: left.y / right)
    }
    
    // Overload the + operator for vector addition
    static func +(left: Vector, right: Vector) -> Vector {
        return Vector(x: left.x + right.x, y: left.y + right.y)
    }
    
    // Overload the - operator for vector addition
    static func -(left: Vector, right: Vector) -> Vector {
        return Vector(x: left.x - right.x, y: left.y - right.y)
    }
    
    func dot(vector: Vector) -> CGFloat {
        let thisVectorNormalized = self.normalize()
        let otherVectorNormalized = vector.normalize()
        
        return acos((thisVectorNormalized.x * otherVectorNormalized.x) + (thisVectorNormalized.y * otherVectorNormalized.y))
    }
    
    func dotDegrees(vector: Vector) -> CGFloat {
        let thisVectorNormalized = self.normalize()
        let otherVectorNormalized = vector.normalize()
        
        return radsToDegrees(rads: acos((thisVectorNormalized.x * otherVectorNormalized.x) + (thisVectorNormalized.y * otherVectorNormalized.y)))
    }
    
    // Return the vector that is perpindicular and to the right (clockwise)
    func right() -> Vector {
        return Vector(x: y, y: -x)
    }
    
    // Return the vector that is perpindicular and to the right (clockwise)
    func left() -> Vector {
        return Vector(x: -y, y: x)
    }
    
    // Returns the reverse of this vector
    func reverse() -> Vector {
        return Vector(x: -x, y: -y)
    }
    
    // Adjusts the vector so that it does not exceed the input
    func truncate(value: CGFloat) -> Vector {
        // Check if the length of the vector is greater than the input
        if(self.length() > value) {
            // If so, normalize and change to desired length
            return self.normalize() * value
        }
        return self
    }
    
    // Distance between this vetor and the one passed in argument
    func distanceBetween(vector: Vector) -> CGFloat {
        return (self - vector).length()
    }
    
    // Rotate vector by degrees
    func rotate(degrees: CGFloat) -> Vector {
        let rotation = degreesToRads(degrees: degrees)
        
        return Vector(x: (x * cos(rotation)) - (y * sin(rotation)), y: (x * sin(rotation)) + (y * cos(rotation)))
    }
    
    // Convert vector to degrees
    func toRads() -> CGFloat {
        return atan2(y, x)
    }
    
    // Convert vector to degrees
    func toDegrees() -> CGFloat {
        return radsToDegrees(rads: atan2(y, x))
    }
    
    // Return this vector as a CGPoint
    func toCGPoint() -> CGPoint {
        return CGPoint(x: x, y: y)
    }
    
    // Check if this is a zero'd out vector
    func isZero() -> Bool {
        if x == 0 && y == 0 {
            return true
        }
        return false
    }
}

// Inheritable class that appends some useful math functions to any class that inherits it
protocol VectorMath { }

extension VectorMath {
    // Reusable function for receving a normalized vector that represents an angle in degrees
    func angleToVector(degrees: CGFloat) -> Vector {
        return Vector(x: cos(degreesToRads(degrees: degrees)), y: sin(degreesToRads(degrees: degrees)))
    }
    // Reusable function for receving a normalized vector that represents an angle in degrees
    func angleToVector(rads: CGFloat) -> Vector {
        return Vector(x: cos(rads), y: sin(rads))
    }
    
    // Converts degrees to radians
    func degreesToRads(degrees: CGFloat) -> CGFloat {
        return degrees * (.pi / 180.0)
    }
    
    // Converts radians to degrees
    func radsToDegrees(rads: CGFloat) -> CGFloat {
        return rads * (180.0 / .pi)
    }
    
    // Reusable function for taking separated coordinates and returning a CGPoint object
    func coordToCGPoint(x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint(x: x, y: y)
    }
    
    // Reusable function for taking separated coordinates and returning a CGPoint object
    func vectorToCGPoint(vector: Vector) -> CGPoint {
        return CGPoint(x: vector.x, y: vector.y)
    }
    
    // Convert the heading direction to the sprite's necessary rotation
    func ConvertHeadingToSpriteRotation(heading: CGFloat) -> CGFloat {
        return self.degreesToRads(degrees: heading + 90.0)
    }
    
    // Finds the angle between 2 points
    func GetDirection(firstPoint: CGPoint, secondPoint: CGPoint) -> CGFloat {
        return self.radsToDegrees(rads: atan2(secondPoint.y - firstPoint.y, secondPoint.x - firstPoint.x))
    }
    
    // Get a randomized vector
    func randomVector() -> Vector {
        let randomizedVector = Vector(x: CGFloat.random(in: -1...1), y: CGFloat.random(in: -1...1))
        return randomizedVector.normalize()
    }
}
