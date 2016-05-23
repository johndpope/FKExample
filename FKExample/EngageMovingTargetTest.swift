//
//  EngageMovingTargetTest.swift
//  FKExample
//
//  Created by Ryan Campbell on 3/29/16.
//  Copyright © 2016 Phalanx Studios. All rights reserved.
//

import SpriteKit
import GameplayKit
import FormationKit
import SwitchBoard
import Particleboard

class EngageMovingTargetTest : Testable {
    
    weak var scene : GameScene?
    
    var desc = "Tap to engage a moving target."
    
    init() {
        
    }
    
    init(scene:GameScene) {
        self.scene = scene
    }
    
    func setupTest(instructions:TestInstructions) {
        self.scene?.configureNavmesh()
        self.scene?.createSquadFromInstructions(instructions)
        self.scene?.createEnemySquadFromInstructions(instructions, position: CGPoint(x:1600, y:68))
        
        self.scene?.addAbilitiesToSquad(self.scene!.squads[0])
        self.scene?.addAbilitiesToSquad(self.scene!.squads[1])
    }
    
    func moveEnemySquad() {
        let moveAbility = self.scene?.squads[1].abilitiesComponent.abilities.filter({$0.name == "Move"}).first
        var instructions = CommandInstructions()
        instructions.desiredPosition = CGPoint(x:0, y:68)
        self.scene?.squads[1].abilitiesComponent.runAbility(moveAbility!.ability, instructions: instructions)
    }
    
    func tapped(location: CGPoint) {

    }
    
    func teardownTest() {
        
    }
    
    func setDebugFlags() {
        DebugFlags.sharedInstance.DEBUG_ENABLED = true
        DebugFlags.sharedInstance.SQUAD_TARGETS = true
        DebugFlags.sharedInstance.UNIT_TARGETS = true
        DebugFlags.sharedInstance.SQUAD_STATE = true
    }
    
}

