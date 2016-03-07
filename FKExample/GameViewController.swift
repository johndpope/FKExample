//
//  GameViewController.swift
//  FKExample
//
//  Created by Ryan Campbell on 2/19/16.
//  Copyright (c) 2016 Phalanx Studios. All rights reserved.
//

import UIKit
import SpriteKit
import SwitchBoard

class GameViewController: UIViewController {
    
    var sceneManager : SBSceneManager?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let skView = self.view as? SKView {

            self.sceneManager = SBSceneManager(view: skView)
        
            self.sceneManager?.registerScene("GameScene",
                scene: SBSceneContainer(
                    classType: GameScene.self,
                    name: "GameScene",
                    transition: nil,
                    preloadable: true,
                    category: SBSceneContainer.SceneGroup.Battle,
                    atlases: ["Melee1", "CombatAssets", "Bomur"]))
            
            if let initialScene = self.sceneManager?.scenes["GameScene"] {
                self.sceneManager?.sceneDidFinish(initialScene)
            }
            
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
