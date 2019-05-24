//
//  FighterShipAttackState.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/24/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation

class FighterShipAttackState: State {
    // Singleton instance to pass to the state machine
    static var sharedInstance: FighterShipAttackState = FighterShipAttackState()
    
    // Initializer, private as this shouldn't be initialized outside of the singleton
    private init() { }
    
    // Function for entering into a state
    func enter(object: BaseObject) {
        if let fighterShip = object as? FighterShip {
            if let target = fighterShip.target {
                print("\(fighterShip.name!) entering attack state")
                fighterShip.steeringBehavior?.setToPursue(target: target)
            }
            else {
                fighterShip.stateMachine?.changeState(newState: FighterShipWanderState.sharedInstance)
            }
        }
    }
    
    // Function for exiting a state
    func exit(object: BaseObject) {
        if let fighterShip = object as? FighterShip {
            fighterShip.target = nil
        }
    }
    
    // Function for updating a state
    func execute(object: BaseObject, dTime: TimeInterval) {
        if let fighterShip = object as? FighterShip {
            // Check if the target isn't nil
            if let target = fighterShip.target {
                // Check if the target is still alive
                if target.isActive {
                    fighterShip.fireMissile()
                    
                    // Change the ship to wander if the velocity returns false (velocity was set to 0 for some reason)
                    fighterShip.updateVelocity(timeElapsed: dTime)
                    fighterShip.updatePosition(timeElapsed: dTime)
                    fighterShip.updateNode()
                    
                    // When we return in bounds, go back to wandering
                    if(fighterShip.isOutOfBounds()) {
                        fighterShip.stateMachine?.changeState(newState: FighterShipReturnToFieldState.sharedInstance)
                    }
                }
                else {
                    fighterShip.stateMachine?.changeState(newState: FighterShipWanderState.sharedInstance)
                }
            }
            // The target was destroyed
            else {
                fighterShip.stateMachine?.changeState(newState: FighterShipWanderState.sharedInstance)
            }
        }
    }
}
