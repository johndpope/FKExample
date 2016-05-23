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
    
    init() {
        
    }
    
    init(scene:GameScene) {
        self.scene = scene
    }
    
    func setupTest(instructions:TestInstructions) {
        self.scene?.configureNavmesh()
        self.scene?.createSquadFromInstructions(instructions, position:CGPoint(x:-1200, y:-1200))
        self.scene?.camera?.panToPoint(CGPoint(x:-1200, y:-1200))

    }
    
    func tapped(location: CGPoint) {
        
    }
    
    func teardownTest() {
        
    }
    
    func setDebugFlags() {
        DebugFlags.sharedInstance.DEBUG_ENABLED = true
        DebugFlags.sharedInstance.SQUAD_POSITION = true
        DebugFlags.sharedInstance.UNIT_STANDING_POSITIONS = true
        DebugFlags.sharedInstance.SQUAD_HEADING = true

    }
    
}

