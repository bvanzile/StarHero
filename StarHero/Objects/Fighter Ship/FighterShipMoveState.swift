//
//  FighterShipMoveState.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/22/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation

class FighterShipMoveState: State {
    // Singleton instance to pass to the state machine
    static var sharedInstance: FighterShipMoveState = FighterShipMoveState()
    
    // Initializer, private as this shouldn't be initialized outside of the singleton
    private init() { }
    
    // Function for entering into a state
    func enter(object: BaseObject) {
        print("Entering movement state")
        if let fighterShip = object as? FighterShip {
            // Set the velocity to the ship's heading if it is currently not moving so that it doesn't turn around instantly
            if(fighterShip.velocity.length() == 0) {
                fighterShip.velocity = fighterShip.heading * fighterShip.takeoffSpeed
            }
        }
    }
    
    // Function for exiting a state
    func exit(object: BaseObject) {
        print("Exiting movement state")
        if let _ = object as? FighterShip {
        }
    }
    
    // Function for updating a state
    func execute(object: BaseObject, dTime: TimeInterval) {
        if let fighterShip = object as? FighterShip {
            fighterShip.updateVelocity(timeElapsed: dTime)
            fighterShip.updatePosition(timeElapsed: dTime)
            fighterShip.updateNode()
            
            print("State follow path array: \(fighterShip.steeringBehavior!.followPath.count)")
            if fighterShip.steeringBehavior!.followPath.isEmpty {
                fighterShip.stateMachine!.changeState(newState: FighterShipWanderState.sharedInstance)
            }
        }
    }
}
