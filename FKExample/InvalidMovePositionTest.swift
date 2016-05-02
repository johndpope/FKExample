//
//  InvalidMovePositionTest.swift
//  FKExample
//
//  Created by Ryan Campbell on 3/26/16.
//  Copyright © 2016 Phalanx Studios. All rights reserved.
//

import SpriteKit
import GameplayKit
import FormationKit
import SwitchBoard
import Particleboard

class InvalidMovePositionTest : Testable {
    
    weak var scene : GameScene?
    
    var desc = "Tap to move. Try a position off of the map."
    
    init(scene:GameScene) {
        self.scene = scene
    }
    
    func setupTest() {
        self.scene?.configureNavmesh()
        self.scene?.createSquadWithHero(position:CGPoint(x:-1200, y:-1200), heading: -0.1)
        self.scene?.camera?.panToPoint(CGPoint(x:-1200, y:-1200))
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
    
    func setDebugFlags() {
        DebugFlags.sharedInstance.DEBUG_ENABLED = true
        DebugFlags.sharedInstance.SQUAD_POSITION = true
        DebugFlags.sharedInstance.UNIT_STANDING_POSITIONS = true
    }
    
}

