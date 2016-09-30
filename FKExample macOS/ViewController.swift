//
//  ViewController.swift
//  FKExample macOS
//
//  Created by Ryan Campbell on 9/16/16.
//  Copyright © 2016 Phalanx Studios. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit
import SwitchBoardOS
import ParticleboardOS

class ViewController: NSViewController {
    
    var sceneManager : SBSceneManager?

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let skView = self.view as? SKView {
            
            // NOTE: Uncommenting these causes a memory leak, so don't be alarmed.
            skView.showsFPS = true
            skView.showsNodeCount = true
            ///skView.showsPhysics = true
            skView.showsDrawCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /// Cut the framerate down to 30 FPS
            skView.preferredFramesPerSecond = 30
            
            self.sceneManager = SBSceneManager(view: skView)
            
            self.sceneManager?.registerScene(key: "GameScene",
                                             scene: SBSceneContainer(
                                                classType: GameScene.self,
                                                name: "GameScene",
                                                transition: nil,
                                                preloadable: true,
                                                category: SBSceneContainer.SceneGroup.Battle,
                                                atlases: ["dialogue", "Trebuchet", "BadArcher1", "Archer1", "Melee1", "Melee2", "CombatAssets", "Bomur", "Test", "Interface", "icons", "Stou"]))
            
            if let initialScene = self.sceneManager?.scenes["GameScene"] {
                self.sceneManager?.sceneDidFinish(nextScene: initialScene)
            }
            
            skView.showsPhysics = false
            
        }
        
    }
}

