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
    
    init(scene:GameScene) {
        self.scene = scene
    }
    
    func setupTest() {
        self.scene?.configureNavmesh()
        self.scene?.createSquadWithHero(position:CGPoint(x:500, y:0), heading: -1, currentUnits: 199, maxUnits: 200, columns: 15, spacing: 48)
    }
    
    func tapped(location: CGPoint) {
        let end = self.scene?.convertPoint(location, fromNode: (self.scene?.childNodeWithName("World")!)!)
        if let pathfinding = self.scene?.getPathToPoint((self.scene?.squads[0].agent.actualPosition)!, end: end!) {
            let instructions = FKMovementInstructions(position: location, path: pathfinding.path, type: FKMovementType.Path)
            self.scene?.squads[0].navigationComponent.executeMovementInstructions(instructions)
        }
    }
    
    func teardownTest() {
        
    }
    
}

