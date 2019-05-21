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
        if let fighterShip = object as? FighterShip {
            print("\(fighterShip.name!) entering wander state")
        }
    }
    
    // Function for exiting a state
    func exit(object: BaseObject) {
        if let fighterShip = object as? FighterShip {
            print("\(fighterShip.name!) exiting wander state")
        }
    }
    
    // Function for updating a state
    func execute(object: BaseObject) {
        if let fighterShip = object as? FighterShip {
            fighterShip.travelOnPath()
        }
    }
}
