//
//  MainMenu.swift
//  MobileApps
//
//  Created by Silas on 26.02.18.
//  Copyright © 2018 Silas. All rights reserved.
//

import SpriteKit
//import Foundation

class MainMenu: SKScene {

    let playButton = SKSpriteNode(imageNamed: "play_buttons_pressed_blue")
    let exitButton = SKSpriteNode(imageNamed: "exit_buttons")
    
    override func didMove(to view: SKView) {
        playButton.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 + playButton.size.height / 4)
        playButton.setScale(0.5)
        self.addChild(playButton)
        
        exitButton.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - exitButton.size.height / 4)
        exitButton.setScale(0.5)
        self.addChild(exitButton)
        
        self.backgroundColor = SKColor.black
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let loc = touch.location(in: self)
            if atPoint(loc) == playButton {
                let transition = SKTransition.fade(withDuration: 2)
                let gameScene = GameScene(size: self.size)
                self.view?.presentScene(gameScene, transition: transition)
            }
            if atPoint(loc) == exitButton{
                exit(0)
            }
        }
    }
}
