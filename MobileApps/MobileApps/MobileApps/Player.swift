//
//  Player.swift
//  MobileApps
//
//  Created by Bambi on 23.02.18.
//  Copyright © 2018 Silas. All rights reserved.
//

import Foundation
import SpriteKit

class Player {
    
    // Player texture
    let playerTexture = SKTexture(imageNamed: "ship") //"ship"
    
    // Player object --> With ! u know the var now has no state but will have one before its first call.
    // The problem is that there is no access to any specific funcs/vars before init and return
    //var player: SKSpriteNode!
    var playerNode: SKSpriteNode = SKSpriteNode()  // Works -> empty node
    
    // Shot texture
    let bulletTexture = SKTexture(imageNamed: "bullet")
    
    // Shot node
    var bulletNode: SKSpriteNode = SKSpriteNode()
    
    // Start parameters for the player
    func initPlayer(gameInstance: GameScene, physicsMaskPlayer: UInt32, physicsMaskEnemy: UInt32, physicalMaskEmpty: UInt32){
        
        // Set state of the player
        playerNode = SKSpriteNode(texture: playerTexture) //(imageNamed: playerTexture)
        
        // Set player start position
        playerNode.position = CGPoint(x: gameInstance.size.width / 2, y: gameInstance.size.height / 2 - 200)
        
        // Set player scale
        playerNode.setScale(0.25)
        
        // Set z-index
        playerNode.zPosition = 1
        
        // Collider - Circle
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: playerNode.size.width / 2)
        
        // Collider - Shape
        playerNode.physicsBody = SKPhysicsBody(
            texture: playerTexture,
            size: CGSize(
                width: playerTexture.size().width / 4,
                height: playerTexture.size().height / 4
            )
        )
        
        // Collision: https://stackoverflow.com/questions/31109659/how-does-collisionbitmask-work-swift-spritekit
        // Gravity behavior: no gravity
        playerNode.physicsBody?.affectedByGravity = false
        //playerNode.physicsBody?.isDynamic = false

        // Set physicsBitMask: defines the category to which this body belongs to
        playerNode.physicsBody?.categoryBitMask = physicsMaskPlayer
        
        // Set collisionBitMask: defines the categories that can collide with this body (disable to have no tranfsormation affects)
        playerNode.physicsBody?.collisionBitMask = 0
        
        // Set contanctBitMask: defines which bodies causes intersection notifications with this body
        playerNode.physicsBody?.contactTestBitMask = physicsMaskEnemy
        
        // Add to scene
        gameInstance.addChild(playerNode)
        
    }
    
    func addBullet(gameInstance: GameScene, audioManagerInstance: AudioManager, physicsMaskPlayerBullet: UInt32, physicsMaskEnemy: UInt32, physicsMaskEmpty: UInt32) {
        
        // Initiate shot node
        bulletNode = SKSpriteNode(texture: bulletTexture)
        
        // Set position relative to player
        bulletNode.position = playerNode.position
        
        // Set z-index
        bulletNode.zPosition = 1
        
        // Collider - Circle
        //bulletNode.physicsBody = SKPhysicsBody(circleOfRadius: bulletNode.size.width / 5)
        
        // Collider - Shape
        bulletNode.physicsBody = SKPhysicsBody(
            texture: bulletTexture,
            size: CGSize(
                width: bulletTexture.size().width / 4,
                height: bulletTexture.size().height / 4
            )
        )
        
        // Gravity behavior: not affected by gravity, not affected by other forces
        bulletNode.physicsBody?.isDynamic = false
        //bulletNode.physicsBody?.affectedByGravity = false
        
        // Set physicsBitMask - isDynamic = false !!! -> no auto collision handling
        bulletNode.physicsBody?.categoryBitMask = physicsMaskPlayerBullet
        
        bulletNode.physicsBody?.collisionBitMask = 0
        
        bulletNode.physicsBody?.contactTestBitMask = physicsMaskEnemy
        
        
        // Add to scene
        gameInstance.addChild(bulletNode)
        
        // Set target position for the shot (when reached, the shot will be deleted)
        // Target position: client height + texture height
        let targetPositionY: CGFloat = gameInstance.size.height + bulletNode.size.height
        
        // Action - transformation
        let moveTo = SKAction.moveTo(
            y: targetPositionY,     // Target position
            duration: 3             // Transformation duration in seconds --> speed derivation
        )
        
        // Action - remove shot if its position is greater than the target position
        let delete = SKAction.removeFromParent()
        
        // Execute action sequence (I totally freak out Oo - what a nice Framework)
        bulletNode.run(SKAction.sequence([moveTo, delete]))
        
        // Action - sound
        audioManagerInstance.playPlayerShotSoundSKAction(bullet: bulletNode) // works very good (frequency)
        //audioManager.playPlayerShotSound() // works - low frequency
        
    }
}
