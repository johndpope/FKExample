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
import WarGUI

struct TestDefinition {
    
    var classObj : ()->AnyObject
    
    var settings : TestSettings
    
    init(settings: TestSettings, classObj:()->AnyObject) {
        self.classObj = classObj
        self.settings = settings
    }
    
}

let classMap : Dictionary<String, TestDefinition> = [
    "MovementTest" :  TestDefinition(settings:movementTestSetting, classObj: { return MovementTest() }),
    "ReformOnUnitDeathTest" :  TestDefinition(settings:movementTestSetting, classObj: { return ReformOnUnitDeathTest() }),
    "ReformTest" :  TestDefinition(settings:movementTestSetting, classObj: { return ReformTest() }),
    "AddHeroTest" :  TestDefinition(settings:movementTestSetting, classObj: { return AddHeroTest() }),
    "InvalidMovePositionTest" :  TestDefinition(settings:movementTestSetting, classObj: { return InvalidMovePositionTest() }),
    "CatchingUpTest" :  TestDefinition(settings:movementTestSetting, classObj: { return CatchingUpTest() }),
    "PerformanceTest" :  TestDefinition(settings:movementTestSetting, classObj: { return PerformanceTest() }),
    "SingleFightTest" :  TestDefinition(settings:combatTestSetting, classObj: { return SingleFightTest() }),
    "EngageMovingTargetTest" :  TestDefinition(settings:combatTestSetting, classObj: { return EngageMovingTargetTest() })
]

class GameScene : SBGameScene, SKPhysicsContactDelegate, FKPathfindingProtocol, FKHeraldryProtocol {
    
    var lastUpdateTimeInterval: NSTimeInterval = 0
    
    let maximumUpdateDeltaTime: NSTimeInterval = 2.0 / 60.0
    
    var navmesh : Navmesh?
    
    var squads = [FKSquadEntity]()
    
    var units = [FKUnitEntity]()
    
    var heros = [FKHeroEntity]()
    
    var currentTest : Testable!
    
    var currentInstructions : TestInstructions!
    
    var formationToTest = FKFormationComponent.Arrangement.Grid
    
    var actionBar : WGActionEntity?
    
