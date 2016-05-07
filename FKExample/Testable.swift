//
//  Testable.swift
//  FKExample
//
//  Created by Ryan Campbell on 3/24/16.
//  Copyright © 2016 Phalanx Studios. All rights reserved.
//

import SpriteKit

protocol Testable {
        
    var desc : String { get }
    
    weak var scene : GameScene? { get set }
    
    func setupTest(instructions:TestInstructions)
    
    func tapped(location:CGPoint)
    
    func teardownTest()
    
    func setDebugFlags()
    
}
