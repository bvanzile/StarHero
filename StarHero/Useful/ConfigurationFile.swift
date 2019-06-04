//
//  ConfigurationFile.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/17/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

struct Config {
    // Call for updating the width and height of the game scene
    static func updateFieldDimenstions(fieldWidth: CGFloat, fieldHieght: CGFloat) {
        self.FieldWidth = fieldWidth
        self.FieldHeight = fieldHieght
    }
    
    // Field boundaries
    static var FieldWidth: CGFloat = 0.0
    static var FieldHeight: CGFloat = 0.0
    
    // Types of screen touches
    static let TouchUp: Int = 0
    static let TouchDown: Int = 1
    static let TouchMoved: Int = 2
    
    // Different layers of the game scene (zPosition)
    struct RenderPriority {
        static let TopLevelMenu: CGFloat = 2.0
        static let GameFront: CGFloat = 1.0
        static let GameDefault: CGFloat = 0.0
        static let GameBottom: CGFloat = -1.0
    }
    
    // Collision detection: bitmask categories
    struct BitMaskCategory {
        static let FighterShip: UInt32 = 0x1 << 1
        static let MotherShip: UInt32 = 0x1 << 2
        static let Drone: UInt32 = 0x1 << 3
        static let Sight: UInt32 = 0x1 << 4
        static let Missile: UInt32 = 0x1 << 5
        static let All: UInt32 = UInt32.max
    }
    
    // For the game pause button
    static let PauseButtonAlpha: CGFloat = 0.5
    
    // Sprite image locations
    static let FighterShipLocation: String = "FighterShipDetailed"
    static let FighterShipScale: CGFloat = 0.3           // Factor to scale the fighter ship to from image size to screen size
    
    // Fighter ship physics configurations
    static let FighterShipMass: CGFloat = 25             // Weight of the ship for movement physics
    static let FighterShipMaxSpeed: CGFloat = 120        // Units/second
    static let FighterShipTakeoffSpeed: CGFloat = 5      // Units/second
    static let FighterShipMaxForce: CGFloat = 75         // For acceleration/turn rate
    static let FighterShipDeceleration: CGFloat = 0.8    // Rate of deceleration for an arrival, higher is faster
    static let FighterShipSightDistance: CGFloat = 1000.0
    static let FighterShipSightPeripheral: CGFloat = 100.0
    
    // Special fighter ship configurations
    static let FighterShipMaxMissileCount: Int = 2
    static let FighterShipFiringLimit: CGFloat = 1.0
    static let FighterShipReloadCooldown: CGFloat = 2.0
    
    // Missile constants
    static let MissileLocation: String = "Missile"
    static let MissileScale: CGFloat = 0.1
    
    // Missile physics
    static let MissileMass: CGFloat = 1
    static let MissileMaxSpeed: CGFloat = 500
    static let MissileTakeoffSpeed: CGFloat = 0.0
    static let MissileMaxForce: CGFloat = 100
    static let MissileDeceleration: CGFloat = 0.1
    
    // Team names
    struct Team {
        static let RedTeam: Int = 0
        static let BlueTeam: Int = 1
        static let GreenTeam: Int = 2
        static let OrangeTeam: Int = 3
        static let NoTeam: Int = 4
        static let RandomTeam: Int = 5
        
        static func getRandomTeam() -> Int {
            return Int.random(in: 0...4)
        }
    }
    
    // Colors used
    static let ColorRed: UIColor = UIColor(displayP3Red: 221.0/255.0, green: 34.0/255.0, blue: 34.0/255.0, alpha: 1.0)
    static let ColorBlue:UIColor = UIColor(displayP3Red: 36.0/255.0, green: 149.0/255.0, blue: 214.0/255.0, alpha: 1.0)
    static let ColorGreen:UIColor = UIColor(displayP3Red: 135.0/255.0, green: 188.0/255.0, blue: 64.0/255.0, alpha: 1.0)
    static let ColorTeal:UIColor = UIColor(displayP3Red: 50.0/255.0, green: 188.0/255.0, blue: 173.0/255.0, alpha: 1.0)
    static let ColorOrange:UIColor = UIColor(displayP3Red: 250.0/255.0, green: 162.0/255.0, blue: 28.0/255.0, alpha: 1.0)
    static let ColorDarkBlue:UIColor = UIColor(displayP3Red: 26.0/255.0, green: 87.0/255.0, blue: 168.0/255.0, alpha: 1.0)
    
    // Assign color based on team input
    static func getTeamColor(team: Int) -> UIColor {
        switch team {
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
