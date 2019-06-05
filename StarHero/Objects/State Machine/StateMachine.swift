//
//  StateMachine.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/19/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation

class StateMachine {
    // The object that is using this state machine
    var objectOwner: BaseObject
    
    // Stored states in the machine
    var currentState: State?
    var previousState: State?
    
    // Initializer
    init(object: BaseObject, currentState: State? = nil, previousState: State? = nil) {
        // Set the state machine owner
        objectOwner = object
        
        // Set the current and previous states, if necessary
        self.currentState = currentState
        self.previousState = previousState
    }
    
    // Initializers for setting the state machine up
    func setCurrentState(state: State) { currentState = state }
    func setPreviousState(state: State) { previousState = state }
    
    // Getters
    func getCurrentState() -> State? { return currentState }
    func getPreviousState() -> State? { return previousState }
    
    // Call the current state execution function
    func update(dTime: TimeInterval) {
        currentState?.execute(object: objectOwner, dTime: dTime)
    }
    
    //
    func changeState(newState: State?) {
        // Unwrap the new state
        if let newState = newState {
            // Update the previous state
            previousState = currentState
            
            // Run the current state's exit method if it exists
            currentState?.exit(object: objectOwner)
            
            // Update the current state with the input new state
            currentState = newState
            
            // Run the enter method for the new state
            currentState?.enter(object: objectOwner)
        }
        else {
            print("New state is nil, didn't change states")
        }
    }
    
    // Return to the previous state
    func revertToPreviousState() {
        if previousState != nil {
            changeState(newState: previousState)
        }
        else {
            print("Can't revert to previous state as it is nil")
        }
    }
    
    // Checks if the current state matches the parameter
    func isInState(_ states: State...) -> Bool {
        for state in states {
            if let currentState = currentState {
                if object_getClassName(currentState) == object_getClassName(state) {
                    return true
                }
            }
        }
        
        return false
    }
}
