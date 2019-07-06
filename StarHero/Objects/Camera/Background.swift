//
//  Background.swift
//  StarHero
//
//  Created by Bryan Van Zile on 7/5/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

class Background {
    var backgroundNodes: [SKSpriteNode] = [SKSpriteNode]()
    
    init(scene: GameScene, fieldWidth: CGFloat, fieldHeight: CGFloat) {
        let background: SKSpriteNode = SKSpriteNode(imageNamed: "Background500")
        background.zPosition = Config.RenderPriority.GameBackground
        
        let bgWidth = background.frame.maxX * 2
        let bgHeight = background.frame.maxY * 2
        let xAmount = Int(fieldWidth / bgWidth)
        let yAmount = Int(fieldHeight / bgHeight)
        
        print("width: \(bgWidth), height: \(bgHeight)")
        print("x#: \(xAmount), y#: \(yAmount)")
        
        for x in 0...xAmount {
            for y in 0...yAmount {
                let nextTile: SKSpriteNode = background.copy() as! SKSpriteNode
                nextTile.position.y = -(fieldHeight / 2) + (CGFloat(y) * bgHeight)// + (bgHeight / 2)
                nextTile.position.x = -(fieldWidth / 2) + (CGFloat(x) * bgWidth)// + (bgWidth / 2)
                
                backgroundNodes.append(nextTile)
            }
        }
        
        for bg in backgroundNodes {
            scene.addChild(bg)
        }
    }
}
