//
//  MotherShipMoveState.swift
//  StarHero
//
//  Created by Bryan Van Zile on 6/28/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation

class MotherShipMoveState: State {
    // Singleton instance to pass to the state machine
    static var sharedInstance: MotherShipMoveState = MotherShipMoveState()
    
    // Initializer, private as this shouldn't be initialized outside of the singleton
    private init() { }
    
    // Function for entering into a state
    func enter(object: BaseObject) {
        print("Entering movement state")
        if let _ = object as? MotherShip {
            
        }
    }
    
    // Function for exiting a state
    func exit(object: BaseObject) {
        print("Exiting movement state")
        if let _ = object as? MotherShip {
        }
    }
    
    // Function for updating a state
    func execute(object: BaseObject, dTime: TimeInterval) {
        if let motherShip = object as? MotherShip {
            motherShip.updateVelocity(timeElapsed: dTime)
            motherShip.updatePosition(timeElapsed: dTime)
            motherShip.updateNode(ignoreHeading: true)
            
            if motherShip.steeringBehavior!.followPath.isEmpty {
                motherShip.stateMachine!.changeState(newState: MotherShipIdleState.sharedInstance)
            }
        }
    }
}
