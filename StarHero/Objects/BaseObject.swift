//
//  BaseObject.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/17/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

class BaseObject {

    // State of the object
    var isActive: Bool = false
    
    // Unique name of this object, also used for the node
    var name: String = ""
    static var uniqueIdentifier: CUnsignedLong = 0
    
    // Team this object belongs to
    var team: Int = Config.Team.NoTeam
    
    // Direction this object is facing
    internal var position: Position = Position()
    internal var heading: CGFloat = 0.0
    
    // Default initializer
    init() {
        
    }
    
    // Add this object to the scene, must be called by subclass
    func addToScene() -> SKNode? {
        print("BaseObject addToScene - shouldn't see this")
        return nil
    }
    
    // Update
    func update() -> Bool {
        return true
    }
    
    // Get a unique name for the object, this version should be overwritten
    func getUniqueName() -> String {
        return ""
    }
    
    // Return the object's name
    func getName() -> String {
        return self.name
    }
    
    func destroy() {
        
    }
    
    // Assign color based on team input
    internal func getTeamColor() -> UIColor {
        switch self.team {
        case Config.Team.RedTeam:
            return Config.ColorRed
        case Config.Team.BlueTeam:
            return Config.ColorBlue
        case Config.Team.GreenTeam:
            return Config.ColorGreen
        case Config.Team.OrangeTeam:
            return Config.ColorOrange
        default:
            return Config.ColorTeal
        }
    }
}
