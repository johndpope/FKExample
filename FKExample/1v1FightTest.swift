//
//  1v1Fight.swift
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
import StrongRoom

class SingleFightTest : Testable {
    
    weak var scene : GameScene?
    
    var desc = "Tap to engage 1 versus 1."
    
    init() {
        
    }
    
    init(scene:GameScene) {
        self.scene = scene
    }
    
    func setupTest(instructions:TestInstructions) {
        self.scene?.configureNavmesh()
        self.scene?.createSquadFromInstructions(instructions)
        self.scene?.createEnemySquadFromInstructions(instructions, position: CGPoint(x:1600, y:68))
    }
    
    func tapped(location: CGPoint) {
        var instructions = CommandInstructions()
        instructions.targetSquad = self.scene!.squads[1]
        if let ability = self.scene?.squads[0].abilitiesComponent.abilities.filter({$0.name == "Attack"}).first {
            self.scene?.squads[0].abilitiesComponent.runAbility(ability.ability, instructions: instructions)
        }
        if let ability = self.scene?.squads[0].abilitiesComponent.abilities.filter({$0.name == "Shoot"}).first {
            self.scene?.squads[0].abilitiesComponent.runAbility(ability.ability, instructions: instructions)
        }
    }
    
    func teardownTest() {
        
    }
    
    func setDebugFlags() {
        DebugFlags.sharedInstance.DEBUG_ENABLED = true
        DebugFlags.sharedInstance.SQUAD_TARGETS = true
        DebugFlags.sharedInstance.UNIT_TARGETS = true
    }
    
}

