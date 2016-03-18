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

class GameScene: SBGameScene {
    
    var lastUpdateTimeInterval: NSTimeInterval = 0
    
    let maximumUpdateDeltaTime: NSTimeInterval = 2.0 / 60.0
    
    var squads = [FKSquadEntity]()
    
    var touchCallback : ((location:CGPoint)->())? = nil
    
    override func didMoveToView(view: SKView) {
        
        let world = SKNode()
        world.name = "World"
        self.addChild(world)
        
        /// Notify squad 1 that 2 exists
        //squad.navigationComponent.agentsToAvoid.append(squad2.agent)
        
        //self.setupMovementTest()
        //self.setupReformOnDeathTest()
        self.setupReformTest()

    }
    
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
                formation:FKFormationComponent.Arrangement.Grid,
                columns: 6,
                spacing: 64))
        
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
                currentUnits: 40,
                maxUnits: 40,
                controller: .Player,
                scene: self,
                layer: self.childNodeWithName("World")!,
                formation:FKFormationComponent.Arrangement.Grid,
                columns: 6,
                spacing: 64,
                hero:"Bomur"))
        
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
                formation:FKFormationComponent.Arrangement.Grid,
                columns: 5,
                spacing: 64))
        
        self.squads.append(squad2)

    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            self.touchCallback?(location: location)
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
    
    // MARK: Movement Test
    
    func setupMovementTest() {
        self.createSquadWithHero()
        self.touchCallback = self.moveOnTouch
    }
    
    func moveOnTouch(location:CGPoint) {
        let instructions = FKMovementInstructions(position: location, path: nil, type: FKMovementType.Towards)
        self.squads[0].navigationComponent.executeMovementInstructions(instructions)
    }
    
    // MARK: Reform on Unit Death Test

    func setupReformOnDeathTest() {
        self.createSquadWithHero()
        self.touchCallback = self.killRandomUnitOnTouch
    }
    
    func killRandomUnitOnTouch(location:CGPoint) {
        let rand = Int.random(min: 0, max: self.squads[0].units.count - 1)
        let unit = self.squads[0].units[rand]
        unit.componentForClass(FKDeathComponent)?.beginDeath()
    }
    
    // MARK: Reform after random positioning test
    
    func setupReformTest() {
        self.createSquadWithHero()
        self.scrambleUnits()
        self.touchCallback = self.reformUnits
    }
    
    func scrambleUnits() {
        for unit in self.squads[0].units {
            unit.componentForClass(FKRankComponent)?.standingPosition?.occupiedBy = nil
            unit.componentForClass(FKRankComponent)?.standingPosition = nil
            let randomX = CGFloat.random(min: -300, max: 300)
            let randomY = CGFloat.random(min: -300, max: 300)
            let base = unit.componentForClass(FKRenderComponent)?.basePosition
            let location = CGPoint(x: base!.x + randomX, y: base!.y + randomY)
            let instructions = FKMovementInstructions(position: location, path: nil, type: FKMovementType.Towards)
            unit.movementComponent.executeMovementInstructions(instructions)
        }
    }
    
    func reformUnits(location:CGPoint) {
        self.squads[0].formationComponent.reassignStandingPositionsByDistance()
    }

    
    
}
