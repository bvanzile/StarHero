//
//  ObjectPeripheralSight.swift
//  StarHero
//
//  Created by Bryan Van Zile on 6/6/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

protocol ObjectPeripheralSight {
    // Holds the physics object
    var peripheralNode: SKShapeNode { get }
    
    // The kind of object that can be seen
    var objectsInPeripheral: [String : MovingObject] { get set }
}

extension ObjectPeripheralSight {
    // Setup the physics body for the peripheral sight node
    func setupPeripheralPhysicsBody(radius: CGFloat, canSee: UInt32) {
        // Create the physics body and update the properties
        peripheralNode.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        peripheralNode.physicsBody?.isDynamic = true
        peripheralNode.physicsBody?.affectedByGravity = false
        peripheralNode.physicsBody?.categoryBitMask = Config.BitMaskCategory.Peripheral
        peripheralNode.physicsBody?.contactTestBitMask = canSee
        peripheralNode.physicsBody?.collisionBitMask = 0x0
    }
    
    // Return whether any items are visible
    func seesSomething() -> Bool {
        return objectsInPeripheral.isEmpty ? false : true
    }
    
    // Return the closest object in sight
    func getClosestObject(to: Vector) -> MovingObject? {
        // The closest moving object
        var closest: MovingObject?
        
        // Look through what this object can see and grab the closest
        for (_, objInPeripheral) in self.objectsInPeripheral {
            if objInPeripheral.isActive {
                if closest == nil {
                    closest = objInPeripheral
                }
                else {
                    if((closest!.position - to).length() > (objInPeripheral.position - to).length()) {
                        closest = objInPeripheral
                    }
                }
            }
        }
        
        return closest
    }
}
