//
//  GameScene.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/8/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    // The drawing node created with the default project when pressing the screen
    private var spinnyNode : SKShapeNode?
    
    // The pause button
    private var pauseButton: SKShapeNode?
    
    override func didMove(to view: SKView) {
        print("didMove")
        
        // Update the configuration file with accurate game screen field dimensions
        Config.updateFieldDimenstions(fieldWidth: self.size.width, fieldHieght: self.size.height)
        
        // Set up the object manager for this game scene
        ObjectManager.sharedInstance.setup(scene: self)
        
        // Get the pause button and store it for later
        self.pauseButton = self.childNode(withName: "//pauseButton") as? SKShapeNode
        if let pauseButton = self.pauseButton {
            pauseButton.zPosition = Config.RenderPriority.TopLevelMenu
            print("Inititialized pause button")
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.02
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            spinnyNode.zPosition = 5.0
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        // Set the scene as the contact delegate of the physics engine
        physicsWorld.contactDelegate = self
    }
    
    func touchDown(atPoint pos : CGPoint) {
        print("Touched screen at \(Int(pos.x)), \(Int(pos.y))")
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            self.addChild(n)
//        }
        
        let touchedNode = self.nodes(at: pos)
        var touchedNodeNames = [String]()
        for n in touchedNode {
            if let myNode = n.name {
                print("Touched: \(myNode)")
                touchedNodeNames.append(myNode)
                
                // Pause button overrides everything
                if(myNode == "pauseButton") {
                    // Give a fancy little action to the pause button
                    if let pauseButton = self.pauseButton {
                        pauseButton.run(SKAction.sequence([SKAction.fadeIn(withDuration: 0.1), SKAction.fadeAlpha(to: Config.PauseButtonAlpha, duration: 0.2)]))
                    }
                    
                    // Empty out the touched nodes since the pause button was pressed and we don't care about what else was touched
                    touchedNodeNames.removeAll()
                    touchedNodeNames.append(myNode)
                    break
                }
            }
        }
        
        // Pass the along the position that the screen was touched
        ObjectManager.sharedInstance.screenTouched(pos: pos, touchType: Config.TouchDown, touchedNodes: touchedNodeNames)
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        // Pass the along the position that the screen was touched
        ObjectManager.sharedInstance.screenTouched(pos: pos, touchType: Config.TouchMoved)
    }
    
    func touchUp(atPoint pos : CGPoint) {
        // Pass the along the position that the screen was touched
        ObjectManager.sharedInstance.screenTouched(pos: pos, touchType: Config.TouchUp)
    }
    
    // Some contact was detected between two game physics objects
    func didBegin(_ contact: SKPhysicsContact) {
        ObjectManager.sharedInstance.addNewContactToQueue(contact: contact)
    }
    
    // Some contact between two game physics objects has now ended
    func didEnd(_ contact: SKPhysicsContact) {
        ObjectManager.sharedInstance.addEndedContactToQueue(contact: contact)
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
