//
//  State.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/19/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation

protocol State {
    // Function for entering into a state
    func enter(object: BaseObject)
    
    // Function for exiting a state
    func exit(object: BaseObject)
    
    // Function for updating a state
    func execute(object: BaseObject)
}
