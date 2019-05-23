//
//  GameScene.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/8/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    // The drawing node created with the default project when pressing the screen
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        print("didMove")
        
        // Update the configuration file with accurate game screen field dimensions
        Config.updateFieldDimenstions(fieldWidth: self.size.width, fieldHieght: self.size.height)
        
        // Set up the object manager for this game scene
        for node in ObjectManager.sharedInstance.setup() {
            self.addChild(node)
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.02
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        print("touchDown at \(pos)")
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
        
        let touchedNode = self.nodes(at: pos)
        var touchedNodeNames = [String]()
        for n in touchedNode {
            if let myNode = n.name {
                print("Touched: \(myNode)")
                touchedNodeNames.append(myNode)
            }
        }
        
        // Pass the along the position that the screen was touched
        ObjectManager.sharedInstance.screenTouched(pos: pos, touchType: Config.TouchDown, touchedNodes: touchedNodeNames)
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
        
        // Pass the along the position that the screen was touched
        ObjectManager.sharedInstance.screenTouched(pos: pos, touchType: Config.TouchMoved)
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
        
        // Pass the along the position that the screen was touched
        ObjectManager.sharedInstance.screenTouched(pos: pos, touchType: Config.TouchUp)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        // Update the game objects
        ObjectManager.sharedInstance.update(currentTime: currentTime)
    }
}
