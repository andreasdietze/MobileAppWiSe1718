//
//  Health.swift
//  MobileApps
//
//  Created by Silas on 28.02.18.
//  Copyright © 2018 Silas. All rights reserved.
//

import Foundation
import SpriteKit

class Health {
    
    var contactBegin: Bool = true
    
    // Health texture
    let healthTexture = SKTexture(imageNamed: "health2")
    
    // 2. Health texture
    let healthTexture2 = SKTexture(imageNamed: "health1")
    
    // Health object
    var healthNode: SKSpriteNode = SKSpriteNode()
    
    var healthNode2: SKSpriteNode = SKSpriteNode()
    
    // scale
    let healthNodeScale: CGFloat = 0.16
    let healthNodeScale2: CGFloat = 0.25
    
    @objc func addHealth(gameInstance: GameScene,
                         physicsMaskHealth: UInt32,
                         physicsMaskPlayer: UInt32,
                         physicsMaskEmpty: UInt32) {
        
        // Set state of the health
        healthNode.name = "health"
        
        healthNode = SKSpriteNode(texture: healthTexture)
        healthNode2 = SKSpriteNode(texture: healthTexture2)
        
        // Set health start position: x:random within client view, y: top of client view + texture height
        let rnd = CGFloat(arc4random_uniform(UInt32(gameInstance.size.width)))
        healthNode.position = CGPoint(
            x: rnd,
            y: gameInstance.size.height + healthNode.size.height
        )
        healthNode2.position = CGPoint(
            x: rnd,
            y: gameInstance.size.height + healthNode2.size.height
        )
        
        // Set scale
        healthNode.setScale(healthNodeScale)
        healthNode2.setScale(healthNodeScale2)
        
        // Set rotation (rotate 270 deg)
        // healthNode.zRotation = CGFloat((CGFloat.pi / 180) * 270)
        
        // Set z-index
        healthNode.zPosition = 1
        healthNode2.zPosition = 1
        
        // Collider - Shape
        healthNode.physicsBody = SKPhysicsBody(
            texture: healthTexture,
            size: CGSize(
                width: healthTexture.size().width * healthNodeScale,
                height: healthTexture.size().height * healthNodeScale
            )
        )
        
        // Gravity behavior: no gravity
        healthNode.physicsBody?.affectedByGravity = false
        //enemyNode.physicsBody?.isDynamic = false
        
        // Set physicsBitMask - isDynamic = false !!! -> no auto collision handling
        healthNode.physicsBody?.categoryBitMask = physicsMaskHealth // defines the category to which this physics body belongs to
        
        // Collision will occur when enemy hits empty, playerbullet or player
        healthNode.physicsBody?.collisionBitMask = 0  // defines the categories that can collide with this body
        
        // ContactEvent with player
        healthNode.physicsBody?.contactTestBitMask =  physicsMaskPlayer //| physicsMaskPlayer // defines which bodies causes intersection notifications with this body
        
        // Add to scene
        gameInstance.addChild(healthNode)
        gameInstance.addChild(healthNode2)
        
        // Action - transformation
        let moveDown = SKAction.moveTo(y: -healthNode.size.height, duration: 10)
        
        let rotate = SKAction.rotate(byAngle: 6.28, duration: 1)
        let rotate2 = SKAction.rotate(byAngle: -6.28, duration: 2)
        
        let repeatRotation:SKAction = SKAction.repeatForever(rotate)
        let repeatRotation2:SKAction = SKAction.repeatForever(rotate2)
        
        // Action - delete
        let delete = SKAction.removeFromParent()
        
        // Action - sequence
        healthNode.run(repeatRotation)
        healthNode.run(SKAction.sequence([moveDown, delete]))
        healthNode2.run(repeatRotation2)
        healthNode2.run(SKAction.sequence([moveDown, delete]))
    }
}
