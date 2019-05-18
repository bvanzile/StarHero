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
    
    // Sprite image locations
    static let FighterShipLocation: String = "FighterShip"
    
    // Fighter ship configurations
    static let FighterShipVelocity: Int = 10
    
    // Team names
    struct Team {
        static let RedTeam: Int = 0
        static let BlueTeam: Int = 1
        static let GreenTeam: Int = 2
        static let OrangeTeam: Int = 3
        static let NoTeam: Int = 4
    }
    
    // Colors used
    static let ColorRed: UIColor = UIColor(displayP3Red: 221.0/255.0, green: 34.0/255.0, blue: 34.0/255.0, alpha: 1.0)
    static let ColorBlue:UIColor = UIColor(displayP3Red: 36.0/255.0, green: 149.0/255.0, blue: 214.0/255.0, alpha: 1.0)
    static let ColorGreen:UIColor = UIColor(displayP3Red: 135.0/255.0, green: 188.0/255.0, blue: 64.0/255.0, alpha: 1.0)
    static let ColorTeal:UIColor = UIColor(displayP3Red: 50.0/255.0, green: 188.0/255.0, blue: 173.0/255.0, alpha: 1.0)
    static let ColorOrange:UIColor = UIColor(displayP3Red: 250.0/255.0, green: 162.0/255.0, blue: 28.0/255.0, alpha: 1.0)
    static let ColorDarkBlue:UIColor = UIColor(displayP3Red: 26.0/255.0, green: 87.0/255.0, blue: 168.0/255.0, alpha: 1.0)
}
