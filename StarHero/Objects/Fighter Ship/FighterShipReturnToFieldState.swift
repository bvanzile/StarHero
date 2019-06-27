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
            fighterShip.steeringBehavior?.setToSeek(target: Vector(point: fighterShip.boundaryOrigin!.position))
            
//            // Check if we are in a corner
//            if abs(fighterShip.position.x) > Config.FieldWidth / 2 * 0.85 && abs(fighterShip.position.y) > Config.FieldHeight / 2 * 0.85 {
//                //print("\(fighterShip.name!) is in a corner, headed back to center")
//                fighterShip.steeringBehavior?.setToSeek(target: Vector(x: 0, y: 0))
//            }
//            else if fighterShip.position.x > Config.FieldWidth / 2 {
//                // Ship crossed the wall on the right so we reverse along the y axis
//                //print("\(fighterShip.name!) hit the right boundary")
//                var returnVector = fighterShip.heading
//                returnVector.x = -abs(returnVector.x)
//
//                fighterShip.steeringBehavior?.setToSeek(target: fighterShip.position + returnVector * fighterShip.maxSpeed)
//            }
//            else if fighterShip.position.x < -Config.FieldWidth / 2 {
//                // Ship crossed the wall on the left so we reverse along the y axis
//                //print("\(fighterShip.name!) hit the left boundary")
//                var returnVector = fighterShip.heading
//                returnVector.x = abs(returnVector.x)
//
//                fighterShip.steeringBehavior?.setToSeek(target: fighterShip.position + returnVector * fighterShip.maxSpeed)
//            }
//            else if fighterShip.position.y > Config.FieldHeight / 2 {
//                // Ship crossed the wall on the top so we reverse along the y axis
//                //print("\(fighterShip.name!) hit the top boundary")
//                var returnVector = fighterShip.heading
//                returnVector.y = -abs(returnVector.y)
//
//                fighterShip.steeringBehavior?.setToSeek(target: fighterShip.position + returnVector * fighterShip.maxSpeed)
//            }
//            else if fighterShip.position.y < -Config.FieldHeight / 2 {
//                // Ship crossed the wall on the bottom so we reverse along the y axis
//                //print("\(fighterShip.name!) hit the bottom boundary")
//                var returnVector = fighterShip.heading
//                returnVector.y = abs(returnVector.y)
//
//                fighterShip.steeringBehavior?.setToSeek(target: fighterShip.position + returnVector * fighterShip.maxSpeed)
//            }
//            else {
//                // Don't know how we ended up here, go to the middle I guess
//                print("\(fighterShip.name!) is super lost and had to return to the middle")
//                fighterShip.steeringBehavior?.setToSeek(target: Vector(x: 0, y: 0))
//            }
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
