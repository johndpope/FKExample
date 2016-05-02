//
//  TestSelect.swift
//  FKExample
//
//  Created by Ryan Campbell on 5/2/16.
//  Copyright © 2016 Phalanx Studios. All rights reserved.
//

import SpriteKit

class TestSelect : SKNode {
    
    var root : SKNode?
    
    override init() {
        super.init()
        let ref = SKReferenceNode(fileNamed: "TestSelect")
        self.root = (ref!.children.first!.copy() as! SKNode)
        self.addChild(self.root!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    // MARK: User Input
    

    
}


