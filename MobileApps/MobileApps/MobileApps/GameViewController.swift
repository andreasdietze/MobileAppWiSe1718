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
        
        let scene1 = GameScene(size: self.view.bounds.size)
        let skview = self.view as! SKView
        skview.showsFPS = true
        skview.showsNodeCount = true
        
        skview.presentScene(scene1)
    }
}
