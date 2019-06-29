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
    case FollowPath
    case Idle
}

class SteeringBehavior {
    // The vehicle that is using this steering behavior
    var owner: MovingObject
    
    // The current active steering behavior
    private var activeSteeringBehavior: SteeringBehaviors = SteeringBehaviors.Idle
    
    // Target vector
    var targetPosition: Vector = Vector()
    
    // Just stores the heading to return to after dodging
    var returnHeading: Vector?
    
    // Constants used for wandering behavior
    private var wanderCircle: Vector = Vector()
    private let wanderJitter: CGFloat = 2.0
    private let wanderRadius: CGFloat = 20.0
    private let wanderDistance: CGFloat = 0.0
    
    // For pursuing
    var pursuedTarget: MovingObject? = nil
    
    // Path to follow, received from user input
    var followPath: [CGPoint] = [CGPoint]()
    var followAccuracy: CGFloat = 1.0
    
    // Initializer
    init(object: MovingObject) {
        self.owner = object
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
        wanderCircle = owner.heading * wanderRadius
        targetPosition = wanderCircle + owner.position
    }
    func setToPursue(target: MovingObject) {
        activeSteeringBehavior = SteeringBehaviors.Pursue
        pursuedTarget = target
    }
    func setToFollowPath(path: [CGPoint], accuracy: CGFloat = 1.0) {
        activeSteeringBehavior = SteeringBehaviors.FollowPath
        followPath = path
        followAccuracy = accuracy
    }
    func setToIdle() { activeSteeringBehavior = SteeringBehaviors.Idle }
    
    func getActiveBehavior() -> SteeringBehaviors {
        return activeSteeringBehavior
    }
    
    // Function for getting the steering force
    func calculateSteeringForce() -> Vector {
        // Get the avoidance velocity, if there is any
        var avoidanceVelocity = Vector()
        
        // Check if we need to be avoiding anything
        if !owner.objectsToAvoid.isEmpty {
            // Stores the closest enemy object to avoid
            var closestObjectToAvoid: MovingObject? = nil
            
            // Iterate through the objects that are close to us
            for (_, objectInRange) in owner.objectsToAvoid {
                if closestObjectToAvoid == nil {
                    closestObjectToAvoid = objectInRange
                }
                else if (objectInRange.position - owner.position).length() < (closestObjectToAvoid!.position - owner.position).length() {
                    closestObjectToAvoid = objectInRange
                }
            }
            
            // Unwrap
            if let avoidObject = closestObjectToAvoid {
                // Get the velocity that will point us to safety
                avoidanceVelocity = flee(target: avoidObject.position)
                
                // Reset the wandering circle if we are wandering since we wan't to come out of the avoidance going straight
                if activeSteeringBehavior == .Wander {
                    wanderCircle = owner.heading * wanderRadius
                    targetPosition = wanderCircle + owner.position
                }
                
                // Return the steering force vector
                return (avoidanceVelocity - owner.velocity).truncate(value: owner.maxForce)
            }
        }
        
        // Get the desired velocity from the active steering behavior
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
            
        case .FollowPath:
            desiredVelocity = follow()
            break
            
        case .Idle: // .Idle
            return desiredVelocity
        }
        
        // Return the steering force vector
        return (desiredVelocity - owner.velocity).truncate(value: owner.maxForce)
    }

    private func seek(target: Vector? = nil) -> Vector {
        // Limit the desired velocity to 90 degrees right or left so we don't try to come to a stop
        let targetPos = target ?? targetPosition
        
        let desiredVelocity = targetPos - owner.position

        // Check if we are trying to turn around
        if desiredVelocity.dot(vector: owner.heading) > 1.5708 {
            // Desired velocity is behind, figure out if we need to be turning right or left and change desired to 90 degrees
            if owner.heading.right().dot(vector: desiredVelocity) < 1.5708 {
                // Turning around to the right
                return owner.heading.right() * owner.maxSpeed
            }
            else {
                // Turning around to the left
                return owner.heading.left() * owner.maxSpeed
            }
        }
        else {
            // Target is in front
            return desiredVelocity.normalize() * owner.maxSpeed
        }
    }
    
    private func flee(target: Vector? = nil) -> Vector {
        // Limit the desired velocity to 90 degrees right or left so we don't try to come to a stop
        let targetPos = target ?? targetPosition
        
        let desiredVelocity = owner.position - targetPos
        
        // Check if we are trying to turn around
        if desiredVelocity.dot(vector: owner.heading) > 1.5708 {
            // Desired velocity is behind, figure out if we need to be turning right or left and change desired to 90 degrees
            if owner.heading.right().dot(vector: desiredVelocity) < 1.5708 {
                // Turning around to the right
                return owner.heading.right() * owner.maxSpeed
            }
            else {
                // Turning around to the left
                return owner.heading.left() * owner.maxSpeed
            }
        }
        else {
            // Target is in front
            return desiredVelocity.normalize() * owner.maxSpeed
        }
    }
    
    private func arrive() -> Vector {
        // Get the distance to the target
        let vectorToTarget = targetPosition - owner.position
        let distance = vectorToTarget.length()
        
        // Check if we aren't there yet
        if(distance > (owner.radius / 10)) {
            // Calculate speed given the desired deceleration rate
            var speed = distance / owner.deceleration
            
            // Make sure we aren't moving faster than the max speed
            speed = speed < owner.maxSpeed ? speed : owner.maxSpeed
            
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
        targetPosition = owner.position + ((owner.heading * wanderDistance) + wanderCircle)
        
        // Return a desired velocity where we seek the position on the wander circle
        return seek()
    }
    
    private func pursue() -> Vector {
        if let target = pursuedTarget {
            // Vector to the pursued object's current position
            let distanceToTarget = target.position - owner.position
            
            // Relative heading
            let relativeHeading = owner.heading.dot(vector: target.heading)
            
            if relativeHeading > 2.9 {
                return seek(target: target.position)
            }
            
            let lookAheadTime = (distanceToTarget).length() / Config.MissileMaxSpeed //((movingObject.maxSpeed + target.velocity.length()) * 1)
            
            return seek(target: target.position + (target.velocity * lookAheadTime))
        }
        
        return Vector()
    }
    
    private func follow() -> Vector {
        if !followPath.isEmpty {
            // Iterate through the path, reversed so we can get rid of some elements
            for (key, point) in followPath.enumerated().reversed() {
                // Seek toward the first point that isn't too close
                if owner.position.distanceBetween(vector: Vector(point)) > owner.radius * followAccuracy {
                    return seek(target: Vector(point))
                }
                else {
                    // Get rid of this point since it is too close
                    followPath.remove(at: key)
                }
            }
        }
        
        return Vector()
    }
}
