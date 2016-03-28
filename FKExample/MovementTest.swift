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
    
    init(scene:GameScene) {
        self.scene = scene
    }
    
    func setupTest() {
        self.scene?.configureNavmesh()
        self.scene?.createSquadWithHero()
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
    
}
