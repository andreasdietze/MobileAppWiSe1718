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
    
    // Enemy texture
    let enemyTexture = SKTexture(imageNamed: "bluedestroyer")
    
    // Enemy object
    var enemyNode: SKSpriteNode = SKSpriteNode()
    
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
        enemyNode.setScale(0.25)
        
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
                width: enemyTexture.size().width / 4,
                height: enemyTexture.size().height / 4
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
        let delete = SKAction.removeFromParent()
        enemyNode.run(SKAction.sequence([moveDown, delete]))
    }
}
