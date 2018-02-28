//
//  GhostManager.swift
//  MobileApps
//
//  Created by Bambi on 28.02.18.
//  Copyright © 2018 Silas. All rights reserved.
//

import Foundation
import SpriteKit

// Due to the sprite-edge-collision-shape a ghost has to have the same shape as the object the ghost stalks
class GhostManager {
    
    // Explode only one time
    var contactBegin: Bool = true
    
    // Enemy texture
    let ghostTexture = SKTexture(imageNamed: "bluedestroyer")
    
    // Ghost collider identifier
    let ghostColliderName = "blueGhost"
    
    // Enemy object
    var ghostNode: SKSpriteNode = SKSpriteNode()
    
    // Enemy explosion texture sheet
    let enemyExplosionTextureSheet = SKTexture(imageNamed: "galaxy_0")
    
    // Enemy explosion object sheet
    var enemyExplosionNode: SKSpriteNode = SKSpriteNode()
    
    // Enemy explosion scale
    let enemyExplosionScale: CGFloat = 1
    
    // Start parameters for the ghost (no masks needed, collsion handling within didEnd() in GameScene)
    func addGhost(gameInstance: GameScene, enemy: Enemy){
        
        // Set state of the ghost
        ghostNode = SKSpriteNode(texture: ghostTexture)
        
        // Set ghost start to enemy start position
        ghostNode.position = enemy.enemyNode.position

        // Set scale from the object to stalk
        ghostNode.setScale(enemy.enemyNodeScale)
        
        // Set enemy rotation (rotate 270 deg)
        ghostNode.zRotation = CGFloat((CGFloat.pi / 180) * 270)
        
        // Set z-index
        ghostNode.zPosition = 1
        
        // Collider - Shape
        ghostNode.physicsBody = SKPhysicsBody(
            texture: ghostTexture,
            size: CGSize(
                width: ghostTexture.size().width * enemy.enemyNodeScale,
                height: ghostTexture.size().height * enemy.enemyNodeScale
            )
        )
        
        // Gravity behavior: no gravity
        ghostNode.physicsBody?.affectedByGravity = false
        //ghostNode.physicsBody?.isDynamic = false
        
        // Set physicsBitMask - isDynamic = false !!! -> no auto collision handling
        ghostNode.physicsBody?.categoryBitMask = 0b10000001 // defines the category to which this physics body belongs to
        
        // Collision will occur when enemy hits empty, playerbullet or player
        ghostNode.physicsBody?.collisionBitMask = 0  // defines the categories that can collide with this body
        
        // ContactEvent with bullet and player
        ghostNode.physicsBody?.contactTestBitMask = 0b10 //| physicsMaskPlayer // defines which bodies causes intersection notifications with this body
        
        ghostNode.name = ghostColliderName
        
        // Add to scene
        gameInstance.addChild(ghostNode)
        
        // Action - transformation
        let moveDown = SKAction.moveTo(y: -ghostNode.size.height, duration: 10)
        
        // Action - delete
        let delete = SKAction.removeFromParent()
        
        // Action - sequence
        ghostNode.run(SKAction.sequence([moveDown, delete]))
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
        gameInstance.run(SKAction.wait(forDuration: 2.0)) {
            self.enemyExplosionNode.removeFromParent()
            self.contactBegin = true
        }
    }
    
}
