//
//  ReformOnUnitDeathTest.swift
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

class ReformOnUnitDeathTest : Testable {
    
    weak var scene : GameScene?
    
    init(scene:GameScene) {
        self.scene = scene
    }
    
    func setupTest() {
        self.scene?.configureNavmeshWithObstacles([])
        self.scene?.createSquadWithHero()
    }
    
    func tapped(location: CGPoint) {
        let rand = Int.random(min: 0, max: (self.scene?.squads[0].units.count)! - 1)
        let unit = self.scene?.squads[0].units[rand]
        unit!.componentForClass(FKDeathComponent)?.beginDeath()
    }
    
    func teardownTest() {
        
    }
    
}
