//
//  FighterShipWanderState.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/19/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation

class FighterShipWanderState: State {
    // Singleton instance to pass to the state machine
    static var sharedInstance: FighterShipWanderState = FighterShipWanderState()
    
    // Initializer, private as this shouldn't be initialized outside of the singleton
    private init() { }
    
    // Function for entering into a state
    func enter(object: BaseObject) {
        //print("Entering Wander")
        if let fighterShip = object as? FighterShip {
            //print("\(fighterShip.name!) entering wander state")
            
            // If the ship still sees something, attack it
            if fighterShip.seesAttackableEnemy() {
                fighterShip.stateMachine?.changeState(newState: FighterShipAttackState.sharedInstance)
            }
            else {
                fighterShip.steeringBehavior?.setToWander()
            }
        }
    }
    
    // Function for exiting a state
    func exit(object: BaseObject) {
        if let _ = object as? FighterShip {
            //print("\(fighterShip.name!) exiting wander state")
        }
    }
    
    // Function for updating a state
    func execute(object: BaseObject, dTime: TimeInterval) {
        if let fighterShip = object as? FighterShip {
            // Change the ship to wander if the velocity returns false (velocity was set to 0 for some reason)
            fighterShip.updateVelocity(timeElapsed: dTime)
            fighterShip.updatePosition(timeElapsed: dTime)
            fighterShip.updateNode()
            
            // If the ship sees something, attack it
            if fighterShip.seesAttackableEnemy() {
                fighterShip.stateMachine?.changeState(newState: FighterShipAttackState.sharedInstance)
            }
        }
    }
}
