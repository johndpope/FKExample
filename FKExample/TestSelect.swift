//
//  TestSelect.swift
//  FKExample
//
//  Created by Ryan Campbell on 5/2/16.
//  Copyright © 2016 Phalanx Studios. All rights reserved.
//

import SpriteKit


/**
    These are the test settings used in the map of all tests. This is used by the UI to know what must be selected before the continue button shows.
*/
struct TestSettings {
    
    var selectFriendly : Bool
    
    var selectFriendlyHero : Bool
    
    var selectFriendlyAbility : Bool
    
    var selectEnemy : Bool
    
    var selectEnemyHero : Bool
    
    var selectEnemyAbility : Bool
    
}

/// A convienent list of predfined test settings
let movementTestSetting = TestSettings(selectFriendly: true, selectFriendlyHero: true, selectFriendlyAbility: false, selectEnemy: false, selectEnemyHero: false, selectEnemyAbility: false)

let combatTestSetting = TestSettings(selectFriendly: true, selectFriendlyHero: true, selectFriendlyAbility: true, selectEnemy: true, selectEnemyHero: true, selectEnemyAbility: true)

/**
    Use this class to pass to each test. Informs the test which settings to use.
 */
class TestInstructions {
    
    var settings : TestSettings
    
    var name : String?
    
    init(settings:TestSettings) {
        self.settings = settings
    }
    
    func testIsValid() -> Bool {
        if self.name != nil {
            return true
        }
        return false
    }
    
}

/**
The UI and logic to select a test
*/
class TestSelect : SKNode {
    
    var root : SKNode
    
    var callback : (instructions:TestInstructions)->() = {_ in }
    
    var selectedTest : String? = nil
    
    var instructions : TestInstructions?
    
    override init() {
        self.root = SKNode()
        super.init()
        let ref = SKReferenceNode(fileNamed: "TestSelect")
        for child in ref!.children {
            self.root.addChild(child.copy() as! SKNode)
        }
        self.addChild(self.root)
        self.userInteractionEnabled = true
        self.hidePanels(["Friendly", "Ability", "Enemy", "EnemyAbility"])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Tests
    
    func testSelected(name:String, node:SKNode) {
        self.unhighlightTests()
        self.highlightSelectedTest(node)
        self.selectedTest = name
        self.instructions = TestInstructions(settings: movementTestSetting)
        self.instructions!.name = name
        self.allowContinueIfValidParameters()
    }
    
    func highlightSelectedTest(node:SKNode) {
        if let highlight = self.root.childNodeWithName("Test/test_highlight") {
            highlight.position = CGPoint(x:highlight.position.x, y:node.position.y + 1)
            if let label = node as? SKLabelNode {
                label.fontColor = SKColor.whiteColor()
            }
        }
    }
    
    func unhighlightTests() {
        for child in self.root.childNodeWithName("Test")!.children {
            if let label = child as? SKLabelNode {
                label.fontColor = SKColor.blackColor()
            }
        }
    }
    
    
    // MARK: Friendly Unit
    
    
    // MARK: Friendly Abilties
    
    
    // MARK: Enemy Unit
    
    
    // MARK: Enemy Abilities
    
    
    // MARK: Continue
    
    func allowContinueIfValidParameters() {
        if self.paramatersAreValid() {
            self.showContinueButton()
        }
        else {
            self.hideContinueButton()
        }
    }
    
    func paramatersAreValid() -> Bool {
        if self.instructions?.testIsValid() == true {
            return true
        }
        return false
    }
    
    func showContinueButton() {
        if let proceed = self.root.childNodeWithName("Continue") {
            if proceed.position.y != 50 {
                proceed.runAction(SKAction.moveToY(50, duration: 0.3))
            }
        }
    }
    
    func hideContinueButton() {
        if let proceed = self.root.childNodeWithName("Continue") {
            if proceed.position.y != -110 {
                proceed.runAction(SKAction.moveToY(-110, duration: 0.3))
            }
        }
    }
    
    func continuePressed() {
        self.callback(instructions: self.instructions!)
        self.root.removeFromParent()
    }
    
    // MARK: Utility
    
    func hidePanels(names:[String]) {
        for name in names {
            self.hidePanel(name)
        }
    }
    
    func hidePanel(name:String) {
        self.root.childNodeWithName(name)?.hidden = true
    }
    
    func showPanels(names:[String]) {
        for name in names {
            self.showPanel(name)
        }
    }
    
    func showPanel(name:String) {
        self.root.childNodeWithName(name)?.hidden = false
    }
    
    // MARK: User Input
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self.root)
            let nodes = self.root.nodesAtPoint(location)
            for node in nodes {
                if(node.name?.rangeOfString("test_") != nil) {
                    let name = node.name!.replace("test_", withString: "")
                    self.testSelected(name, node: node)
                }
                
                if(node.name?.rangeOfString("run") != nil) {
                    self.continuePressed()
                }
            }
        }

    }
    
}


