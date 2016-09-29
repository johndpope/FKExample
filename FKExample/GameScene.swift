//
//  GameScene.swift
//  FKExample
//
//  Created by Ryan Campbell on 2/19/16.
//  Copyright (c) 2016 Phalanx Studios. All rights reserved.
//

import SpriteKit
import GameplayKit

#if os(iOS)
    import FormationKit
    import SwitchBoard
    import Particleboard
    import WarGUI
    import StrongRoom
    import BarricAssets
    import PathKit
#elseif os(OSX)
    import FormationKitOS
    import SwitchBoardOS
    import ParticleboardOS
    import WarGUIOS
    import StrongRoomOS
    import BarricAssetsOS
    import PathKitOS
#endif

struct TestDefinition {
    
    var classObj : ()->AnyObject
    
    var settings : TestSettings
    
    init(settings: TestSettings, classObj: @escaping()->AnyObject) {
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
    
    var lastUpdateTimeInterval: TimeInterval = 0
    
    let maximumUpdateDeltaTime: TimeInterval = 2.0 / 60.0
    
    var navmesh : PKNavmesh?
    
    ///var navmesh : Navmesh?

    
    var squads = [FKSquadEntity]()
    
    var units = [FKUnitEntity]()
    
    var heros = [FKHeroEntity]()
    
    var currentTest : Testable!
    
    var currentInstructions : TestInstructions!
    
    var formationToTest = FKFormationComponent.Arrangement.grid
    
    var actionBar : WGActionEntity?
    
    var ui : WGContainerNode?
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        self.physicsWorld.speed = WorldPerformance.PHYSICS_SPEED
        self.buildWorldLayers()
        self.registerGestures()
        self.configureNavmesh()

        
        var instructions = TestInstructions(settings: combatTestSetting)
        instructions.name = "MovementTest"
        instructions.selectedFriendly = "Melee1"
        ///instructions.selectedEnemy = "BadMelee1"
        instructions.selectedFriendlySize = 12
        instructions.selectedFriendlyHero = nil
        ///instructions.selectedEnemySize = 20
        self.setupNextTest(instructions)
        let leader = self.createArmyLeader()
        //self.addAbilitiesToSquad(leader, filter:["Haste"])
        self.setupGUI(leader)
        self.currentTest.setDebugFlags()
    }
    
    func setupNextTest(_ instructions : TestInstructions)  {
        self.camera?.childNode(withName: "SelectTests")?.removeFromParent()
        let test = classMap[instructions.name!]!.classObj()
        if test is Testable {
            
            if self.currentTest != nil {
                self.clearCurrentTest()
            }
            
            self.currentInstructions = instructions
            self.currentTest = test as! Testable
            self.currentTest.scene = self
            self.currentTest.setupTest(instructions)
        }
    }
    
    // MARK: WORLD LAYERS AND NODES
    
    /// Setup an array of child SKNodes to hold different visual elements
    override func buildWorldLayers() {
        
        self.cameraBounds = CameraBounds(lower: 100, left: 0, upper: 0, right: 0)
        self.size = CGSize(width: 2730, height: 1536)
        
        #if os(OSX)
            ///self.size = CGSize(width: 1920, height: 1080)
        #endif
        
        #if os(iOS)
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.size = CGSize(width: 2048, height: 1536)
            }
        #endif
        
        super.buildWorldLayers()
        
        /// Set the camera as the scenes camera. Some scenes work without this lines, others don't.
        /// For example, LevelScene worked without it, but Camp scene did not
        self.camera = self.childNode(withName: "Camera") as? SKCameraNode
        
        self.setCameraBounds(offsetBounds: self.cameraBounds)
        
