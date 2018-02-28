//
//  Enemy.swift
//  MobileApps
//
//  Created by Bambi on 23.02.18.
//  Copyright © 2018 Silas. All rights reserved.
//

import Foundation
import SpriteKit

class Enemy {
    
    // Explode only one time
    var contactBegin: Bool = true
    
    // Enemy texture
    let enemyTexture = SKTexture(imageNamed: "bluedestroyer")
    
    // Enemy object
    var enemyNode: SKSpriteNode = SKSpriteNode()
    
    // Enemy scale
    let enemyNodeScale: CGFloat = 0.125
    
    // Enemy texture sheet
    let enemyTextureSheet = SKTexture(imageNamed: "spaceship_enemy_start")
    
    // Enemy object with sprite sheet
    var enemyNodeSheet: SKSpriteNode = SKSpriteNode()
    
    // Enemy sprite sheet scale
    let enemyNodeSheetScale: CGFloat = 0.125
    
    // Enemy explosion texture sheet
    let enemyExplosionTextureSheet = SKTexture(imageNamed: "galaxy_0")
    
    // Enemy explosion object sheet
    var enemyExplosionNode: SKSpriteNode = SKSpriteNode()
    
    // Enemy explosion scale
    let enemyExplosionScale: CGFloat = 1
    
    // Start parameters for the player
    @objc func addEnemy(gameInstance: GameScene, physicsMaskPlayerBullet: UInt32, physicsMaskEnemy: UInt32, physicsMaskEmpty: UInt32, physicsMaskPlayer: UInt32){
        
        // Set state of the enemy
        enemyNode = SKSpriteNode(texture: enemyTexture) //(imageNamed: enemyTexture)
        
        // Set enemy start position: x:random within client view, y: top of client view + texture height
        enemyNode.position = CGPoint(
            x: CGFloat(arc4random_uniform(UInt32(gameInstance.size.width))),
            y: gameInstance.size.height + enemyNode.size.height
        )
        
        // Set enemy scale
        enemyNode.setScale(enemyNodeScale)
        
        // Set enemy rotation (rotate 270 deg)
        enemyNode.zRotation = CGFloat((CGFloat.pi / 180) * 270)
        
        // Set z-index
        enemyNode.zPosition = 1
        
        // Collider - Rectangle
        /*enemyNode.physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(
                width: enemyNode.size.width, // / 2,
                height: enemyNode.size.height // / 2
            )
        )*/
        
        // Collider - Shape
        enemyNode.physicsBody = SKPhysicsBody(
            texture: enemyTexture,
            size: CGSize(
                width: enemyTexture.size().width * enemyNodeScale,
                height: enemyTexture.size().height * enemyNodeScale
            )
        )
        
        // Gravity behavior: no gravity
        enemyNode.physicsBody?.affectedByGravity = false
        //enemyNode.physicsBody?.isDynamic = false
        
        // Set physicsBitMask - isDynamic = false !!! -> no auto collision handling
        enemyNode.physicsBody?.categoryBitMask = physicsMaskEnemy // defines the category to which this physics body belongs to
        
        // Collision will occur when enemy hits empty, playerbullet or player
        enemyNode.physicsBody?.collisionBitMask = 0  // defines the categories that can collide with this body
        
        // ContactEvent with bullet and player
        enemyNode.physicsBody?.contactTestBitMask =  physicsMaskPlayerBullet //| physicsMaskPlayer // defines which bodies causes intersection notifications with this body
        
        // Add to scene
        gameInstance.addChild(enemyNode)
        
        // Action - transformation
        let moveDown = SKAction.moveTo(y: -enemyNode.size.height, duration: 10)
        
        // Action - delete
        let delete = SKAction.removeFromParent()
        
        // Action - sequence
        enemyNode.run(SKAction.sequence([moveDown, delete]))
    }
    
    func addEnemySheet(gameInstance: GameScene, physicsMaskPlayerBullet: UInt32, physicsMaskEnemy: UInt32, physicsMaskEmpty: UInt32, physicsMaskPlayer: UInt32){
        // TextureSheet-Array
        var enemyArray = [SKTexture]()
        
        // Append textures to array
        for index in 1...8 {
            enemyArray.append(SKTexture(imageNamed: "\(index)"))
        }
        
        // Set root texture
        enemyNodeSheet = SKSpriteNode(texture: enemyTextureSheet)
        
        // Set Scale
        enemyNodeSheet.setScale(enemyNodeSheetScale)
        
        // Set random spwan location on x-axis, y: client height + tex height
        enemyNodeSheet.position = CGPoint(
            x: CGFloat(arc4random_uniform(UInt32(gameInstance.size.width))),
            y: gameInstance.size.height + enemyNodeSheet.size.height
        )
        
        // Set enemy rotation (rotate 180 deg)
        enemyNodeSheet.zRotation = CGFloat((CGFloat.pi / 180) * 180)
        
        // Set z-index
        enemyNodeSheet.zPosition = 1
        
        // Collider - Shape
        enemyNodeSheet.physicsBody = SKPhysicsBody(
            texture: enemyTextureSheet,
            size: CGSize(
                width: enemyTextureSheet.size().width * enemyNodeSheetScale,
                height: enemyTextureSheet.size().height * enemyNodeSheetScale
            )
        )
        
        // Gravity behavior: no gravity
        enemyNodeSheet.physicsBody?.affectedByGravity = false
        
        // Set physicsBitMask
        enemyNodeSheet.physicsBody?.categoryBitMask = physicsMaskEnemy
        
        // No physical collision handling
        enemyNodeSheet.physicsBody?.collisionBitMask = 0
        
        // ContactEvent with bullet and player
        enemyNodeSheet.physicsBody?.contactTestBitMask =  physicsMaskPlayerBullet
        
        // Add to scene
        gameInstance.addChild(enemyNodeSheet)
        
        // Action - SpriteSheet
        enemyNodeSheet.run(SKAction.repeatForever(SKAction.animate(with: enemyArray, timePerFrame: 0.1)))
        
        // Action - transformation
        let moveDown = SKAction.moveTo(y: -enemyNodeSheet.size.height, duration: 10)
        
        // Action - delete
        let delete = SKAction.removeFromParent()
        
        // Action - sequence
        enemyNodeSheet.run(SKAction.sequence([moveDown, delete]))
        
    }
    
    func addEnemyExplosionSheet(gameInstance: GameScene, enemyPosition: CGPoint){
        // TextureSheet-Array
        var explosionArray = [SKTexture]()
        
        // Append textures to array
        for index in 1...16 {
            explosionArray.append(SKTexture(imageNamed: "galaxy_" + "\(index)"))
        }
        
        // Set root texture
        enemyExplosionNode = SKSpriteNode(texture: enemyExplosionTextureSheet)
        
        // Set Scale
        enemyExplosionNode.setScale(enemyExplosionScale)
        
        // Set random spwan location on x-axis, y: client height + tex height
        enemyExplosionNode.position = enemyPosition
        
        // Set z-index
        enemyExplosionNode.zPosition = 2
        
        // Add to scene
        gameInstance.addChild(enemyExplosionNode)
        
        // Action - SpriteSheet
        enemyExplosionNode.run(SKAction.repeatForever(SKAction.animate(with: explosionArray, timePerFrame: 0.1)))
        
        // Remove node when explosion animation has expired
        gameInstance.run(SKAction.wait(forDuration: 1.7)) {
            self.enemyExplosionNode.removeFromParent()
            self.contactBegin = true
        }
        
        gameInstance.run(SKAction.wait(forDuration: 0.1)) {
            //self.contactBegin = true
        }
    }
}
