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
        self.scene?.createSquadFromInstructions(instructions)

    }
    
    func tapped(location: CGPoint) {
    
    }
    
    func teardownTest() {
  
    }
    
    func setDebugFlags() {
        DebugFlags.sharedInstance.DEBUG_ENABLED = true
        DebugFlags.sharedInstance.SQUAD_POSITION = true
        DebugFlags.sharedInstance.SQUAD_HEADING = true
    }
    
}
