//
//  GameScene.swift
//  MobileApps
//
//  Created by Silas on 05.02.18.
//  Copyright © 2018 Silas. All rights reserved.
//

import SpriteKit
//import AVFoundation

class GameScene: SKScene {

    // Global game objects
    let ship = SKSpriteNode(imageNamed: "ship")
    let backgroundScene1 = SKSpriteNode(imageNamed: "background")
    let backgroundScene2 = SKSpriteNode(imageNamed: "background")
    
    // Global class objects
    var audioManager = AudioManager()
    var backgroundManager = BackgroundManager()
    
    override func didMove(to view: SKView) {

        // Player
        ship.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - 200)
        ship.setScale(0.25)
        ship.zPosition = 1
        self.addChild(ship)
    
        // Background
        backgroundManager.initBackground(gameInstance: self) // Pass as GameScene
        
        // AudioManager
        audioManager.initAudioFiles()
        audioManager.playBackgroundMusic()
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let locationUser = touch.location(in: self)
            ship.position.x = locationUser.x
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let locationUser = touch.location(in: self)
            
            if atPoint(locationUser) == ship {
                addBullet()
            }
        }
        
    }
    
    // Gameloop
    override func update(_ currentTime: TimeInterval) {
        
        backgroundManager.updateBackground()
        
    }
    
    func addBullet() {
        
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.position = ship.position
        bullet.zPosition = 0
        self.addChild(bullet)
        
        // Actions - transformation
        let moveTo = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 3)
        let delete = SKAction.removeFromParent()
        
        bullet.run(SKAction.sequence([moveTo, delete]))
        
        // Actions - sound
        //bullet.run(SKAction.playSoundFileNamed("LaserShot", waitForCompletion: true)) // example
        audioManager.playPlayerShotSoundSKAction(bullet: bullet) // works very good (frequency)
        //audioManager.playPlayerShotSound() // works - low frequency
        
    }
    
    // Global access to game instance
    // https://stackoverflow.com/questions/29809643/how-to-make-a-global-variable-that-uses-self-in-swift
    //class var sharedInstance: GameScene {
      //  return _SingletonSharedInstance
    //}
    
}

// Global access to game instance --> not working T_T
//private let _SingletonSharedInstance = GameScene()

