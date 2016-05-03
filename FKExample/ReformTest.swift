//
//  ReformTest.swift
//  FKExample
//
//  Created by Ryan Campbell on 3/24/16.
//  Copyright © 2016 Phalanx Studios. All rights reserved.
//

import SpriteKit
import GameplayKit
import FormationKit
import SwitchBoard
import Particleboard

class ReformTest : Testable {
    
    weak var scene : GameScene?
    
    var desc = "Tap to reform by distance."
    
    init() {
        
    }
    
    init(scene:GameScene) {
        self.scene = scene
    }
    
    func setupTest() {
        self.scene?.configureNavmesh()
        self.scene?.createSquadWithHero()
        self.scrambleUnits()
    }
    
    func tapped(location: CGPoint) {
        self.scene?.squads[0].formationComponent.reassignStandingPositionsByDistance()
    }
    
    func teardownTest() {
        
    }
    
    func scrambleUnits() {
        for unit in (self.scene?.squads[0].units)! {
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
    
    func setDebugFlags() {
        DebugFlags.sharedInstance.DEBUG_ENABLED = true
        DebugFlags.sharedInstance.SQUAD_STANDING_POSITIONS = true
        DebugFlags.sharedInstance.UNIT_STANDING_POSITIONS = true
    }
    
}

