//
//  GameScene.swift
//  MobileApps
//
//  Created by Silas on 05.02.18.
//  Copyright © 2018 Silas. All rights reserved.
//

import SpriteKit
//import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {

    // Global class/game objects
    var backgroundManager = BackgroundManager()
    var audioManager = AudioManager()
    var player = Player()
    var enemy = Enemy()
    var timerEnemy = Timer()
    
    // Define collider masks
    struct PhysicsBodyMasks {
        // Player objects
        let playerMask:         UInt32  = 0b1       // binary 1
        let playerBulletMask:   UInt32  = 0b10      // binary 2
        
        // Enemy objects
        let enemyMask:          UInt32  = 0b100     // binary 4
        let enemyBulletMask:    UInt32  = 0b1000    // binary 8
        
        // Empty object
        let emptyMask:          UInt32  = 0b10000   // binary 16
    }
    
    var physicsBodyMask = PhysicsBodyMasks()
    
    override func didMove(to view: SKView) {
        
        // Set physics behavior
        // default: self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        
        // Set contact delegate
        self.physicsWorld.contactDelegate = self

        // Background
        backgroundManager.initBackground(gameInstance: self) // Pass as GameScene
        
        // AudioManager
        audioManager.initAudioFiles()
        audioManager.playBackgroundMusic()
        
        // Player
        player.initPlayer(
            gameInstance: self,
            physicsMaskPlayer: physicsBodyMask.playerBulletMask,    // PlayerCollisionMask
            physicsMaskEnemy: physicsBodyMask.enemyMask,            // EnemyCollisionMask
            physicalMaskEmpty: physicsBodyMask.emptyMask            // EmptyCollisionMask
        )
        
        // Enemies
        // https://stackoverflow.com/questions/40613556/timer-scheduledtimer-does-not-work-in-swift-3
        timerEnemy = Timer.scheduledTimer(withTimeInterval: 2, repeats: true){
            
            //"[weak self]" creates a "capture group" for timer
            [weak self] timer in
            
            //Add a guard statement to bail out of the timer code
            //if the object has been freed.
            guard let strongSelf = self else {
                return
            }
            // Spawn enemies
            strongSelf.enemy.addEnemy(
                gameInstance: strongSelf,
                physicsMaskPlayerBullet: strongSelf.physicsBodyMask.playerBulletMask,   // PlayerBulletCollisionMask
                physicsMaskEnemy: strongSelf.physicsBodyMask.enemyMask,                 // EnemyCollisionMask
                physicsMaskEmpty: strongSelf.physicsBodyMask.emptyMask,                 // EmptyCollisionMask
                physicsMaskPlayer: strongSelf.physicsBodyMask.playerMask                // PlayerCollisionMask
            )
        }
    }
    
    var foo : Int = 0
    func didBegin(_ contact: SKPhysicsContact) {
        foo = foo + 1
        print("kontakt" + String(foo))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            player.playerNode.position.x = touch.location(in: self).x
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let locationUser = touch.location(in: self)
            
            if atPoint(locationUser) == player.playerNode {
                // Add player shots
                player.addBullet(
                    gameInstance: self,                                         // Game instance
                    audioManagerInstance: audioManager,                         // AudioManager instance
                    physicsMaskPlayerBullet: physicsBodyMask.playerBulletMask,  // PlayerCollisionMask
                    physicsMaskEnemy: physicsBodyMask.enemyMask,                // EnemyCollisionMask
                    physicsMaskEmpty: physicsBodyMask.emptyMask                 // EmptyCollisionMask
                )
            }
        }
        
    }
    
    // Gameloop
    override func update(_ currentTime: TimeInterval) {
        
        // Update background
        backgroundManager.updateBackground()
        
    }
    
    
    // Global access to game instance
    // https://stackoverflow.com/questions/29809643/how-to-make-a-global-variable-that-uses-self-in-swift
    //class var sharedInstance: GameScene {
      //  return _SingletonSharedInstance
    //}
    
}

// Global access to game instance --> not working T_T
//private let _SingletonSharedInstance = GameScene()

