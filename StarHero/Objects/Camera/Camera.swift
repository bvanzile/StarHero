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
    
    // For scaling
    private let minScale: CGFloat = 0.75
    private let maxScale: CGFloat = 2.0
    private var currentScale: CGFloat = 1.0
    private var lastScale: CGFloat = 1.0
    
    // Storing the background in the camera to optimize
    var background: Background?
    
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
        
        let maxX = (Config.MaxFieldWidth / 2) - (Config.FieldWidth / 2)
        let maxY = (Config.MaxFieldHeight / 2) - (Config.FieldHeight / 2)
        
        if cameraNode.position.x > maxX {
            cameraNode.position.x = maxX
        }
        else if cameraNode.position.x < -maxX {
            cameraNode.position.x = -maxX
        }
        
        if cameraNode.position.y > maxY {
            cameraNode.position.y = maxY
        }
        else if cameraNode.position.y < -maxY {
            cameraNode.position.y = -maxY
        }
        
        // Update the last touched since we will now be touching somewhere else in the game view
        lastTouchDown?.x += deltaMove.x
        lastTouchDown?.y += deltaMove.y
        
        // Reset the delta since we used it
        deltaMove = Vector()
        
        optimizeBackground()
    }
    
    // Start camera movement
    func startMoving(_ touchDownPosition: CGPoint) {
        // This implies two touchdowns which means probable pinch gesture
        if isMoving {
            stopMoving()
            return
        }
        
        // Capture where the touch down occurred so we can capture the delta
        lastTouchDown = touchDownPosition
        
        isMoving = true
    }
    
    // End the camera movement
    func stopMoving() {
        lastTouchDown = nil
        
        isMoving = false
    }
    
    // Start scaling the camera
    func startScale() {
        lastScale = 1.0
    }
    
    // Scale the camera
    func setScale(_ scale: CGFloat) {
        let scaleDelta = (lastScale - scale) / 2
        currentScale += scaleDelta
        
        if currentScale > maxScale { currentScale = maxScale }
        else if currentScale < minScale { currentScale = minScale }
        
        cameraNode.setScale(currentScale)
        
        lastScale = scale
        
        optimizeBackground()
    }
    
    // Draw background nodes that are visible
    func optimizeBackground() {
        if let bg = background {
            for node in bg.backgroundNodes {
                if cameraNode.contains(node) {
                    node.isHidden = false
                }
                else {
                    node.isHidden = true
                }
            }
        }
    }
    
    // Get the camera
    func getNode() -> SKCameraNode {
        return cameraNode
    }
}
