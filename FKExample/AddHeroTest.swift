//
//  AddHeroTest.swift
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
class AddHeroTest : Testable {
    
    weak var scene : GameScene?
    
    var desc = "Tap to add the hero to the squad."
    
    init() {
        
    }
    
    init(scene:GameScene) {
        self.scene = scene
    }
    
    func setupTest(_ instructions:TestInstructions) {
        self.scene?.configureNavmesh()
        self.scene?.createSquad(instructions.selectedFriendly!)
        self.scene?.createHero()
    }
    
    func tapped(_ location: CGPoint) {
        self.scene?.heros[0].addUnitToSquad((self.scene?.squads[0])!)
    }
    
    func teardownTest() {
        
    }
    
    func setDebugFlags() {
        DebugFlags.sharedInstance.DEBUG_ENABLED = true
        DebugFlags.sharedInstance.SQUAD_STANDING_POSITIONS = true
        DebugFlags.sharedInstance.UNIT_STANDING_POSITIONS = true
    }
    
}

