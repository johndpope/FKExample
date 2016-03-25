//
//  GameScene.swift
//  FKExample
//
//  Created by Ryan Campbell on 2/19/16.
//  Copyright (c) 2016 Phalanx Studios. All rights reserved.
//

import SpriteKit
import GameplayKit
import FormationKit
import SwitchBoard
import Particleboard

class GameScene: SBGameScene, SKPhysicsContactDelegate, FKPathfindingProtocol {
    
    var lastUpdateTimeInterval: NSTimeInterval = 0
    
    let maximumUpdateDeltaTime: NSTimeInterval = 2.0 / 60.0
    
    var navmesh : Navmesh?
    
    var squads = [FKSquadEntity]()
    
    var units = [FKUnitEntity]()
    
    var heros = [FKHeroEntity]()
    
    var currentTest : Testable!
    
    var formationToTest = FKFormationComponent.Arrangement.Grid
    
    var touchCallback : ((location:CGPoint)->())? = nil
    
    override func didMoveToView(view: SKView) {
        
        self.camera = self.childNodeWithName("camera") as! SKCameraNode
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        self.physicsWorld.speed = WorldPerformance.PHYSICS_SPEED
        
        /// Notify squad 1 that 2 exists
        //squad.navigationComponent.agentsToAvoid.append(squad2.agent)
        
        //self.currentTest = MovementTest(scene:self)
        //self.currentTest = ReformOnUnitDeathTest(scene: self)
        //self.currentTest = ReformTest(scene: self)
        self.currentTest = AddHeroTest(scene: self)
        //self.currentTest = TriangleFormationTest(scene: self)

        self.currentTest.setupTest()
    }
    
    // MARK: SKPhysicsContactDelegate
    
    func didBeginContact(contact: SKPhysicsContact) {
        FKPhysicsService.sharedInstance.didBeginContact(contact)
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        FKPhysicsService.sharedInstance.didEndContact(contact)
    }
    
    // MARK: Navmesh
    
    func configureNavmesh() {
        self.navmesh = Navmesh(file: "TestLevel", scene: self, bufferRadius: 140)
    }
    
    func configureNavmeshWithObstacles(names:[String]) {
        var obstacleSpriteNodes = [SKSpriteNode]()
        self.enumerateChildNodesWithName("World/obstacles/*") { node, stop in
            let realNode = node as! SKSpriteNode
            if names.contains(realNode.name!) {
                obstacleSpriteNodes.append(realNode)
            }
            else {
                node.removeFromParent()
            }
        }
        
        let polygonObstacles: [GKPolygonObstacle] = SKNode.obstaclesFromNodePhysicsBodies(obstacleSpriteNodes)
        
        self.navmesh = Navmesh(obstacles: polygonObstacles, bufferRadius: 140)
    }
    
    // MARK: Utility
    
    func createSquad() {
        let squad = FKSquadFactory.sharedInstance.createSquad(
            FKSquadFactory.FKSquadConstruction(
                name:"Melee1",
                position: CGPoint(x:1100, y:768),
                heading: -1,
                currentUnits: 40,
                maxUnits: 40,
                controller: .Player,
                scene: self,
                layer: self.childNodeWithName("World")!,
                formation:formationToTest,
                columns: 6,
                spacing: 64,
                pathfinder : self))
        
        /// Store it so it doesn't disappear when this function finishes
        self.squads.append(squad)

    }
    
    func createSquadWithHero() {
        /// Create a squad
        let squad = FKSquadFactory.sharedInstance.createSquad(
            FKSquadFactory.FKSquadConstruction(
                name:"Melee1",
                position: CGPoint(x:1100, y:768),
                heading: -1,
                currentUnits: 19,
                maxUnits: 20,
                controller: .Player,
                scene: self,
                layer: self.childNodeWithName("World")!,
                formation:formationToTest,
                columns: 5,
                spacing: 64,
                hero:"Bomur",
                pathfinder : self))
        
        /// Store it so it doesn't disappear when this function finishes
        self.squads.append(squad)
    }
    
    func createNextSquad() {
        /// Create a squad
        let squad2 = FKSquadFactory.sharedInstance.createSquad(
            FKSquadFactory.FKSquadConstruction(
                name:"Melee1",
                position: CGPoint(x:1024, y:768),
                heading: 3.14,
                currentUnits: 15,
                maxUnits: 15,
                controller: .Player,
                scene: self,
                layer: self.childNodeWithName("World")!,
                formation:formationToTest,
                columns: 5,
                spacing: 64,
                pathfinder : self))
        
        self.squads.append(squad2)

    }
    
    func createHero() -> FKHeroEntity? {
        if let hero = FKUnitFactory.sharedInstance.createHero(FKSquadFactory.FKSquadConstruction(
            name:"Bomur",
            position: CGPoint(x:200, y:200),
            heading: 3.14,
            currentUnits: 1,
            maxUnits: 1,
            controller: .Player,
            scene: self,
            layer: self.childNodeWithName("World")!,
            formation:FKFormationComponent.Arrangement.Grid,
            columns: 1,
            spacing: 64,
            hero:"Bomur",
            pathfinder : self)) {
                hero.renderComponent.node.position = CGPoint(x:200, y:200)
                FKUnitFactory.sharedInstance.addUnitToScene(hero)
                self.heros.append(hero)
                return hero
        }
        return nil
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let realLocation = self.childNodeWithName("World")!.convertPoint(location, fromNode: self)
            self.currentTest.tapped(realLocation)
        }
    }
   
    // MARK: UPDATE
    
    override func update(currentTime: CFTimeInterval) {
        
        /* Called before each frame is rendered */
        // Calculate the amount of time since `update` was last called.
        var deltaTime = currentTime - lastUpdateTimeInterval
        
        // If more than `maximumUpdateDeltaTime` has passed, clamp to the maximum; otherwise use `deltaTime`.
        deltaTime = deltaTime > maximumUpdateDeltaTime ? maximumUpdateDeltaTime : deltaTime
        
        // The current time will be used as the last update time in the next execution of the method.
        lastUpdateTimeInterval = currentTime
            
        /// Update the squad component system
        for componentSystem in FKSquadFactory.sharedInstance.componentSystems {
            componentSystem.updateWithDeltaTime(deltaTime)
        }
        
        /// Update the unit component system
        for componentSystem in FKUnitFactory.sharedInstance.componentSystems {
            componentSystem.updateWithDeltaTime(deltaTime)
        }
        
    }
    
    // MARK: Pathfinding Protocol
    
    func getPathToPoint(start: CGPoint, end: CGPoint) -> (path: GKPath, nodes: [GKGraphNode2D])? {
        return self.navmesh?.findPathIngoringBuffer(start, end: end, radius: 50, scene: self)
    }
    
    
}
