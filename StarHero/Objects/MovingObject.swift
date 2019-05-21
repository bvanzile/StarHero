//
//  MovingObject.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/17/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

class MovingObject: BaseObject, VectorMath {
    
    // Things an object needs to move around
    var velocity: CGFloat = 0.0
    
    // Initializer
    override init(position: CGPoint?, heading: CGFloat = 0.0, team: Int = Config.Team.NoTeam) {
        super.init(position: position, heading: heading, team: team)
    }
    
    // Move the object from the current coordinate to a new coordinate by the velocity
    func travelOnPath() {
        // Update the position based on 2D vector math
        self.position.x = self.position.x + (self.velocity * cos(DegreesToRads(degrees: self.heading)))
        self.position.y = self.position.y + (self.velocity * sin(DegreesToRads(degrees: self.heading)))
    }
}
