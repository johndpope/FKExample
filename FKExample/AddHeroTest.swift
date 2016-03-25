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
    
    init(scene:GameScene) {
        self.scene = scene
    }
    
    func setupTest() {
        self.scene?.createSquad()
        self.scene?.createHero()
    }
    
    func tapped(location: CGPoint) {
        self.scene?.heros[0].addUnitToSquad((self.scene?.squads[0])!)
    }
    
    func teardownTest() {
        
    }
    
}

