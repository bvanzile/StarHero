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
            // Check if we see anything
            //print("\(fighterShip.name!) is attacking")
            if !fighterShip.seesEnemyFighterShip() {
                // Nothing in sight so go back to wandering
                fighterShip.stateMachine?.changeState(newState: FighterShipWanderState.sharedInstance)
            }
            else {
                // Begin the pursuit on the closest fighter ship in vision
                if let closest = fighterShip.getClosestEnemyFighterShip() {
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
                    
                    // Jump out of the way if you get too close
                    if (fighterShip.position - target.position).length() < fighterShip.velocity.length() * 1.1 {
                        // Check if you are facing each other and about to collide
                        let collisionAngle = fighterShip.heading.dot(vector: target.heading)
                        let collisionPosition = (target.position - fighterShip.position).dot(vector: fighterShip.heading)

                        // If the other ship is coming right for this one
                        if collisionAngle > 2.7 && collisionPosition < 1.0 {
                            // Always turn right as a courtesy in this situation
                            let dodgeDirection = fighterShip.heading.right()
                            
                            //fighterShip.lastThreatHeading = dodgeDirection.reverse()
                            fighterShip.steeringBehavior?.setToGo(direction: dodgeDirection)
                            fighterShip.stateMachine?.changeState(newState: FighterShipDodgeState.sharedInstance)
                        }
                        else {
                            if fighterShip.heading.right().dot(vector: (target.position - fighterShip.position) + target.velocity) < 1.5708 {
                                // Enemy is to the right so dodge to the left
                                let dodgeDirection = fighterShip.heading.left()
                                
                                fighterShip.steeringBehavior?.setToGo(direction: dodgeDirection)
                                fighterShip.stateMachine?.changeState(newState: FighterShipDodgeState.sharedInstance)
                            }
                            else {
                                // Enemy must be to the left so dodge to the right
                                let dodgeDirection = fighterShip.heading.right()
                                
                                fighterShip.steeringBehavior?.setToGo(direction: dodgeDirection)
                                fighterShip.stateMachine?.changeState(newState: FighterShipDodgeState.sharedInstance)
                            }
                        }
                    }
                }
                else {
                    // Remove from seen if possible
                    if let targetName = target.name {
                        fighterShip.objectsInSight.removeValue(forKey: targetName)
                    }
                    
                    // Check if we still see something to attack
                    if fighterShip.seesEnemyFighterShip() {
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
