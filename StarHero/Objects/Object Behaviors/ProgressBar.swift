//
//  ProgressBar.swift
//  StarHero
//
//  Created by Bryan Van Zile on 7/5/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

class ProgressBar {
    // Progress bars
    private var progressBar: SKSpriteNode
    private var backgroundBar: SKSpriteNode
    
    // Determines if something is in progress
    var inProgress: Bool = false
    var storedAction: String?
    
    // Storing the colors
    private var fgColor: UIColor
    private var completeColor: UIColor
    
    init(width: CGFloat, height: CGFloat, x: CGFloat, y: CGFloat, bgColor: UIColor = .black, fgColor: UIColor = UIColor(red: 30, green: 120, blue: 174), completeColor: UIColor = UIColor(red: 50, green: 188, blue: 173)) {
        // Grab the colors
        self.fgColor = fgColor
        self.completeColor = completeColor
        
        // Setup the first bar
        progressBar = SKSpriteNode(color: bgColor, size: CGSize(width: width, height: height))
        progressBar.position = CGPoint(x: -(progressBar.frame.maxX), y: y)
        progressBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        progressBar.alpha = 1.0
        
        // Become an exact copy
        backgroundBar = progressBar.copy() as! SKSpriteNode
        
        // Setup the foreground differences
        progressBar.xScale = 0.0
        progressBar.color = fgColor
        
        backgroundBar.isHidden = true
        progressBar.isHidden = true
    }
    
    // Add the nodes to the game
    func addNodes(toNode: SKNode) {
        toNode.addChild(backgroundBar)
        toNode.addChild(progressBar)
    }
    
    // Start the progress bar
    func start(action: String, duration: Double) {
        if !inProgress {
            // Start up the progress
            inProgress = true
            storedAction = action
            
            backgroundBar.removeAllActions()
            progressBar.removeAllActions()
            
            backgroundBar.run(SKAction.sequence([SKAction.unhide(), SKAction.fadeIn(withDuration: 0.2)]))
            progressBar.xScale = 0.0
            progressBar.color = fgColor
            progressBar.run(SKAction.sequence([SKAction.unhide(), SKAction.fadeIn(withDuration: 0.2), SKAction.scaleX(to: 1.0, duration: duration - 0.2)]))
        }
    }
    
    // Stop the progress bar
    func stop() {
        if inProgress {
            inProgress = false
            
            backgroundBar.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.4), SKAction.hide()]))
            progressBar.run(SKAction.sequence([SKAction.colorize(with: completeColor, colorBlendFactor: 1.0, duration: 0.2), SKAction.fadeOut(withDuration: 0.2), SKAction.hide(), SKAction.scaleX(to: 0.0, duration: 0.0)]))
        }
    }
    
    // Update
    func update() -> String? {
        if inProgress && progressBar.xScale > 0.999 {
            stop()
            
            if storedAction != nil {
                let returnAction = storedAction!
                storedAction = nil
                
                return returnAction
            }
        }
        
        return nil
    }
}
