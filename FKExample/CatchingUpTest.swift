//
//  CatchingUpTest.swift
//  FKExample
//
//  Created by Ryan Campbell on 3/28/16.
//  Copyright © 2016 Phalanx Studios. All rights reserved.
//

import SpriteKit
import GameplayKit
#if os(iOS)
    import FormationKit
    import SwitchBoard
    import Particleboard
    import StrongRoom
#elseif os(OSX)
    import FormationKitOS
    import SwitchBoardOS
    import ParticleboardOS
    import StrongRoomOS
#endif

/// This test is currently a copy of invalid move. Turn on debug squad state to see when a unit switches to "C" for cathcing up.
class CatchingUpTest : Testable {
    
    weak var scene : GameScene?
    
    var desc = "Tap to move. Try t get stuck in corners."
    
    init() {
        
    }
    
    init(scene:GameScene) {
        self.scene = scene
    }
    
    func setupTest(_ instructions:TestInstructions) {
        self.scene?.createSquadFromInstructions(instructions, position:CGPoint(x:-1200, y:-1200))
        self.scene?.camera?.panToPoint(point: CGPoint(x:-1200, y:-1200))

    }
    
    func tapped(_ location: CGPoint) {
      
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