    override func didMoveToView(view: SKView) {
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.size = CGSize(width: 2730, height: 1536)
        }
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        self.physicsWorld.speed = WorldPerformance.PHYSICS_SPEED
        self.buildWorldLayers()
        self.registerGestures()

        
        var instructions = TestInstructions(settings: combatTestSetting)
        instructions.name = "SingleFightTest"
        instructions.selectedFriendly = "Archer1"
        instructions.selectedEnemy = "BadMelee1"
        self.setupNextTest(instructions)
        self.setupGUI()
    }
    
    func setupNextTest(instructions : TestInstructions)  {
        self.camera?.childNodeWithName("SelectTests")?.removeFromParent()
        let test = classMap[instructions.name!]!.classObj()
        if test is Testable {
            
            if self.currentTest != nil {
                self.clearCurrentTest()
            }
            
            self.currentInstructions = instructions
            self.currentTest = test as! Testable
            self.currentTest.scene = self
            self.currentTest.setupTest(instructions)
            self.addDescriptionToScene()
        }
    }
    
    // MARK: WORLD LAYERS AND NODES
    
    /// Setup an array of child SKNodes to hold different visual elements
    override func buildWorldLayers() {
        
        self.cameraBounds = CameraBounds(lower: 100, left: 0, upper: 0, right: 0)
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.size = CGSize(width: 2048, height: 1536)
        }
        
        super.buildWorldLayers()
        
        // Set the camera as the scenes camera. Some scenes work without this lines, others don't.
        // For example, LevelScene worked without it, but Camp scene did not
        self.camera = self.childNodeWithName("Camera") as? SKCameraNode
        
        self.setCameraBounds(self.cameraBounds)
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
        self.enumerateChildNodesWithName("World/obstacles/*") { node, stop in
            node.removeFromParent()
        }
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
    
    func createSquadFromInstructions(instructions:TestInstructions, position:CGPoint = CGPoint(x:1100, y:768)) {
        var formation = FKFormationComponent.Arrangement.Grid
        if instructions.selectedFriendlyFormation == "Triangle" {
            formation = FKFormationComponent.Arrangement.Triangle
        }
        
        self.createSquadWithHero(
            instructions.selectedFriendly!,
            currentUnits:instructions.selectedFriendlySize,
            maxUnits:instructions.selectedFriendlySize + 1,
            formation: formation,
            hero: instructions.selectedFriendlyHero,
            position:position)
        

    }
    
    func createEnemySquadFromInstructions(instructions:TestInstructions, position:CGPoint) {
        var formation = FKFormationComponent.Arrangement.Grid
        if instructions.selectedEnemyFormation == "Triangle" {
            formation = FKFormationComponent.Arrangement.Triangle
        }
        
        self.createSquadWithHero(
            instructions.selectedEnemy!,
            currentUnits:instructions.selectedEnemySize,
            maxUnits:instructions.selectedEnemySize + 1,
            formation: formation,
            hero: instructions.selectedEnemyHero,
            controller: .EnemyNPC,
            position:position)
        
        
    }

    
    func createSquad(name:String = "Melee1", position:CGPoint = CGPoint(x:1100, y:768), heading:Float = -1, currentUnits : Int = 19, maxUnits : Int = 20, controller:FKSquadEntity.Controller = .Player, columns : Int = 5, spacing: Int = 64, formation: FKFormationComponent.Arrangement = .Grid) {
        /// Create a squad
        let squad = FKSquadFactory.sharedInstance.createSquad(
            FKSquadFactory.FKSquadConstruction(
                name:name,
                position: position,
                heading: heading,
                currentUnits: currentUnits,
                maxUnits: maxUnits,
                controller: controller,
                scene: self,
                layer: self.childNodeWithName("World")!,
                formation:formation,
                columns: columns,
                spacing: spacing,
                pathfinder : self,
                herladryDelegate:self))
        
        /// Store it so it doesn't disappear when this function finishes
        self.squads.append(squad)
    }
    
    func createSquadWithHero(name:String = "Melee1", position:CGPoint = CGPoint(x:1100, y:768), heading:Float = -1, currentUnits : Int = 19, maxUnits : Int = 20, controller:FKSquadEntity.Controller = .Player, columns : Int = 5, spacing: Int = 64, hero:String? = nil, formation: FKFormationComponent.Arrangement = .Grid) {
        /// Create a squad
        let squad = FKSquadFactory.sharedInstance.createSquad(
            FKSquadFactory.FKSquadConstruction(
                name:name,
                position: position,
                heading: heading,
                currentUnits: currentUnits,
                maxUnits: maxUnits,
                controller: controller,
                scene: self,
                layer: self.childNodeWithName("World")!,
                formation:formation,
                columns: columns,
                spacing: spacing,
                hero:hero,
                pathfinder : self,
                herladryDelegate:self))
        
        /// Store it so it doesn't disappear when this function finishes
        self.squads.append(squad)
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
            pathfinder : self,
            herladryDelegate:self)) {
                hero.renderComponent.node.position = CGPoint(x:200, y:200)
                FKUnitFactory.sharedInstance.addUnitToScene(hero)
                self.heros.append(hero)
                return hero
        }
        return nil
    }
    
    // MARK: Common Abilities
    
    func addMoveToSquad(squad:FKSquadEntity) {
        let ability = Ability.factoryInit("Move")
        let activeAbility = FKAbilitiesComponent.ActiveAbility(name:"Move", ability:ability, actionBarPosition:1, actionBarPriority:1)
        squad.abilitiesComponent.abilities.append(activeAbility)
    }
    
    func addMeleeToSquad(squad:FKSquadEntity) {
        let ability = Ability.factoryInit("Attack")
        let activeAbility = FKAbilitiesComponent.ActiveAbility(name:"Attack", ability:ability, actionBarPosition:1, actionBarPriority:1)
        squad.abilitiesComponent.abilities.append(activeAbility)
    }
    
    func addShootToSquad(squad:FKSquadEntity) {
        let ability = Ability.factoryInit("Shoot")
        let activeAbility = FKAbilitiesComponent.ActiveAbility(name:"Shoot", ability:ability, actionBarPosition:1, actionBarPriority:1)
        squad.abilitiesComponent.abilities.append(activeAbility)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if !self.refreshButtonTapped(location) && !self.debugButtonTapped(location) && !self.testButtonTapped(location) {
                let realLocation = self.childNodeWithName("World")!.convertPoint(location, fromNode: self)
                self.actionBar?.handleInput(realLocation)
            }
        }
    }
    
    // MARK: Test Specific
    
    func addDescriptionToScene() {
        if let testLabel = self.childNodeWithName("Camera/TestDescription") as? SKLabelNode {
            testLabel.text = self.currentTest.desc
        }
    }
    
    
    func refreshButtonTapped(location:CGPoint) -> Bool {
        let realLocation = self.camera!.convertPoint(location, fromNode: self)
        if let refresh = self.camera?.nodeAtPoint(realLocation) as? SKSpriteNode {
            if refresh.name == "refresh" {
                
                self.clearCurrentTest()
                self.currentTest.setupTest(self.currentInstructions)
                
                return true
            }
        }
        return false
    }
    
    func clearCurrentTest() {
        /// Kill squads
        for squad in self.squads {
            squad.componentForClass(FKCasualtyComponent)?.manuallyDestorySquad()
        }
        
        /// Clear local references
        self.squads.removeAll()
        self.units.removeAll()
        self.heros.removeAll()
        
        /// Remove previous nodes
        for node in self.childNodeWithName("World")!.children {
            print(node.name)
            if node.name != "obstacles" && node.name != "bg" {
                node.removeFromParent()
            }
        }
        
        /// rerun test
        self.currentTest.teardownTest()
    }
    
    func debugButtonTapped(location:CGPoint) -> Bool {
        let realLocation = self.camera!.convertPoint(location, fromNode: self)
        if let debug = self.camera?.nodeAtPoint(realLocation) as? SKSpriteNode {
            if debug.name == "debug" {
                
                if DebugFlags.sharedInstance.DEBUG_ENABLED == false {
                    self.currentTest.setDebugFlags()
                }
                else {
                    DebugFlags.sharedInstance.DEBUG_ENABLED = false
                    for squad in self.squads {
                        squad.componentForClass(FKSquadDebugComponent)?.clearDebugLayer()
                    }
                }
                
                return true
            }
        }
        return false
    }
    
    func testButtonTapped(location:CGPoint) -> Bool {
        let realLocation = self.camera!.convertPoint(location, fromNode: self)
        if let tests = self.camera?.nodeAtPoint(realLocation) as? SKSpriteNode {
            if tests.name == "tests" {
                
                let testNode = TestSelect()
                testNode.name = "SelectTests"
                testNode.callback = self.setupNextTest
                testNode.position = CGPoint(x:-1024, y:-768)
                testNode.zPosition = 6000
                self.camera?.addChild(testNode)
                
                return true
            }
        }
        return false
    }
    
    // MARK: GUI
    
    func setupGUI() {
        let bar = WGActionEntity(parentNode: self.camera!)
        self.actionBar = bar
    }
    
    func heraldryTapped(squad: FKSquadEntity) {
        if(squad.controller == .EnemyNPC) {
            self.actionBar?.handleEnemySquadTouched(squad)
        }
        else {
            self.actionBar?.selectSquad(squad)
        }
    }
   
    func heraldryDoubleTapped(squad: FKSquadEntity) {
        if let camera = self.camera {
            let pos = self.convertPoint(squad.agent.actualPosition, fromNode:squad.layer!)
            camera.panToPoint(pos)
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
        
        /// Update entites not part of the system
        self.actionBar?.updateWithDeltaTime(deltaTime)
        
    }
    
    // MARK: Pathfinding Protocol
    
    func getPathToPoint(start: CGPoint, end: CGPoint) -> (path: GKPath, nodes: [GKGraphNode2D])? {
        return self.navmesh?.findPathIngoringBuffer(start, end: end, radius: 50, scene: self)
    }
    
    func isPointValid(desired: float2) -> Bool {
        return self.navmesh!.pointIsValid(desired)
    }
    
    
}
