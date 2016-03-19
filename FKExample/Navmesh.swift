//
//  Navmesh.swift
//  With War & Woe
//
//  Created by Ryan Campbell on 7/30/15.
//  Copyright © 2015 Ryan Campbell. All rights reserved.
//

import SpriteKit
import GameplayKit
import SwitchBoard

enum MeshSize : Float {
    case
    Individual = 32,
    Small = 80,
    Medium = 130,
    Large = 180,
    XLarge = 230
    
    static func getAppropriateSize(radius:Float) -> MeshSize {
        if(radius >= MeshSize.Large.rawValue) {
            return MeshSize.XLarge
        }
        if(radius >= MeshSize.Medium.rawValue) {
            return MeshSize.Large
        }
        if(radius >= MeshSize.Small.rawValue) {
            return MeshSize.Medium
        }
        if(radius >= MeshSize.Individual.rawValue) {
            return MeshSize.Small
        }
        return MeshSize.Individual
    }
}

/**
Extension of [GKObstacleGraph](https://developer.apple.com/library/prerelease/ios/documentation/GameplayKit/Reference/GKObstacleGraph_Class/) 
that has built in utility methods for pathfinding. For example, if the desired point is inside of an obstacle, you can optionally find the 
closest point on the graph.
*/
class Navmesh : GKObstacleGraph {
    
    var meshObstacles = [MeshObstacle]()
    
    var meshes = Dictionary<MeshSize, GKObstacleGraph>()
    
    // MARK: Initializing a Navmesh
    
    /// Reads a PList file with details on the obstacles. Creates a sprite for each obstacle, with a CGPath representing the data.
    /// Path is converted to a physics body, which is used for the obstacle in the GKGraph.
    init(file:String, scene:GameScene, bufferRadius:Float) {
        let meshes = Navmesh.buildObstacles(Navmesh.loadPListData(file), scene:scene, bufferRadius: CGFloat(bufferRadius))
        var obstacles = [GKPolygonObstacle]()
        for mesh in meshes {
            self.meshObstacles.append(mesh)
            obstacles.append(mesh.obstacle)
        }
        
        /*var bodies = [SKPhysicsBody]()
        for mesh in meshes {
            bodies.append(mesh.sprite.physicsBody!)
        }*/
        //let obstacleSpriteNodes: [SKSpriteNode] = scene["World/obstacles/*"] as! [SKSpriteNode]
        //obstacles = SKNode.obstaclesFromNodePhysicsBodies(obstacleSpriteNodes)
        super.init(obstacles: obstacles, bufferRadius: bufferRadius)
        self.removeNodesOutsideOfSceneBounds(scene)
        
        self.removeNodesThatArentConnected()
        
        /*self.meshes[MeshSize.Individual] = GKObstacleGraph(obstacles: obstacles, bufferRadius: MeshSize.Individual.rawValue)
        self.meshes[MeshSize.Small] = GKObstacleGraph(obstacles: obstacles, bufferRadius: MeshSize.Small.rawValue)
        self.meshes[MeshSize.Medium] = GKObstacleGraph(obstacles: obstacles, bufferRadius: MeshSize.Medium.rawValue)
        self.meshes[MeshSize.Large] = GKObstacleGraph(obstacles: obstacles, bufferRadius: MeshSize.Large.rawValue)
        self.meshes[MeshSize.XLarge] = GKObstacleGraph(obstacles: obstacles, bufferRadius: MeshSize.XLarge.rawValue)*/

    }
    
    /// For each level, multiple navmeshes will be made. The different buffer radius will help units of different sizing navigate.
    /// Call this function when the obstacle have already been loaded
    override init(obstacles:[GKPolygonObstacle], bufferRadius:Float) {
        super.init(obstacles: obstacles, bufferRadius: bufferRadius)
    }
    
    /// Standard helper to load a plist file
    class func loadPListData(file:String) -> NSDictionary {
        let lookup = "\(file)_obstacles"
        let path = NSBundle.mainBundle().pathForResource(lookup, ofType: "plist")
        let pListData = NSDictionary(contentsOfFile:path!)
        return pListData!
    }
    
    /// Loops through each item in the plist file and creates a sprite with the appropriate physcis shape based off of the data.
    class func buildObstacles(data:NSDictionary, scene:GameScene, bufferRadius:CGFloat) -> [MeshObstacle] {
        
        /// Drill down to the fixtures object
        let bodies = data["bodies"] as! NSDictionary
        let level = bodies["bg"] as! NSDictionary
        let fixtures = level["fixtures"] as! Array<NSDictionary>
        var ret = [MeshObstacle]()
        
        /// Each fixture contains multiple polygons. A fixture would be two unconnected obstacles. A polygon would be all convex shapes that make one obstacle.
        for (_, fixture) in fixtures.enumerate() {
            let polygons = fixture["polygons"] as! Array<Array<String>>
            if polygons.count > 1 {
                print("PhysicsEditor split the polyogn into multiple triangles")
            }
            for (_, polygon) in polygons.enumerate() {
                
                let mesh = MeshObstacle(polygon: polygon, scene:scene, buffer:bufferRadius)
                ret.append(mesh)

            }
            
        }
        
