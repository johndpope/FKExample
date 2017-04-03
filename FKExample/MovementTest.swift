//
//  MovementTest.swift
//  FKExample
//
//  Created by Ryan Campbell on 3/24/16.
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

class MovementTest : Testable {
    
    weak var scene : GameScene?
    
    var desc = "Tap to move."
    
    init() {
        
    }
    
    init(scene:GameScene) {
        self.scene = scene
    }
    
    func setupTest(_ instructions:TestInstructions) {
        self.scene?.createSquadFromInstructions(instructions)
        self.addSecondSquad()
    }
    
    func addSecondSquad() {
        var instructions = TestInstructions(settings: combatTestSetting)
        instructions.name = "MovementTest"
        instructions.selectedFriendly = "Archer1"
        instructions.selectedFriendlySize = 12
        instructions.selectedFriendlyHero = nil
        self.scene?.createSquadFromInstructions(instructions, position: CGPoint(x:-500, y:1000), heading: 1)
    }
    
    func tapped(_ location: CGPoint) {
    
    }
    
    func teardownTest() {
  
    }
    
    func setDebugFlags() {
        DebugFlags.sharedInstance.DEBUG_ENABLED = true
        DebugFlags.sharedInstance.SQUAD_POSITION = true
        DebugFlags.sharedInstance.SQUAD_HEADING = true
    }
    
}
