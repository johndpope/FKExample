//
//  ReformTest.swift
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

class ReformTest : Testable {
    
    weak var scene : GameScene?
    
    var desc = "Tap to reform by distance."
    
    init() {
        
    }
    
    init(scene:GameScene) {
        self.scene = scene
    }
    
    func setupTest(_ instructions:TestInstructions) {
        self.scene?.configureNavmesh()
        self.scene?.createSquadFromInstructions(instructions)
        self.scrambleUnits()
    }
    
    func tapped(_ location: CGPoint) {
        self.scene?.squads[0].formationComponent.reassignStandingPositionsByDistance()
    }
    
    func teardownTest() {
        
    }
    
    func scrambleUnits() {
        for unit in (self.scene?.squads[0].units)! {
            unit.component(ofType: FKRankComponent.self)?.standingPosition?.occupiedBy = nil
            unit.component(ofType: FKRankComponent.self)?.standingPosition = nil
            let randomX = CGFloat.random(min: -300, max: 300)
            let randomY = CGFloat.random(min: -300, max: 300)
            let base = unit.component(ofType: FKRenderComponent.self)?.basePosition
            let location = CGPoint(x: base!.x + randomX, y: base!.y + randomY)
            let instructions = FKMovementInstructions(position: location, path: nil, type: FKMovementType.towards)
            unit.movementComponent.executeMovementInstructions(instructions)
        }
    }
    
    func setDebugFlags() {
        DebugFlags.sharedInstance.DEBUG_ENABLED = true
        DebugFlags.sharedInstance.SQUAD_STANDING_POSITIONS = true
        DebugFlags.sharedInstance.UNIT_STANDING_POSITIONS = true
    }
    
}

