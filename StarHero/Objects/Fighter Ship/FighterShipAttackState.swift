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
        //print("Entering Attack")
        if let fighterShip = object as? FighterShip {
            // Check if we see anything
            //print("\(fighterShip.name!) is attacking")
            if !fighterShip.seesAttackableEnemy() {
                // Nothing in sight so go back to wandering
                fighterShip.stateMachine?.changeState(newState: FighterShipWanderState.sharedInstance)
            }
            else {
                // Begin the pursuit on the closest fighter ship in vision
                if let closest = fighterShip.getClosestEnemyToAttack() {
                    // Start going after the closest ship
                    fighterShip.steeringBehavior?.setToPursue(target: closest)
                }
                else {
                    fighterShip.stateMachine?.changeState(newState: FighterShipWanderState.sharedInstance)
                }
            }
        }
    }
    
    // Function for exiting a state
    func exit(object: BaseObject) {
        if let fighterShip = object as? FighterShip {
            fighterShip.steeringBehavior?.pursuedTarget = nil
        }
    }
    
    // Function for updating a state
    func execute(object: BaseObject, dTime: TimeInterval) {
        if let fighterShip = object as? FighterShip {
            // Check if the target isn't nil
            if let target = fighterShip.steeringBehavior?.pursuedTarget {
                // Check if the target is still alive
                if target.isActive {
                    fighterShip.attackTarget()
                    
                    // Change the ship to wander if the velocity returns false (velocity was set to 0 for some reason)
                    fighterShip.updateVelocity(timeElapsed: dTime)
                    fighterShip.updatePosition(timeElapsed: dTime)
                    fighterShip.updateNode()
                    
                    // Check if the pursued ship is still in sight
                    if !fighterShip.doesSee(target.name!) {
                        // Lost sight, start wandering
                        fighterShip.stateMachine?.changeState(newState: FighterShipWanderState.sharedInstance)
                    }
                }
                else {
                    // Remove from seen if possible
                    if let targetName = target.name {
                        fighterShip.objectsInSight.removeValue(forKey: targetName)
                    }
                    
                    // Check if we still see something to attack
                    if fighterShip.seesAttackableEnemy() {
                        fighterShip.stateMachine?.changeState(newState: FighterShipAttackState.sharedInstance)
                    }
                    else {
                        // Start to wander
                        fighterShip.stateMachine?.changeState(newState: FighterShipWanderState.sharedInstance)
                    }
                }
            }
            // The target was destroyed
            else {
                fighterShip.stateMachine?.changeState(newState: FighterShipWanderState.sharedInstance)
            }
        }
    }
}
