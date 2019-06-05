//
//  FighterShipTurnToLookState.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/26/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation

class FighterShipTurnToLookState: State {
    // Singleton instance to pass to the state machine
    static var sharedInstance: FighterShipTurnToLookState = FighterShipTurnToLookState()
    
    // Initializer, private as this shouldn't be initialized outside of the singleton
    private init() { }
    
    // Function for entering into a state
    func enter(object: BaseObject) {
        if let fighterShip = object as? FighterShip {
            // If we see an enemy ship, start attacking it
            if fighterShip.seesEnemyFighterShip() {
                // Begin the pursuit on the closest fighter ship in vision
                if let closest = fighterShip.getClosestEnemyFighterShip() {
                    // Start going after the closest ship
                    fighterShip.steeringBehavior?.setToPursue(target: closest)
                    fighterShip.stateMachine?.changeState(newState: FighterShipAttackState.sharedInstance)
                }
                else {
                    fighterShip.stateMachine?.changeState(newState: FighterShipWanderState.sharedInstance)
                }
            }
            // If the steering behavior wasn't set then we have to cancel moving into this state and go back to wandering
            else if fighterShip.steeringBehavior?.getActiveBehavior() != SteeringBehaviors.Go {
                print("Failed to go in the direction")
                fighterShip.stateMachine?.changeState(newState: FighterShipWanderState.sharedInstance)
            }
        }
    }
    
    // Function for exiting a state
    func exit(object: BaseObject) {
        if let _ = object as? FighterShip {
            
        }
    }
    
    // Function for updating a state
    func execute(object: BaseObject, dTime: TimeInterval) {
        if let fighterShip = object as? FighterShip {
            fighterShip.updateVelocity(timeElapsed: dTime)
            fighterShip.updatePosition(timeElapsed: dTime)
            fighterShip.updateNode()
            
            // Check to see if we fully turned and then go back to wandering
            if let neededHeading = fighterShip.steeringBehavior?.targetPosition {
                if fighterShip.heading.dot(vector: neededHeading) < 0.1 {
                    fighterShip.stateMachine?.changeState(newState: FighterShipWanderState.sharedInstance)
                }
            }
        }
    }
}

