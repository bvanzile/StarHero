//
//  PopupButtons.swift
//  StarHero
//
//  Created by Bryan Van Zile on 7/4/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

protocol PopupButtons: VectorMath {
    // Array of possible buttons
    var buttons: [SKSpriteNode] { get }
    
    // Determines if the buttons are currently popped up
    var buttonsOpen: Bool { get }
}

extension PopupButtons {
    // Show the buttons
    func showButtons(scale: CGFloat) -> Bool {
        if !buttonsOpen {
            for button in buttons {
                //button.run(SKAction.unhide())
                //button.isHidden = false
                //button.run(SKAction.scale(to: 2.0, duration: 1.0))
                //button.run(SKAction.scale(by: 0.5, duration: 1.0))
                button.run(SKAction.sequence([SKAction.unhide(), SKAction.scale(to: scale, duration: 0.25)]))
            }
            
            return true
        }
        return false
    }
    
    // Hide the buttons
    func hideButtons() -> Bool {
        if buttonsOpen {
            for button in buttons {
                //button.run(SKAction.hide())
                //button.run(SKAction.scale(by: 0.5, duration: 1.0))
                //button.isHidden = true
                button.run(SKAction.sequence([SKAction.scale(to: 0.01, duration: 0.25), SKAction.hide()]))
            }
            
            return false
        }
        return true
    }
    
    // Setup locations for the buttons
    func setPositions(length: CGFloat, offset: Int) {
        if buttons.count > 0 {
            var locations: [Vector] = [Vector(x: 0, y: 1)]
            var totalRotationDegrees: Int = 0
            
            for i in 1..<buttons.count {
                locations.append(locations[i - 1].rotate(degrees: -CGFloat(offset)))
                totalRotationDegrees += offset
            }
            
            if buttons.count == locations.count {
                for (i, button) in buttons.enumerated() {
                    let pos = locations[i].rotate(degrees: CGFloat(totalRotationDegrees) / 2)
                    button.position = (pos * length).toCGPoint()
                    button.zRotation = pos.toRads() - degreesToRads(degrees: 90)
                }
            }
        }
    }
}