        /// manually create other SKNode layers
        let ui = WGContainerNode()
        ui.name = "UI"
        self.camera!.addChild(ui)
        ui.initWithDefaults(self)
        self.ui = ui
        
    }
    
    // MARK: SKPhysicsContactDelegate
    
    func didBegin(_ contact: SKPhysicsContact) {
        FKPhysicsService.sharedInstance.didBeginContact(contact)
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        FKPhysicsService.sharedInstance.didEndContact(contact)
    }
    
    // MARK: Navmesh
    
    func configureNavmesh() {
        self.enumerateChildNodes(withName: "World/obstacles/*") { node, stop in
            node.removeFromParent()
        }
        self.navmesh = PKNavmesh(file:"TestLevel",scene:self, bgLayer:self.childNode(withName: "World")!, obstacleLayer:self.childNode(withName: "World/obstacles")!, bufferRadius:150, collider:FKPhysicsService.ColliderType.environment.rawValue)
        ///self.navmesh = Navmesh(file:"TestLevel",scene:self, bufferRadius:50)
    }

    
    // MARK: Utility
    
    func createSquadFromInstructions(_ instructions:TestInstructions, position:CGPoint = CGPoint(x:0, y:900), heading:Float = -1) {
        
        var formation = FKFormationComponent.Arrangement.grid
        if instructions.selectedFriendlyFormation == "Triangle" {
            formation = FKFormationComponent.Arrangement.triangle
        }
        var size = instructions.selectedFriendlySize
        if instructions.selectedFriendlyHero != nil {
            size = size + 1
        }
        
        self.createSquadWithHero(
            instructions.selectedFriendly!,
            position:position,
            heading:heading,
            currentUnits:instructions.selectedFriendlySize,
            maxUnits:size,
            hero: instructions.selectedFriendlyHero,
            formation: formation)
        

    }
    
    func createEnemySquadFromInstructions(_ instructions:TestInstructions, position:CGPoint, heading:Float = -1) {
        var formation = FKFormationComponent.Arrangement.grid
        if instructions.selectedEnemyFormation == "Triangle" {
            formation = FKFormationComponent.Arrangement.triangle
        }
        
        var size = instructions.selectedEnemySize
        if instructions.selectedEnemyHero != nil {
            size = size + 1
        }
        
        self.createSquadWithHero(
            instructions.selectedEnemy!,
            position:position,
            heading:heading,
            currentUnits:instructions.selectedEnemySize,
            maxUnits:size,
            controller: .enemyNPC,
            hero: instructions.selectedEnemyHero,
            formation: formation)
        
        
    }

    
    func createArmyLeader() -> FKSquadEntity {
        /// Create a squad
        let squad = FKSquadFactory.sharedInstance.createSquad(
            FKSquadFactory.FKSquadConstruction(
                name: "Leader",
                position: CGPoint(x:0, y:0),
                heading: Float(0),
                currentUnits: 0,
                maxUnits: 0,
                controller: .friendlyNPC,
                formation: .grid,
                columns: 1,
                spacing: 0,
                pathfinder: self,
                herladryDelegate: self,
                abilities:self.getAbilitiesForSquad("Leader"))
            )
        
        /// Store it so it doesn't disappear when this function finishes
        self.squads.append(squad)
        return squad

    }
    
    func createSquad(_ name:String = "Melee1", position:CGPoint = CGPoint(x:1100, y:768), heading:Float = -1, currentUnits : Int = 19, maxUnits : Int = 20, controller:FKSquadEntity.Controller = .player, columns : Int = 5, spacing: Int = 64, formation: FKFormationComponent.Arrangement = .grid) -> FKSquadEntity {
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
                layer: self.childNode(withName: "World")!,
                formation:formation,
                columns: columns,
                spacing: spacing,
                pathfinder : self,
                herladryDelegate:self))
        
        /// Store it so it doesn't disappear when this function finishes
        self.squads.append(squad)
        return squad
    }
    
    func createSquadWithHero(_ name:String = "Melee1", position:CGPoint = CGPoint(x:1100, y:768), heading:Float = -1, currentUnits : Int = 19, maxUnits : Int = 20, controller:FKSquadEntity.Controller = .player, columns : Int = 5, spacing: Int = 64, hero:String? = nil, formation: FKFormationComponent.Arrangement = .grid) {
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
                layer: self.childNode(withName: "World")!,
                uiLayer: self.ui!,
                formation:formation,
                columns: columns,
                spacing: spacing,
                hero:hero,
                pathfinder : self,
                herladryDelegate:self,
                abilities:self.getAbilitiesForSquad(name),
                heroAbilities:self.getAbilitiesForSquad(hero)))
        
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
            controller: .player,
            scene: self,
            layer: self.childNode(withName: "World")!,
            formation:FKFormationComponent.Arrangement.grid,
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
    
    func addAbilitiesToSquad(_ squad:FKSquadEntity, filter:[String]? = nil) {
        
        if let data = FKUnitFactory.sharedInstance.loadPListData(squad.unitName) {
            let allAbilities = SRUnlockFactory.sharedInstance.getAllAbilitiesForSquad(data: data)
            for abilityData in allAbilities {
                
                if filter == nil || (filter?.contains(abilityData.abilityName))! {
                    let ability = Ability.factoryInit(abilityData.abilityName)
                    let activeAbility = FKAbilitiesComponent.ActiveAbility(
                        name:abilityData.abilityName,
                        ability:ability,
                        actionBarPosition:abilityData.actionBarPosition,
                        actionBarPriority:abilityData.actionBarPriority)
                    squad.abilitiesComponent.abilities.append(activeAbility)
                }
            }
        }

    }
    
    func getAbilitiesForSquad(_ unitName:String?) -> [FKAbilitiesComponent.ActiveAbility] {
        var ret = Array<FKAbilitiesComponent.ActiveAbility>()
        
        guard unitName != nil else {
            return ret
        }
        
        if let data = FKUnitFactory.sharedInstance.loadPListData(unitName!) {
            let allAbilities = SRUnlockFactory.sharedInstance.getAllAbilitiesForSquad(data: data)
            for abilityData in allAbilities {
                
                let ability = Ability.factoryInit(abilityData.abilityName)
                let activeAbility = FKAbilitiesComponent.ActiveAbility(
                        name:abilityData.abilityName,
                        ability:ability,
                        actionBarPosition:abilityData.actionBarPosition,
                        actionBarPriority:abilityData.actionBarPriority)
                ret.append(activeAbility)
            }
        }
        return ret
    }
    
    func addMoveToSquad(_ squad:FKSquadEntity) {
        let ability = Ability.factoryInit("Move")
        let activeAbility = FKAbilitiesComponent.ActiveAbility(name:"Move", ability:ability, actionBarPosition:1, actionBarPriority:1)
        squad.abilitiesComponent.abilities.append(activeAbility)
    }
    
    func addMeleeToSquad(_ squad:FKSquadEntity) {
        let ability = Ability.factoryInit("Attack")
        let activeAbility = FKAbilitiesComponent.ActiveAbility(name:"Attack", ability:ability, actionBarPosition:1, actionBarPriority:1)
        squad.abilitiesComponent.abilities.append(activeAbility)
    }
    
    func addShootToSquad(_ squad:FKSquadEntity) {
        let ability = Ability.factoryInit("Shoot")
        let activeAbility = FKAbilitiesComponent.ActiveAbility(name:"Shoot", ability:ability, actionBarPosition:1, actionBarPriority:1)
        squad.abilitiesComponent.abilities.append(activeAbility)
    }
    
    func clickUp(location:CGPoint) {
        if !self.refreshButtonTapped(location) && !self.debugButtonTapped(location) && !self.testButtonTapped(location) {
            let realLocation = self.childNode(withName: "World")!.convert(location, from: self)
            self.actionBar?.handleInput(realLocation)
            self.currentTest?.tapped(location)
        }
    }
    
    func clickDown(location:CGPoint) {
        
    }
    
    // MARK: iOS Input
    
    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            self.clickDown(location: location)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            self.clickUp(location: location)
        }
    }
    #endif
    
    // MARK: macOS Input
    
    #if os(OSX)
    
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        self.clickDown(location: location)
    }
    
    override func mouseUp(with event: NSEvent) {
        let location = event.location(in: self)
        self.clickUp(location: location)
    }
    
    #endif
    
    // MARK: Test Specific
    
    
    func refreshButtonTapped(_ location:CGPoint) -> Bool {
        let realLocation = self.camera!.convert(location, from: self)
        if let refresh = self.camera?.atPoint(realLocation) as? SKSpriteNode {
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
            squad.component(ofType: FKCasualtyComponent.self)?.manuallyDestorySquad()
        }
        
        /// Clear local references
        self.squads.removeAll()
        self.units.removeAll()
        self.heros.removeAll()
        
        /// Remove previous nodes
        for node in self.childNode(withName: "World")!.children {
            if node.name != "obstacles" && node.name != "bg" && node.name != "flee" {
                node.removeFromParent()
            }
        }
        
        /// rerun test
        self.currentTest.teardownTest()
    }
    
    func debugButtonTapped(_ location:CGPoint) -> Bool {
        let realLocation = self.camera!.convert(location, from: self)
        if let debug = self.camera?.atPoint(realLocation) as? SKSpriteNode {
            if debug.name == "debug" {
                
                if DebugFlags.sharedInstance.DEBUG_ENABLED == false {
                    self.currentTest.setDebugFlags()
                }
                else {
                    DebugFlags.sharedInstance.DEBUG_ENABLED = false
                    for squad in self.squads {
                        squad.component(ofType: FKSquadDebugComponent.self)?.clearDebugLayer()
                    }
                }
                
                return true
            }
        }
        return false
    }
    
    func testButtonTapped(_ location:CGPoint) -> Bool {
        let realLocation = self.camera!.convert(location, from: self)
        if let tests = self.camera?.atPoint(realLocation) as? SKSpriteNode {
            if tests.name == "tests" {
                
                /// Deselect UI
                self.actionBar?.handleInput(CGPoint(x:-10000, y:-10000))
                
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
    
    func setupGUI(_ leader:FKSquadEntity) {
        let bar = WGActionEntity(parentNode: self.ui!, leader:leader)
        self.actionBar = bar
        self.actionBar?.component(ofType: WGRenderComponent.self)?.show()
    }
    
    func heraldryTapped(_ squad: FKSquadEntity) {
        if(squad.controller == .enemyNPC) {
            self.actionBar?.handleEnemySquadTouched(squad)
        }
        else {
            self.actionBar?.selectSquad(squad)
        }
    }
   
    func heraldryDoubleTapped(_ squad: FKSquadEntity) {
        if let camera = self.camera {
            let pos = self.convert(squad.agent.actualPosition, from:squad.layer!)
            camera.panToPoint(point: pos)
        }
    }
    
    func heraldryLongPress(_ squad: FKSquadEntity) {
        /// do nothing
    }
    
    func heraldryTapStarted(_ squad: FKSquadEntity) {
        /// do nothing
    }
    
    func lockToPositionWhenOffscreen(_ desiredPosition: CGPoint, node: SKSpriteNode) -> CGPoint? {
        return WGAnchorPointService.sharedInstance.anchorIsNecessary(desiredPosition, node: node)
    }
    
    // MARK: UPDATE
    
    override func update(_ currentTime: CFTimeInterval) {
        
        /* Called before each frame is rendered */
        // Calculate the amount of time since `update` was last called.
        var deltaTime = currentTime - lastUpdateTimeInterval
        
        // If more than `maximumUpdateDeltaTime` has passed, clamp to the maximum; otherwise use `deltaTime`.
        deltaTime = deltaTime > maximumUpdateDeltaTime ? maximumUpdateDeltaTime : deltaTime
        
        // The current time will be used as the last update time in the next execution of the method.
        lastUpdateTimeInterval = currentTime
            
        /// Update the squad component system
        for componentSystem in FKSquadFactory.sharedInstance.componentSystems {
            componentSystem.update(deltaTime: deltaTime)
        }
        
        /// Update the unit component system
        for componentSystem in FKUnitFactory.sharedInstance.componentSystems {
            componentSystem.update(deltaTime: deltaTime)
        }
        
        /// Update entites not part of the system
        self.actionBar?.update(deltaTime: deltaTime)
        
    }
    
    // MARK: Pathfinding Protocol
    
    /// Positions should be in scene / global position (0,0) and NOT world layer
    func getPathToPoint(_ start: CGPoint, end: CGPoint) -> (path: GKPath, nodes: [GKGraphNode2D])? {
        return self.navmesh?.findPath(start, end: end, radius: 50, scene: self)
        ///return self.navmesh?.findPathIngoringBuffer(start, end: end, radius: 50, scene: self)
    }
    
    /// Desired should be a point in the World layer coordinate system
    func isPointValid(_ desired: float2) -> Bool {
        let valid = self.navmesh!.pointIsValid(desired)
        return valid
    }
    
    
}
