//
//  ObjectTouchControls.swift
//  StarHero
//
//  Created by Bryan Van Zile on 6/27/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

protocol ObjectTouchControls {
    // The node that is used for touch controls
    var touchNode: SKShapeNode? { get }
    
    // Path drawn for moving along
    var line: SKShapeNode? { get }          // Node that stores and draws the path
    var path: CGMutablePath? { get }        // Different points that create the path
    var lastTouchPos: CGPoint? { get }      // Used only when we want to offset the touch position and not make it absolute
    var points: [CGPoint] { get set }       // Stores the points that make up the path in an array so it can be easily followed
}

extension ObjectTouchControls {
    // Setup the touch node
    func setupTouchNode() {
        touchNode?.fillColor = .clear
        touchNode?.lineWidth = 0
    }
    
    // Setup the path, return the point used for the path
    @discardableResult func drawPath(pos: CGPoint) -> CGPoint {
        var nextPoint = pos
        
        if let validPath = path {
            if validPath.isEmpty {
                // Setup the initial path
                validPath.move(to: nextPoint)
            }
            else {
                if let lastTouch = lastTouchPos {
                    nextPoint = (Vector(validPath.currentPoint) + (Vector(pos) - Vector(lastTouch))).toCGPoint()
                    validPath.addLine(to: nextPoint)
                }
                else {
                    validPath.addLine(to: nextPoint)
                }
                
                // Update the path with the next point
                line?.path = validPath
            }
        }
        
        return nextPoint
    }
    
    // Drawn line is released based on a velocity
    func releasePathNode(_ maxVelocity: CGFloat) {
        line?.run(SKAction.sequence([SKAction.wait(forDuration: Double(getPathLength(points) / maxVelocity)), SKAction.fadeOut(withDuration: 1.0)]))
    }
    
    // Drawn line is released based on a velocity
    func releasePathNode(invalidPath: Bool = true) {
        if let line = self.line {
            if line.alpha > 0.1 {
                if invalidPath {
                    line.strokeColor = .red
                    line.alpha = 0.2
                }
                line.run(SKAction.fadeOut(withDuration: 0.5))
            }
        }
    }
    
    // Add arrow
    func addArrow() {
        if let validPath = path {
            // We can only add an arrow if we have a direction
            if points.count > 3 {
                let start = points[points.count - 3]
                let end = points[points.count - 1]
                let pointerLineLength: CGFloat = 20.0
                let arrowAngle: CGFloat =  CGFloat(Double.pi / 4)
                
                let startEndAngle = atan((end.y - start.y) / (end.x - start.x)) + ((end.x - start.x) < 0 ? CGFloat(Double.pi) : 0)
                let arrowLine1 = CGPoint(x: end.x + pointerLineLength * cos(CGFloat(Double.pi) - startEndAngle + arrowAngle), y: end.y - pointerLineLength * sin(CGFloat(Double.pi) - startEndAngle + arrowAngle))
                let arrowLine2 = CGPoint(x: end.x + pointerLineLength * cos(CGFloat(Double.pi) - startEndAngle - arrowAngle), y: end.y - pointerLineLength * sin(CGFloat(Double.pi) - startEndAngle - arrowAngle))
                
                validPath.addLine(to: arrowLine1)
                validPath.move(to: end)
                validPath.addLine(to: arrowLine2)
                
                // Update the path with the arrow
                line?.path = validPath
            }
        }
    }
    
    // Get the length of a path (array of CGPoints)
    func getPathLength(_ points: [CGPoint]) -> CGFloat {
        var length: CGFloat = 0.0
        
        // Iterate through the array of points to add up the distances between points
        for (i, point) in points.enumerated() {
            if i + 1 < points.count {
                length += Vector(point).distanceBetween(vector: Vector(points[i + 1]))
            }
        }
        
        return length
    }
}
