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
            physicsMaskPlayer: physicsBodyMask.playerMask,  // PlayerCollisionMask
            physicsMaskEnemy: physicsBodyMask.enemyMask,    // EnemyCollisionMask
            physicalMaskEmpty: physicsBodyMask.emptyMask    // EmptyCollisionMask
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
            
            strongSelf.enemy.addEnemySheet(
                gameInstance: strongSelf,
                physicsMaskPlayerBullet: strongSelf.physicsBodyMask.playerBulletMask,   // PlayerBulletCollisionMask
                physicsMaskEnemy: strongSelf.physicsBodyMask.enemyMask,                 // EnemyCollisionMask
                physicsMaskEmpty: strongSelf.physicsBodyMask.emptyMask,                 // EmptyCollisionMask
                physicsMaskPlayer: strongSelf.physicsBodyMask.playerMask                // PlayerCollisionMask
                
            )
            
            //strongSelf.enemy.addEnemyExplosionSheet(gameInstance: strongSelf, enemyPosition: CGPoint(x: 100, y: 100))
        }
    }
    
    func getContactPlayerBulletWithEnemy(playerBulletNode: SKSpriteNode, enemyNode: SKSpriteNode){
        
        // Remove bullet
        playerBulletNode.removeFromParent()
        
        // Trigger explosion sound
        audioManager.playExplosionOneSKAction(gameInstance: self)
        
        // Trigger explosion (only one time)
        if enemy.contactBegin {
            enemy.addEnemyExplosionSheet(gameInstance: self, enemyPosition: enemyNode.position)
            enemy.contactBegin = false
        }
        
        // Remove enemy
        enemyNode.removeFromParent()
    }
    
    func getContactPlayerWithEnemy(playerNode: SKSpriteNode, enemyNode: SKSpriteNode){
        // Trigger explosion sound
        audioManager.playExplosionOneSKAction(gameInstance: self)
        
        // Trigger explosion
        if enemy.contactBegin {
            enemy.addEnemyExplosionSheet(gameInstance: self, enemyPosition: enemyNode.position)
            enemy.contactBegin = false
        }

        // Remove bodyB
        enemyNode.removeFromParent()
        
        // -------- Player Stuff -------- //
        
        // Start player got hit / respawn action
        playerNode.run(
            // Repeat action
            SKAction.repeat(
                // Start sequence action
                SKAction.sequence(
                    // Sequence array content
                    [
                        SKAction.fadeAlpha(
                            to: 0.1,
                            duration: 0.1
                        ),
                        SKAction.fadeAlpha(
                            to: 1.0,
                            duration: 0.1
                        )
                    ]
                ),
                count: 10   // Repeat 10 times
            )
        )
        
        // Decrease player life count
        player.decreaseLifeCount(gameInstance: self)
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch contactMask {
        // PlayerBullet collide with enemy
        case physicsBodyMask.playerBulletMask | physicsBodyMask.enemyMask :
            
            // Check if nodes are available, catch otherwise
            guard let nodeA = contact.bodyA.node else {
                print("Node A not found")
                return
            }
            
            guard let nodeB = contact.bodyB.node else {
                print("Node B not found")
                return
            }
            
            // Collision occur for sure
           // print("Collision: PlayerBullet collide with Enemy")
            
            // BodyA: enemy with mask 4
            //print("Mask of A: " + String(contact.bodyA.categoryBitMask))
            
            // BodyB: playerBullet with mask 2
           // print("Mask of B: " + String(contact.bodyB.categoryBitMask))

            // Handle collision
            getContactPlayerBulletWithEnemy(
                playerBulletNode: nodeB as! SKSpriteNode,   // Cast to SKSPriteNode
                enemyNode: nodeA as! SKSpriteNode           // Cast to SKSPriteNode
            )
            break
            
        // Player collide with enemy
        case physicsBodyMask.playerMask | physicsBodyMask.enemyMask :
            // Check if nodes are available, catch otherwise
            guard let nodeA = contact.bodyA.node else {
                print("Node A not found")
                return
            }
            
            guard let nodeB = contact.bodyB.node else {
                print("Node B not found")
                return
            }
            
            // Collision occur for sure
            //print("Collision: Player collide with Enemy")
            
            // BodyA: player with mask 1
           // print("Mask of A: " + String(contact.bodyA.categoryBitMask))

            // BodyB: enemy with mask 4
           // print("Mask of B: " + String(contact.bodyB.categoryBitMask))
            
            // Handle collision
            getContactPlayerWithEnemy(
                playerNode: nodeA as! SKSpriteNode, // Cast to SKSPriteNode
                enemyNode: nodeB as! SKSpriteNode   // Cast to SKSPriteNode
            )
            break
            
        default:
            break
        }
    }
    
    // Wird komischerweise nicht aufgerufen ????
    func didEnd(_ contact: SKPhysicsContact) {
        
        print("Contact finished")
        
        if contact.bodyA.node?.name == "bullet" || contact.bodyB.node?.name == "bullet"
        || contact.bodyA.node?.name == "ship"   || contact.bodyB.node?.name == "ship" {
            enemy.contactBegin = true
             print("Contact finished")
            
        }
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

