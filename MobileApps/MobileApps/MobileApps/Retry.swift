//
//  Retry.swift
//  MobileApps
//
//  Created by Silas on 27.02.18.
//  Copyright © 2018 Silas. All rights reserved.
//

import SpriteKit
//import Foundation

class Retry: SKScene {
    
    let exitButton = SKSpriteNode(imageNamed: "exit_buttons_pressed")
    
    override func didMove(to view: SKView) {
        exitButton.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        exitButton.setScale(0.5)
        self.addChild(exitButton)
        self.backgroundColor = SKColor.black
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let loc = touch.location(in: self)
            if atPoint(loc) == exitButton {
                let transition = SKTransition.fade(withDuration: 2)
                let mainMenu = MainMenu(size: self.size)
                self.view?.presentScene(mainMenu, transition: transition)
            }
        }
    }
}

