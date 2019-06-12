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
    // The pause button
    private var pauseButton: SKShapeNode?
    
    override func didMove(to view: SKView) {
        print("didMove")
        
        // Update the configuration file with accurate game screen field dimensions
        Config.updateFieldDimenstions(fieldWidth: self.size.width, fieldHieght: self.size.height)
        
        // Set up the object manager for this game scene
        ObjectManager.sharedInstance.setup(scene: self)
        ObjectManager.sharedInstance.newGame()
        
        // Get the pause button and store it for later
        pauseButton = childNode(withName: "//pauseButton") as? SKShapeNode
        if let pauseButton = self.pauseButton {
            // Put the pause button on the top
            pauseButton.zPosition = Config.RenderPriority.TopLevelMenu
            
            // Move the pause button to the camera node so it stays on screen
            pauseButton.move(toParent: ObjectManager.sharedInstance.gameCamera.getNode())
            
            print("Inititialized pause button")
        }
        
        // Set the scene as the contact delegate of the physics engine
        physicsWorld.contactDelegate = self
    }
    
    func touchDown(atPoint pos : CGPoint) {
        print("Touched screen at \(Int(pos.x)), \(Int(pos.y))")
        
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
