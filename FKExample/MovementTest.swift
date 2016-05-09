//
//  MovementTest.swift
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

class MovementTest : Testable {
    
    weak var scene : GameScene?
    
    var desc = "Tap to move."
    
    init() {
        
    }
    
    init(scene:GameScene) {
        self.scene = scene
    }
    
    func setupTest(instructions:TestInstructions) {
        self.scene?.configureNavmesh()
        
        var formation = FKFormationComponent.Arrangement.Grid
        if instructions.selectedFriendlyFormation == "Triangle" {
            formation = FKFormationComponent.Arrangement.Triangle
        }
        
        if instructions.selectedFriendlyHero != nil {
            self.scene?.createSquadWithHero(
                instructions.selectedFriendly!,
                currentUnits:instructions.selectedFriendlySize,
                maxUnits:instructions.selectedFriendlySize + 1,
                formation: formation,
                hero: instructions.selectedFriendlyHero!)
        }
        else {
            self.scene?.createSquad(
                instructions.selectedFriendly!,
                currentUnits:instructions.selectedFriendlySize,
                maxUnits:instructions.selectedFriendlySize + 1,
                formation: formation)
        }
        self.scene?.addMoveToSquad(self.scene!.squads[0])
    }
    
    func tapped(location: CGPoint) {
    
        let moveAbility = self.scene?.squads[0].abilitiesComponent.abilities.filter({$0.name == "Move"}).first
        var instructions = CommandInstructions()
        instructions.desiredPosition = location
        self.scene?.squads[0].abilitiesComponent.runAbility(moveAbility!.ability, instructions: instructions)
            
    }
    
    func teardownTest() {
  
    }
    
    func setDebugFlags() {
        DebugFlags.sharedInstance.DEBUG_ENABLED = true
        DebugFlags.sharedInstance.SQUAD_POSITION = true
        DebugFlags.sharedInstance.SQUAD_HEADING = true
    }
    
}
