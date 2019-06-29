//
//  ConfigurationFile.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/17/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}

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
        static let GameBackground: CGFloat = -2.0
    }
    
    // Collision detection: bitmask categories
    struct BitMaskCategory {
        static let FighterShip: UInt32 = 0x1 << 1
        static let MotherShip: UInt32 = 0x1 << 2
        static let Drone: UInt32 = 0x1 << 3
        static let Sight: UInt32 = 0x1 << 4
        static let Peripheral: UInt32 = 0x1 << 5
        static let Missile: UInt32 = 0x1 << 6
        static let All: UInt32 = UInt32.max
    }
    
    // For the game pause button
    static let PauseButtonAlpha: CGFloat = 0.5
    
    // Sprite image locations - Mothership
    static let MotherShipLocation: String = "MotherShip2"
    static let MotherShipScale: CGFloat = 1.25           // Factor to scale the fighter ship to from image size to screen size
    
    // Fighter ship physics configurations
    static let MotherShipMass: CGFloat = 200            // Weight of the ship for movement physics
    static let MotherShipMaxSpeed: CGFloat = 45         // Units/second
    static let MotherShipTakeoffSpeed: CGFloat = 1      // Units/second
    static let MotherShipMaxForce: CGFloat = 200        // For acceleration/turn rate
    static let MotherShipDeceleration: CGFloat = 0.5    // Rate of deceleration for an arrival, higher is faster
    
    // Mothership actions
    static let MotherShipSpawnCooldown: Double = 8.0    // How long between fighter ship spawns
    static let MotherShipInitialSpawn: Int = 4          // How many fighters spawn at the start
    static let MotherShipBoundaryLength: CGFloat = 750
    
    // Sprite image locations - Fightership
    static let FighterShipLocation: String = "FighterShipEmpty"
    static let FighterShipScale: CGFloat = 0.3           // Factor to scale the fighter ship to from image size to screen size
    
    // Fighter ship physics configurations
    static let FighterShipMass: CGFloat = 25             // Weight of the ship for movement physics
    static let FighterShipMaxSpeed: CGFloat = 120        // Units/second
    static let FighterShipTakeoffSpeed: CGFloat = 5      // Units/second
    static let FighterShipMaxForce: CGFloat = 85         // For acceleration/turn rate
    static let FighterShipDeceleration: CGFloat = 0.8    // Rate of deceleration for an arrival, higher is faster
    static let FighterShipSightDistance: CGFloat = 325    // 325  1100
    static let FighterShipSightFOV: CGFloat = 100
    static let FighterShipPeripheralRadius: CGFloat = 60      // 60
    
    // Special fighter ship configurations
    static let FighterShipMaxMissileCount: Int = 2
    static let FighterShipFiringLimit: CGFloat = 0.75
    static let FighterShipReloadCooldown: CGFloat = 2.0
    
    // Missile constants
    static let MissileLocation: String = "MissilePlain"
    static let MissileScale: CGFloat = 0.1
    
    // Missile physics
    static let MissileMass: CGFloat = 3
    static let MissileMaxSpeed: CGFloat = 500
    static let MissileTakeoffSpeed: CGFloat = 0.0
    static let MissileMaxForce: CGFloat = 100
    static let MissileDeceleration: CGFloat = 0.1
    
    // Explosion constants
    static let InitialExplosions: Int = 10
    static let ExplosionsPerSecond: Double = 25.0
    static let ExplosionScale: CGFloat = 0.35
    
    // Explosion colors
    static let ExplosionColors: [UIColor] = [
        UIColor(red: 221, green: 34, blue: 34),     // red
        UIColor(red: 250, green: 162, blue: 28),    // orange
        UIColor(red: 255, green: 250, blue: 35),    // yellow
        UIColor(red: 88, green: 88, blue: 88) ]     // gray
    
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
    static let ColorRed: UIColor = UIColor(red: 221, green: 34, blue: 34)
    static let ColorBlue: UIColor = UIColor(red: 36, green: 149, blue: 214)
    static let ColorGreen: UIColor = UIColor(red: 135, green: 188, blue: 64)
    static let ColorTeal: UIColor = UIColor(red: 50, green: 188, blue: 173)
    static let ColorOrange: UIColor = UIColor(red: 250, green: 162, blue: 28)
    static let ColorDarkBlue: UIColor = UIColor(red: 26, green: 87, blue: 168)
    
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
