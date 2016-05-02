//
//  AddHeroTest.swift
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

class AddHeroTest : Testable {
    
    weak var scene : GameScene?
    
    var desc = "Tap to add the hero to the squad."
    
    init(scene:GameScene) {
        self.scene = scene
    }
    
    func setupTest() {
        self.scene?.configureNavmeshWithObstacles(["obstacle_square_1"])
        self.scene?.createSquad()
        self.scene?.createHero()
    }
    
    func tapped(location: CGPoint) {
        self.scene?.heros[0].addUnitToSquad((self.scene?.squads[0])!)
    }
    
    func teardownTest() {
        
    }
    
    func setDebugFlags() {
        DebugFlags.sharedInstance.DEBUG_ENABLED = true
        DebugFlags.sharedInstance.SQUAD_STANDING_POSITIONS = true
        DebugFlags.sharedInstance.UNIT_STANDING_POSITIONS = true
    }
    
}

