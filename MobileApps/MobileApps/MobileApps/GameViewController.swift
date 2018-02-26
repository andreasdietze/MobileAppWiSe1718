//
//  GameViewController.swift
//  MobileApps
//
//  Created by Silas on 05.02.18.
//  Copyright © 2018 Silas. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Define scene
        let scene1 = MainMenu(size: self.view.bounds.size)
        
        // Define the sprite kit view
        let skview = self.view as! SKView
        
        // Show frame count
        skview.showsFPS = true
        
        // Show node count
        skview.showsNodeCount = true
        
        // Show collider objects
        skview.showsPhysics = true
        
        // Set scene
        skview.presentScene(scene1)
    }
}
