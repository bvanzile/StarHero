//
//  Camera.swift
//  StarHero
//
//  Created by Bryan Van Zile on 6/12/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

class Camera {
    // The camera node used in the game scene
    private var cameraNode: SKCameraNode = SKCameraNode()
    
    // Stores the delta that has been saved up
    private var deltaMove: Vector = Vector()
    private var isMoving: Bool = false
    private var lastTouchDown: CGPoint? = nil
    
    init(_ start: CGPoint? = nil) {
        if let startingPoint = start {
            cameraNode.position = startingPoint
        }
        
        cameraNode.name = "Camera"
    }
    
    // Update the camera
    func update(time: TimeInterval) {
        if !deltaMove.isZero() {
            moveCamera()
        }
    }
    
    // Update the delta movement when the camera movement is active and new positions are being recieved
    func movingInput(_ pos: CGPoint) {
        if isMoving && lastTouchDown != nil {
            deltaMove.x += lastTouchDown!.x - pos.x
            deltaMove.y += lastTouchDown!.y - pos.y
            
            lastTouchDown = pos
        }
    }
    
    // Move the camera by the change in position for this interval
    func moveCamera(_ timingMode: SKActionTimingMode = .linear) {
        // Move the camera
        cameraNode.position.x += deltaMove.x
        cameraNode.position.y += deltaMove.y
        
        // Update the last touched since we will now be touching somewhere else in the game view
        lastTouchDown?.x += deltaMove.x
        lastTouchDown?.y += deltaMove.y
        
        // Reset the delta since we used it
        deltaMove = Vector()
    }
    
    // Start camera movement
    func startMoving(_ touchDownPosition: CGPoint) {
        if isMoving { print("startMoving called: Camera was already moving, this should never happen") }
        
        // Capture where the touch down occurred so we can capture the delta
        lastTouchDown = touchDownPosition
        
        isMoving = true
    }
    
    // End the camera movement
    func stopMoving() {
        lastTouchDown = nil
        
        isMoving = false
    }
    
    // Get the camera
    func getNode() -> SKCameraNode {
        return cameraNode
    }
}
