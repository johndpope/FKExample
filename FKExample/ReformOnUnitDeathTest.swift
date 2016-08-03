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
    
    var desc = "Tap to kill random unit in squad."
    
    init() {
        
    }
    
    init(scene:GameScene) {
        self.scene = scene
    }
    
    func setupTest(_ instructions:TestInstructions) {
        self.scene?.configureNavmesh()
        self.scene?.createSquadFromInstructions(instructions)
    }
    
    func tapped(_ location: CGPoint) {
        let rand = Int.random(min: 0, max: (self.scene?.squads[0].units.count)! - 1)
        let unit = self.scene?.squads[0].units[rand]
        unit!.component(ofType: FKDeathComponent.self)?.beginDeath()
    }
    
    func teardownTest() {
        
    }
    
    func setDebugFlags() {
        DebugFlags.sharedInstance.DEBUG_ENABLED = true
        DebugFlags.sharedInstance.SQUAD_STANDING_POSITIONS = true
        DebugFlags.sharedInstance.UNIT_STANDING_POSITIONS = true
    }
    
}