        return ret

    }
    
    /// When the graph is intiialized, we'll remove all nodes outside of the scene to prevent units from walking off of the scene.
    func removeNodesOutsideOfSceneBounds(scene:GameScene) {
        if let bg = scene.childNodeWithName("World/bg") {
            var nodesOffScene = [GKGraphNode2D]()
            for node in self.nodes as! [GKGraphNode2D] {
                let worldPosition = bg.convertPoint(CGPoint(node.position), fromNode: scene)
                if(!bg.containsPoint(worldPosition)) {
                    nodesOffScene.append(node)
                }
            }
            self.removeNodes(nodesOffScene)
        }
    }
    
    // MARK: Pathfinding
    
    /// Attempts to find a path through the graph while ignoring any obstacles you wish. Obstacles apply to the placement of the start
    /// and end node (i.e.: a unit lies inside of an obstacle and needs to get out).
    func findPath(start:CGPoint, end:CGPoint, ignoringObstacles:[GKPolygonObstacle] = [], radius:Float, scene:GameScene, size:Float = 32) -> GKPath? {
        let startNode = GKGraphNode2D(point:float2(start))
        let endNode = GKGraphNode2D(point:float2(end))
        //let targetMesh = self.meshes[MeshSize.getAppropriateSize(size)]!
        
        self.connectNodeUsingObstacles(startNode, ignoringObstacles: ignoringObstacles)
        self.connectNodeUsingObstacles(endNode, ignoringObstacles: ignoringObstacles)
        
        if(!startNode.connectedNodes.isEmpty && !endNode.connectedNodes.isEmpty) {
            let pathNodes = self.findPathFromNode(startNode, toNode: endNode) as! [GKGraphNode2D]
            let path = GKPath(graphNodes: pathNodes, radius: radius)
            self.removeNodes([startNode, endNode])
            return path
        }
        
        self.removeNodes([startNode, endNode])

        return nil
    }
    
    /// Attempts to find a path even if the start and end point lie within a buffer region.
    func findPathIngoringBuffer(start:CGPoint, end:CGPoint, radius:Float, scene:GameScene, size:Float = 32) -> (path:GKPath, nodes:[GKGraphNode2D])? {
        let startNode = GKGraphNode2D(point:float2(start))
        let endNode = GKGraphNode2D(point:float2(end))
        //let targetMesh = self.meshes[MeshSize.getAppropriateSize(size)]!

        /// First try to connect using ignore buffer
        self.connectNodeUsingObstacles(startNode, ignoringBufferRadiusOfObstacles: self.getBuffersContainingPoint(float2(start)))
        self.connectNodeUsingObstacles(endNode, ignoringBufferRadiusOfObstacles: self.getBuffersContainingPoint(float2(end)))

        /// If weve reached this point, buffer connection didnt work, so try to force connection to lowest cost node
        if startNode.connectedNodes.isEmpty {
            self.removeNodes([startNode])
            self.connectNodeToLowestCostNode(startNode, bidirectional: true)
        }
    
        if endNode.connectedNodes.isEmpty {
            self.removeNodes([endNode])
            self.connectNodeToLowestCostNode(endNode, bidirectional: true)
        }
        
        /// Should have connections by now, so find a path
        if let pathNodes = self.findPathFromNode(startNode, toNode: endNode) as? [GKGraphNode2D] {
            if(pathNodes.count > 1) {
                self.removeNodes([startNode, endNode])
                let path = GKPath(graphNodes: pathNodes, radius: radius)
                return (path, pathNodes)
            }
        }
        
        /// Debugging information if we get here which means everything failed
        if(startNode.connectedNodes.isEmpty) {
            print("start empty")
        }
        else {
            print("end empty")
        }
        
        self.removeNodes([startNode, endNode])
        
        return nil
    }
    
    // MARK: Utility
    
    /// Determines if a point lies on an obstacle. If this doesn't perform well, we can loop through the MeshObstacles and call
    /// containsPoint() on each one. Expects world point
    func pointIsValid(point:float2) -> Bool {
        for mesh in self.meshObstacles {
            if mesh.containsPoint(CGPoint(point)) {
                return false
            }
        }
        return true
    }
    
    /// Builds a list of all buffer regions of obstacles containing a point. Used for ignoreBufferRadius when adding a GKGraphNode to the mesh.
    func getBuffersContainingPoint(point:float2) -> [GKPolygonObstacle] {
        var ret = [GKPolygonObstacle]()
        for mesh in self.meshObstacles {
            if mesh.containsPointInBuffer(CGPoint(point)) {
                ret.append(mesh.obstacle)
            }
        }
        return ret
    }
    
    func removeNodesThatArentConnected() {
        for node in self.nodes as! [GKGraphNode2D] {
            if node.connectedNodes.isEmpty {
                self.removeNodes([node])
            }
        }
    }
}
