//
//  SteeringBehavior.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/21/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

enum SteeringBehaviors {
    case Go
    case Seek
    case Arrive
    case Flee
    case Wander
    case Pursue
    case Idle
}

class SteeringBehavior {
    // The vehicle that is using this steering behavior
    var movingObject: MovingObject
    
    // The current active steering behavior
    private var activeSteeringBehavior: SteeringBehaviors = SteeringBehaviors.Idle
    
    // Target vector
    var targetPosition: Vector = Vector()
    
    // Just stores the heading to return to after dodging
    var returnHeading: Vector?
    
    // For pursuing
    var pursuedTarget: MovingObject? = nil
    
    // Constants used for wandering behavior
    var wanderCircle: Vector = Vector()
    let wanderJitter: CGFloat = 2.0
    let wanderRadius: CGFloat = 20.0
    let wanderDistance: CGFloat = 0.0
    
    // Initializer
    init(object: MovingObject) {
        self.movingObject = object
    }
    
    // Set the current behavior and target
    func setToGo(direction: Vector) {
        activeSteeringBehavior = .Go
        // Target is a direction way off in the distance
        targetPosition = direction.normalize() * (Config.FieldWidth * Config.FieldHeight)
    }
    func setToSeek(target: Vector) {
        activeSteeringBehavior = SteeringBehaviors.Seek
        targetPosition = target
    }
    func setToArrive(target: Vector) {
        activeSteeringBehavior = SteeringBehaviors.Arrive
        targetPosition = target
    }
    func setToFlee(target: Vector) {
        activeSteeringBehavior = SteeringBehaviors.Flee
        targetPosition = target
    }
    func setToWander() {
        activeSteeringBehavior = SteeringBehaviors.Wander
        wanderCircle = movingObject.heading * wanderRadius
        targetPosition = wanderCircle + movingObject.position
    }
    func setToPursue(target: MovingObject) {
        activeSteeringBehavior = SteeringBehaviors.Pursue
        pursuedTarget = target
    }
    func setToIdle() { activeSteeringBehavior = SteeringBehaviors.Idle }
    
    func getActiveBehavior() -> SteeringBehaviors {
        return activeSteeringBehavior
    }
    
    // Function for getting the steering force
    func calculateSteeringForce() -> Vector {        
        var desiredVelocity = Vector()
        
        // Get the desired velocity based on the active steering behavior
        switch activeSteeringBehavior {
        case .Go:
            desiredVelocity = seek()
            
        case .Seek:
            // Calculate the desired velocity
            desiredVelocity = seek()
            
        case .Arrive:
            desiredVelocity = arrive()
            
            // Return a 0 velocity if arrived
            if(desiredVelocity.length() == 0) {
                return desiredVelocity
            }
            
        case .Flee:
            break
            
        case .Wander:
            desiredVelocity = wander()
            
        case .Pursue:
            desiredVelocity = pursue()
            break
            
        case .Idle: // .Idle
            return desiredVelocity
        }
        
        // Need to adjust the steering force if the desired velocity is behind the object so it turns smoothly
        if(movingObject.velocity.dotDegrees(vector: desiredVelocity) > 90) {
            if(movingObject.heading.right().dotDegrees(vector: desiredVelocity) > 90)
            {
                // Turn straight left
                desiredVelocity = movingObject.heading.left() * desiredVelocity.length()
            }
            else {
                // Turn straight right
                desiredVelocity = movingObject.heading.right() * desiredVelocity.length()
            }
        }
        
        // Return the steering force vector
        return (desiredVelocity - movingObject.velocity).truncate(value: movingObject.maxForce)
    }

    private func seek(target: Vector? = nil) -> Vector {
        // Limit the desired velocity to 90 degrees right or left so we don't try to come to a stop
        let targetPos = target ?? targetPosition
        
        let desiredVelocity = targetPos - movingObject.position

        // Check if we are trying to turn around
        if desiredVelocity.dot(vector: movingObject.heading) > 1.5708 {
            // Desired velocity is behind, figure out if we need to be turning right or left and change desired to 90 degrees
            if movingObject.heading.right().dot(vector: desiredVelocity) < 1.5708 {
                // Turning around to the right
                return movingObject.heading.right() * movingObject.maxSpeed
            }
            else {
                // Turning around to the left
                return movingObject.heading.left() * movingObject.maxSpeed
            }
        }
        else {
            // Target is in front
            return (targetPos - movingObject.position).normalize() * movingObject.maxSpeed
        }
    }
    
    private func arrive() -> Vector {
        // Get the distance to the target
        let vectorToTarget = targetPosition - movingObject.position
        let distance = vectorToTarget.length()
        
        // Check if we aren't there yet
        if(distance > (movingObject.radius / 10)) {
            // Calculate speed given the desired deceleration rate
            var speed = distance / movingObject.deceleration
            
            // Make sure we aren't moving faster than the max speed
            speed = speed < movingObject.maxSpeed ? speed : movingObject.maxSpeed
            
            // Update the velocity
            return vectorToTarget * (speed / distance)
        }
        else {
            // Distance is close enough that we have arrived at the destination
            return Vector()
        }
    }
    
    private func wander() -> Vector {
        // Add some randomness to the target circle radius
        wanderCircle = (wanderCircle + Vector(x: CGFloat.random(in: -1..<1) * wanderJitter, y: CGFloat.random(in: -1..<1) * wanderJitter)).normalize() * wanderRadius
        
        // Project the wander circle in front of the moving object
        targetPosition = movingObject.position + ((movingObject.heading * wanderDistance) + wanderCircle)
        
        // Return a desired velocity where we seek the position on the wander circle
        return seek()
    }
    
    private func pursue() -> Vector {
        if let target = pursuedTarget {
            // Vector to the pursued object's current position
            let distanceToTarget = target.position - movingObject.position
            
            // Relative heading
            let relativeHeading = movingObject.heading.dot(vector: target.heading)
            
            if relativeHeading > 2.9 {
                return seek(target: target.position)
            }
            
            let lookAheadTime = (distanceToTarget).length() / Config.MissileMaxSpeed //((movingObject.maxSpeed + target.velocity.length()) * 1)
            
            return seek(target: target.position + (target.velocity * lookAheadTime))
        }
        
        return Vector()
    }
}