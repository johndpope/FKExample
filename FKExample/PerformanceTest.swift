//
//  PerformanceTest.swift
//  FKExample
//
//  Created by Ryan Campbell on 3/28/16.
//  Copyright © 2016 Phalanx Studios. All rights reserved.
//

import SpriteKit
import GameplayKit
import FormationKit
import SwitchBoard
import Particleboard

class PerformanceTest : Testable {
    
    weak var scene : GameScene?
    
    var desc = "Tap to move."
    
    init() {
        
    }
    
    init(scene:GameScene) {
        self.scene = scene
    }
    
    func setupTest(_ instructions:TestInstructions) {
        self.scene?.configureNavmesh()
        self.scene?.createSquadWithHero(instructions.selectedFriendly!,position:CGPoint(x:500, y:0), heading: -1, currentUnits: 199, maxUnits: 200, columns: 15, spacing: 48)
    }
    
    func tapped(_ location: CGPoint) {
  
    }
    
    func teardownTest() {
        
    }
    
    func setDebugFlags() {
        
    }
    
}

