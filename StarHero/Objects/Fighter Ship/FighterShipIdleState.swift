//
//  FighterShipIdleState.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/21/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation

class FighterShipIdleState: State {
    // Singleton instance to pass to the state machine
    static var sharedInstance: FighterShipIdleState = FighterShipIdleState()
    
    // Initializer, private as this shouldn't be initialized outside of the singleton
    private init() { }
    
    // Function for entering into a state
    func enter(object: BaseObject) {
        if let fighterShip = object as? FighterShip {
            fighterShip.steeringBehavior?.setToIdle()
        }
    }
    
    // Function for exiting a state
    func exit(object: BaseObject) {
        if let _ = object as? FighterShip {
            
        }
    }
    
    // Function for updating a state
    func execute(object: BaseObject, dTime: TimeInterval) {
        if let _ = object as? FighterShip {
            // do nothing for now
        }
    }
}

