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
    
    func setupTest()
    
    func tapped(location:CGPoint)
    
    func teardownTest()
    
    func setDebugFlags()
    
}
