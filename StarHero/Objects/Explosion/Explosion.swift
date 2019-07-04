//
//  Explosion.swift
//  StarHero
//
//  Created by Bryan Van Zile on 6/5/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

class Explosion: BaseObject, VectorMath {
    // Explosion parent node to build off of, could possibly make this tappable in the future for whatever reason
    private var explosionOrigin: SKShapeNode = SKShapeNode()
    private var isExploding: Bool = true
    
    // Variables required of an explosion
    private var duration: Double = 1.0      // seconds
    private var size: CGFloat = 0.0         // radius
    private var blockSize: CGFloat = 1.0    // length of single square of explosion
    private var force: Vector = Vector()    // force of impact
    
    // For calculating how many explosions to create this time around
    private var remainder: Double = 0.0
    private let explosionCooldown: Double = 1 / Config.ExplosionsPerSecond
    private var colorIndex: Int = 0
    
    // Initializer for an explosion
    init(position: Vector, size: CGFloat? = nil, duration: Double? = nil, force: Vector? = nil) {
        super.init(position: position)
        
        explosionOrigin.position = position.toCGPoint()
        explosionOrigin.zPosition = Config.RenderPriority.GameFront + 0.1
        
        self.duration = duration ?? self.duration
        self.force = force ?? self.force
        self.size = size ?? self.size
        
        self.blockSize = self.size * Config.ExplosionScale
        
        name = getUniqueName()
        explosionOrigin.name = name
        
        for _ in 0..<Config.InitialExplosions {
            self.addExplosion(ignoreForce: true)
        }
    }
    
    private func addExplosion(ignoreForce: Bool = false) {
        let explosion = SKShapeNode(rectOf: CGSize(width: blockSize, height: blockSize))
        
        explosion.fillColor = Config.ExplosionColors[colorIndex]
        
        if colorIndex >= Config.ExplosionColors.count - 1 {
            colorIndex = 0
        } else {
            colorIndex += 1
        }
        
        var appliedForce: Vector = Vector()
        if !ignoreForce {
            appliedForce = force * CGFloat.random(in: 0...1)
        }
        
        explosion.position = ((randomVector() * (CGFloat.random(in: 0...1) * size / 2)) + appliedForce).toCGPoint()
        explosion.lineWidth = 0
        explosion.isAntialiased = false
        explosion.run(SKAction.sequence([SKAction.wait(forDuration: 0.3),
                                         SKAction.removeFromParent()]))
        explosionOrigin.addChild(explosion)
    }
    
    // Update function, return true if update successful, return false if this object is ready to be terminated
    override func update(dTime: TimeInterval) -> Bool {
        if isExploding {
            // Start adding explosions
            remainder += dTime
            
            while remainder > explosionCooldown {
                self.addExplosion()
                
                remainder -= explosionCooldown
            }
            
            // Remove this explosion when the time expires
            duration -= dTime
            if duration < 0 {
                isExploding = false
            }
        }
        
        // Once the explosion is completed, remove it from the game
        if explosionOrigin.children.isEmpty {
            return false
        }
        
        return true
    }
    
    override func getNode() -> SKNode { return explosionOrigin }
}
