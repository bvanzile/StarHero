//
//  MotherShipIdleState.swift
//  StarHero
//
//  Created by Bryan Van Zile on 6/28/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation

class MotherShipIdleState: State {
    // Singleton instance to pass to the state machine
    static var sharedInstance: MotherShipIdleState = MotherShipIdleState()
    
    // Initializer, private as this shouldn't be initialized outside of the singleton
    private init() { }
    
    // Function for entering into a state
    func enter(object: BaseObject) {
        if let motherShip = object as? MotherShip {
            print("MotherShip entering idle state")
            
            // End the path, if one is ongoing
            motherShip.releasePathNode(invalidPath: false)
            
            motherShip.steeringBehavior?.setToIdle()
        }
    }
    
    // Function for exiting a state
    func exit(object: BaseObject) {
        if let _ = object as? MotherShip {
            print("MotherShip exiting idle state")
        }
    }
    
    // Function for updating a state
    func execute(object: BaseObject, dTime: TimeInterval) {
        if let motherShip = object as? MotherShip {
            motherShip.updateVelocity(timeElapsed: dTime)
            motherShip.updatePosition(timeElapsed: dTime)
            motherShip.updateNode(ignoreHeading: true)
            
            if motherShip.velocity.length() < 5 {
                motherShip.velocity = Vector()
            }
        }
    }
}
