//
//  FighterShipReturnToFieldState.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/22/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation

class FighterShipReturnToFieldState: State {
    // Singleton instance to pass to the state machine
    static var sharedInstance: FighterShipReturnToFieldState = FighterShipReturnToFieldState()
    
    // Initializer, private as this shouldn't be initialized outside of the singleton
    private init() { }
    
    // Function for entering into a state
    func enter(object: BaseObject) {
        if let fighterShip = object as? FighterShip {
            //print("\(fighterShip.name!) is returning to the field")
            fighterShip.steeringBehavior?.setToSeek(target: Vector(x: 0, y: 0))
        }
    }
    
    // Function for exiting a state
    func exit(object: BaseObject) {
        if let _ = object as? FighterShip {
            //print("\(fighterShip.name!) has returned to the field")
        }
    }
    
    // Function for updating a state
    func execute(object: BaseObject, dTime: TimeInterval) {
        if let fighterShip = object as? FighterShip {
            // Change the ship to wander if the velocity returns false (velocity was set to 0 for some reason)
            fighterShip.updateVelocity(timeElapsed: dTime)
            fighterShip.updatePosition(timeElapsed: dTime)
            fighterShip.updateNode()
            
            // When we return in bounds, go back to wandering
            if(!fighterShip.isOutOfBounds()) {
                fighterShip.stateMachine?.changeState(newState: FighterShipWanderState.sharedInstance)
            }
        }
    }
}
