//
//  ObjectCanSee.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/24/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

protocol ObjectCanSee {
    var sightNode: SKShapeNode { get }
}

extension ObjectCanSee {
    // Setup the physics body for a sight node
    func setupSightPhysicsBody(degrees: CGFloat, distance: CGFloat, canSee: UInt32) {
        // Create the physics body and update the properties
        sightNode.physicsBody = SKPhysicsBody(polygonFrom: setupSightPath(degrees: degrees, distance: distance))
        sightNode.physicsBody?.isDynamic = true
        sightNode.physicsBody?.affectedByGravity = false
        sightNode.physicsBody?.categoryBitMask = Config.BitMaskCategory.Sight
        sightNode.physicsBody?.contactTestBitMask = canSee
        sightNode.physicsBody?.collisionBitMask = 0x0
    }
    
    // Return the path that the sight node will use to detect other objects
    private func setupSightPath(degrees: CGFloat, distance: CGFloat) -> CGMutablePath {
        // Create a path that resembles a cone but with 5 straight lines at the top
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: (Vector(degrees: ((degrees / 2) + 90)) * distance).toCGPoint())
        path.addLine(to: (Vector(degrees: ((degrees / 4) + 90)) * distance).toCGPoint())
        path.addLine(to: CGPoint(x: 0, y: distance))
        path.addLine(to: (Vector(degrees: (90 - (degrees / 4))) * distance).toCGPoint())
        path.addLine(to: (Vector(degrees: (90 - (degrees / 2))) * distance).toCGPoint())
        path.addLine(to: CGPoint(x: 0, y: 0))
        
        return path
    }
}
