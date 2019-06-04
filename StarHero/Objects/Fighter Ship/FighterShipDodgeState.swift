//
//  FighterShipDodgeState.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/26/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation

class FighterShipDodgeState: State {
    // Singleton instance to pass to the state machine
    static var sharedInstance: FighterShipDodgeState = FighterShipDodgeState()
    
    // Initializer, private as this shouldn't be initialized outside of the singleton
    private init() { }
    
    // Function for entering into a state
    func enter(object: BaseObject) {
        if let fighterShip = object as? FighterShip {
            // If the steering behavior wasn't set then we have to cancel moving into this state and go back to wandering
            if fighterShip.steeringBehavior?.getActiveBehavior() != SteeringBehaviors.Go {
                print("Failed to go in the direction")
                fighterShip.stateMachine?.changeState(newState: FighterShipWanderState.sharedInstance)
            }
        }
    }
    
    // Function for exiting a state
    func exit(object: BaseObject) {
        if let fighterShip = object as? FighterShip {
            // Reset the last known threat since we are heading back to it
            fighterShip.lastThreatHeading = nil
        }
    }
    
    // Function for updating a state
    func execute(object: BaseObject, dTime: TimeInterval) {
        if let fighterShip = object as? FighterShip {
            fighterShip.updateVelocity(timeElapsed: dTime)
            fighterShip.updatePosition(timeElapsed: dTime)
            fighterShip.updateNode()
            
            // When we return in bounds, go back to wandering
            if(fighterShip.isOutOfBounds()) {
                fighterShip.stateMachine?.changeState(newState: FighterShipReturnToFieldState.sharedInstance)
            }
            
            // Check to see if we fully turned and then turn back
            if let neededHeading = fighterShip.steeringBehavior?.targetPosition {
                if fighterShip.heading.dot(vector: neededHeading) < 0.1 {
                    if let lastThreat = fighterShip.lastThreatHeading {
                        //print("Finished dodging, now turn back toward the danger")
                        fighterShip.steeringBehavior?.setToGo(direction: lastThreat)
                        fighterShip.stateMachine?.changeState(newState: FighterShipTurnToLookState.sharedInstance)
                    }
                    else {
                        fighterShip.stateMachine?.changeState(newState: FighterShipWanderState.sharedInstance)
                    }
                    
                }
            }
        }
    }
}

