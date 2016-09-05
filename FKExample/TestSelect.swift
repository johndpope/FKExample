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
    
    var selectedFriendly : String?
    
    var selectedFriendlyHero : String? = "Bomur"
    
    var selectedFriendlyAbility : String?
    
    var selectedFriendlyFormation : String = "Square"
    
    var selectedFriendlySize : Int = 6
    
    var selectedEnemy : String?
    
    var selectedEnemyHero : String?
    
    var selectedEnemyAbility : String?
    
    var selectedEnemyFormation : String = "Square"
    
    var selectedEnemySize : Int = 6
    
    init(settings:TestSettings) {
        self.settings = settings
    }
    
    func testIsValid() -> Bool {
        if self.name == nil {
            return false
        }
        
        if self.selectedFriendly == nil && self.settings.selectFriendly == true {
            return false
        }
        
        if self.selectedEnemy == nil && self.settings.selectEnemy == true {
            return false
        }
        
        return true
    }
    
}

/**
The UI and logic to select a test
*/
class TestSelect : SKNode {
    
    var root : SKNode
    
    var callback : (_ instructions:TestInstructions)->() = {_ in }
    
    var instructions : TestInstructions?
    
    override init() {
        self.root = SKNode()
        super.init()
        let ref = SKReferenceNode(fileNamed: "TestSelect")
        for child in ref!.children {
            self.root.addChild(child.copy() as! SKNode)
        }
        self.addChild(self.root)
        self.isUserInteractionEnabled = true
        self.hidePanels(["Friendly", "Ability", "Enemy", "EnemyAbility"])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Tests
    
    func testSelected(_ name:String, node:SKNode) {
        self.hideFriendlyUnitPanels()
        self.hideEnemyUnitPanels()
        self.highlightItem(node, highlightPath: "Test/test_highlight")
        self.instructions = TestInstructions(settings: classMap[name]!.settings)
        self.instructions!.name = name
        if !self.allowContinueIfValidParameters() {
            self.showFriendlyUnitPanels()
        }
    }
    
    
    // MARK: Friendly Unit
    
    func showFriendlyUnitPanels() {
        self.showPanel("Friendly")
        self.showPanel("Ability")
    }
    
    func hideFriendlyUnitPanels() {
        self.hidePanel("Friendly")
        self.hidePanel("Ability")
    }
    
    func friendlyUnitSelected(_ name:String, node:SKNode) {
        self.highlightItem(node, highlightPath: "Friendly/Friendly_highlight")
        self.instructions!.selectedFriendly = name
        if !self.allowContinueIfValidParameters() {
            self.showEnemyUnitPanels()
        }

    }
    
    // MARK: Friendly Abilties
    
    
    
    // MARK: Friendly Hero
    
    func selectFriendlyHero(_ name:String, node:SKNode) {
        if name != self.instructions!.selectedFriendlyHero {
            self.highlightItem(node, highlightPath: "Ability/FriendlyHeroUI_highlight")
            self.instructions?.selectedFriendlyHero = name
        }
        else {
            self.instructions?.selectedFriendlyHero = nil
            self.unhighlightItem("Ability/FriendlyHeroUI_highlight")
        }
    }
    
    // MARK: Friendly Size
    
    func selectFriendlySize(_ size:Int, node:SKNode) {
        self.highlightItem(node, highlightPath: "Ability/FriendlySizeUI_highlight")
        self.instructions?.selectedFriendlySize = size
    }
    
    // MARK: Friendly Formation
    
    func selectFriendlyFormation(_ name:String, node:SKNode) {
        self.highlightItem(node, highlightPath: "Ability/FriendlyFormationUI_highlight")
        self.instructions?.selectedFriendlyFormation = name
    }
    
    // MARK: Enemy Unit
    
    func showEnemyUnitPanels() {
        self.showPanel("Enemy")
        self.showPanel("EnemyAbility")
    }
    
    func hideEnemyUnitPanels() {
        self.hidePanel("Enemy")
        self.hidePanel("EnemyAbility")
    }
    
    func unhighlightEnemyUnits() {
        for child in self.root.childNode(withName: "Enemy")!.children {
            if let label = child as? SKLabelNode {
                label.fontColor = SKColor.black
            }
        }
    }
    
    func highlightSelectedEnemyUnit(_ node:SKNode) {
        if let highlight = self.root.childNode(withName: "Enemy/Enemy_highlight") {
            highlight.position = CGPoint(x:highlight.position.x, y:node.position.y)
        }
    }
    
    func enemyUnitSelected(_ name:String, node:SKNode) {
        self.unhighlightEnemyUnits()
        self.highlightSelectedEnemyUnit(node)
        self.instructions!.selectedEnemy = name
        if !self.allowContinueIfValidParameters() {
            
        }
        
    }
    
    
    // MARK: Enemy Abilities
    
    
    // MARK: Enemy Size
    
    func selectEnemySize(_ size:Int, node:SKNode) {
        self.highlightItem(node, highlightPath: "EnemyAbility/EnemySizeUI_highlight")
        self.instructions?.selectedEnemySize = size
    }
    
    // MARK: Enemy Formation
    
    func selectEnemyFormation(_ name:String, node:SKNode) {
        self.highlightItem(node, highlightPath: "EnemyAbility/EnemyFormationUI_highlight")
        self.instructions?.selectedEnemyFormation = name
    }
    
    
    // MARK: Continue
    
    func allowContinueIfValidParameters() -> Bool {
        if self.paramatersAreValid() {
            self.showContinueButton()
            return true
        }
        else {
            self.hideContinueButton()
            return false
        }
    }
    
    func paramatersAreValid() -> Bool {
        if self.instructions?.testIsValid() == true {
            return true
        }
        return false
    }
    
    func showContinueButton() {
        if let proceed = self.root.childNode(withName: "Continue") {
            if proceed.position.y != 50 {
                proceed.run(SKAction.moveTo(y: 50, duration: 0.3))
            }
        }
    }
    
    func hideContinueButton() {
        if let proceed = self.root.childNode(withName: "Continue") {
            if proceed.position.y != -110 {
                proceed.run(SKAction.moveTo(y: -110, duration: 0.3))
            }
        }
    }
    
    func continuePressed() {
        
        /// Hard coded fixes
        if self.instructions?.selectedFriendly == "Trebuchet" {
            self.instructions?.selectedFriendlySize = 1
            self.instructions?.selectedFriendlyHero = nil
        }
       
        self.callback(self.instructions!)
        self.root.removeFromParent()
    }
    
    // MARK: Utility
    
    func hidePanels(_ names:[String]) {
        for name in names {
            self.hidePanel(name)
        }
    }
    
    func hidePanel(_ name:String) {
        self.root.childNode(withName: name)?.isHidden = true
    }
    
    func showPanels(_ names:[String]) {
        for name in names {
            self.showPanel(name)
        }
    }
    
    func showPanel(_ name:String) {
        self.root.childNode(withName: name)?.isHidden = false
    }
    
    func highlightItem(_ node:SKNode, highlightPath:String) {
        if let highlight = self.root.childNode(withName: highlightPath) {
            highlight.position = CGPoint(x:highlight.position.x, y:node.position.y)
        }
    }
    
    func unhighlightItem(_ highlightPath:String) {
        if let highlight = self.root.childNode(withName: highlightPath) {
            highlight.position = CGPoint(x:highlight.position.x, y:10000)
        }
    }
    
    // MARK: User Input
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self.root)
            let nodes = self.root.nodes(at: location)
            for node in nodes {
                if(node.name?.range(of: "test_") != nil) {
                    let name = node.name!.replacingOccurrences(of: "test_", with: "")
                    self.testSelected(name, node: node)
                }
                
                if(node.name?.range(of: "Friendly_") != nil) {
                    let name = node.name!.replacingOccurrences(of: "Friendly_", with: "")
                    self.friendlyUnitSelected(name, node: node)
                }
                
                if(node.name?.range(of: "FriendlySize_") != nil) {
                    let name = node.name!.replacingOccurrences(of: "FriendlySize_", with: "")
                    self.selectFriendlySize(Int(name)!, node: node)
                }
                
                if(node.name?.range(of: "FriendlyFormation_") != nil) {
                    let name = node.name!.replacingOccurrences(of: "FriendlyFormation_", with: "")
                    self.selectFriendlyFormation(name, node: node)
                }
                
                if(node.name?.range(of: "FriendlyHero_") != nil) {
                    let name = node.name!.replacingOccurrences(of: "FriendlyHero_", with: "")
                    self.selectFriendlyHero(name, node: node)
                }
                
                if(node.name?.range(of: "Enemy_") != nil) {
                    let name = node.name!.replacingOccurrences(of: "Enemy_", with: "")
                    self.enemyUnitSelected(name, node: node)
                }
                
                if(node.name?.range(of: "EnemySize_") != nil) {
                    let name = node.name!.replacingOccurrences(of: "EnemySize_", with: "")
                    self.selectEnemySize(Int(name)!, node: node)
                }
                
                if(node.name?.range(of: "EnemyFormation_") != nil) {
                    let name = node.name!.replacingOccurrences(of: "EnemyFormation_", with: "")
                    self.selectEnemyFormation(name, node: node)
                }
                
                if(node.name?.range(of: "run") != nil) {
                    self.continuePressed()
                }
            }
        }

    }
    
}


