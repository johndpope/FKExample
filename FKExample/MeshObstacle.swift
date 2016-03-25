//
//  MeshObstacle.swift
//  With War & Woe
//
//  Created by Ryan Campbell on 8/13/15.
//  Copyright © 2015 Ryan Campbell. All rights reserved.
//

import SpriteKit
import GameplayKit
import SwitchBoard
import FormationKit

/**
Because GKPolygonObstacle and SKSpriteNode.physcisBody do not have read access to the CGPath, we can't do easy hit detection.
This MeshObstacle will store a reference to the sprite, physics body, path and obstacle which will make it easy to get at the data
for Navmesh decisions.
*/
class MeshObstacle {
    
    /// Added to obstacles layer, which has an anchor point at center of scene
    let sprite : SKSpriteNode
    
    /// Supplied from the center of the scene
    let path: CGPath
    
    /// Path with buffer applied
    let bufferedPath: CGPath
    
    /// Use navmesh coordinates which are same as scene cooridnates
    let obstacle : GKPolygonObstacle
    
    // MARK: Initializing a MeshObstacle
    
    /**
        Takes a polygon which consists of an array of strings in the format { 100, 200 } where the first value is the x coord
        and the second is the y. This format is the export format of PhyscisEditor / Box2D. Obstacles are built there, exported, and then
        read from a plist file and finally initalized here.
    
        **Note** On init, the sprite will be added to the scene.
    */
    init(polygon:Array<String>, scene:GameScene, var buffer:CGFloat) {
        
        /// Fudge the buffer a bit to make sure all potential obstacles are included in searches for buffer radius
        buffer += 25
        
        let sprite = SKSpriteNode()
        let path = CGPathCreateMutable()
        let obstacleLayer = scene.childNodeWithName("World/obstacles")
        
        /// Build each sprite and physics body based off of polygon shape
        for i in 0 ..< polygon.count {
            let points = polygon[i].componentsSeparatedByString(",")
            let x = points[0].stringByReplacingOccurrencesOfString("{ ", withString: "")
            let y = points[1].stringByReplacingOccurrencesOfString(" }", withString: "")
            if(i == 0) {
                CGPathMoveToPoint(path, nil, CGFloat((x as NSString).floatValue), CGFloat((y as NSString).floatValue))
            }
            else {
                CGPathAddLineToPoint(path, nil, CGFloat((x as NSString).floatValue), CGFloat((y as NSString).floatValue))
            }
        }
        CGPathCloseSubpath(path)
        sprite.physicsBody = SKPhysicsBody(polygonFromPath: path)
        sprite.physicsBody?.dynamic = false
        sprite.physicsBody?.categoryBitMask = FKPhysicsService.ColliderType.Environment.rawValue
    
        self.sprite = sprite
        self.path = path
        obstacleLayer?.addChild(self.sprite)
        self.obstacle = SKNode.obstaclesFromNodePhysicsBodies([self.sprite]).first!
        
        self.bufferedPath = CGPathCreateCopyByStrokingPath(path, nil, buffer * 2, CGLineCap.Butt, CGLineJoin.Miter, buffer)!

        
    }
    
    // MARK: Hit Testing
    
    /// Used to check if the current unit / hit check is already within the polygon. Coordinates are based on World layer
    func containsPoint(point:CGPoint) -> Bool {
        return CGPathContainsPoint(self.path, nil, point, false)
    }
    
    /// Used to check if the current unit / hit check is already within the buffered polygon. Coordinates are based on World layer
    func containsPointInBuffer(point:CGPoint) -> Bool {
        if let scene = self.sprite.scene as? GameScene {
            let localPoint = scene.childNodeWithName("World")!.convertPoint(point, fromNode: scene)
            return CGPathContainsPoint(self.bufferedPath, nil, localPoint, false)
        }
        return false
    }
    
    /// Loops over each side of the polygon, and checks which side a point **within** the polygon lies closest to.
    func closestSideToPoint(point:float2) -> (start:float2, end:float2) {
        var sorted = [float2]()
        for i in 0 ..< self.obstacle.vertexCount {
            sorted.append(self.obstacle.vertexAtIndex(i))
        }
        sorted.sortInPlace({ distance($0, point) < distance($1, point) })
        return (start:sorted[0], end:sorted[1])
    }
    
    /// Find the point where a perpendicular line connecting to a point inside of the polygon would intersect the edge of the polygon
    func closestPointOutsideHitPoint(hitPoint:float2) -> float2 {
        let closestEdgeToPoint = self.closestSideToPoint(hitPoint)
        let start = closestEdgeToPoint.start
        let end = closestEdgeToPoint.end
        
        // http://stackoverflow.com/questions/1811549/perpendicular-on-a-line-from-a-given-point
        let k = ((end.y - start.y) * (hitPoint.x - start.x) - (end.x - start.x) * (hitPoint.y - start.y)) / ((end.y - start.y) * (end.y - start.y) + (end.x - start.x) * (end.x - start.x))
        let x4 = hitPoint.x - k * (end.y - start.y)
        let y4 = hitPoint.y + k * (end.x - start.x)
        let ret = float2(x: x4, y: y4)
        

        
        return ret
    }
    
    
}
