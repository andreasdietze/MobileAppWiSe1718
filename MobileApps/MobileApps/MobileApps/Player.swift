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
    
    var isPlayerAlive: Bool = true
    
    // Player object --> With ! u know the var now has no state but will have one before its first call.
    // The problem is that there is no access to any specific funcs/vars before init and return
    //var player: SKSpriteNode!
    var playerNode: SKSpriteNode = SKSpriteNode()  // Works -> empty node
    
    // Shot texture
    let bulletTexture = SKTexture(imageNamed: "bullet")
    
    // Shot node
    var bulletNode: SKSpriteNode = SKSpriteNode()
    
    // Life count
    var lifeCount: Int = 4
    
    // Start parameters for the player
    func initPlayer(
            gameInstance: GameScene,
            physicsMaskPlayer: UInt32,
            physicsMaskEnemy: UInt32,
            physicalMaskEmpty: UInt32,
            physicsMaskAsteroid: UInt32
        ){
        
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
        
        // Is body dynamic ?
        //playerNode.physicsBody?.isDynamic = false
        
        // Friction affected body ?
        //playerNode.physicsBody?.friction = 0
        
        // Do not change player direction on collision with asteroids
        playerNode.physicsBody?.allowsRotation = false

        // Set physicsBitMask: defines the category to which this body belongs to
        playerNode.physicsBody?.categoryBitMask = physicsMaskPlayer
        
        // Set collisionBitMask: defines the categories that can collide with this body (disable to have no tranfsormation affects)
        playerNode.physicsBody?.collisionBitMask = physicsMaskAsteroid // 0
        
        // Set contanctBitMask: defines which bodies causes intersection notifications with this body
        playerNode.physicsBody?.contactTestBitMask = physicsMaskEnemy
        
        // Set player name
        playerNode.name = "ship"
        
        // Add to scene
        gameInstance.addChild(playerNode)
        
        // Init player life
        setPlayerLifeCount(lifeCount: lifeCount, gameInstance: gameInstance)
        
    }
    
    func addBullet(
            gameInstance: GameScene,
            audioManagerInstance: AudioManager,
            physicsMaskPlayerBullet: UInt32,
            physicsMaskEnemy: UInt32,
            physicsMaskEmpty: UInt32
        ) {
        
        // Initiate shot node
        bulletNode = SKSpriteNode(texture: bulletTexture)
        
        // Set position relative to player
        bulletNode.position = playerNode.position
        
        // Set z-index
        bulletNode.zPosition = 0
        
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
        
        bulletNode.name = "bullet"
        
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
    
    // Set player life cound
    func setPlayerLifeCount(lifeCount: Int, gameInstance: GameScene){
        
        // For every spriteNode
        for index in 0...lifeCount - 1 {
            // Define the node
            let lifeNode = SKSpriteNode(imageNamed: "live")
            
            // Set name
            lifeNode.name = "live" + String(index)
            
            // Place the nodes
            lifeNode.anchorPoint = CGPoint(x: 0, y:0)
            lifeNode.position.x = CGFloat(index) * lifeNode.size.width
            lifeNode.position.y = gameInstance.size.height - lifeNode.size.height
            
            // Scale
            lifeNode.setScale(0.75)
            
            // Z-Index: over all other objects
            lifeNode.zPosition = 3
            
            // Add to scene
            gameInstance.addChild(lifeNode)
        }
    }
    
    // Increase player life count by one
    public func increaseLifeCount(gameInstance: GameScene){
        if lifeCount < 4 {
            let lifeNode = SKSpriteNode(imageNamed: "live")
            lifeNode.name = "live" + String(lifeCount)
            lifeNode.anchorPoint = CGPoint(x: 0, y: 0)
            lifeNode.position.x = CGFloat(lifeCount) * lifeNode.size.width
            lifeNode.position.y = gameInstance.size.height - lifeNode.size.height
            lifeNode.setScale(0.75)
            lifeNode.zPosition = 3
            gameInstance.addChild(lifeNode)
            lifeCount += 1
        }
    }
    
    // Decrease player life count by one
    public func decreaseLifeCount(gameInstance: GameScene){
        // If player hits an enemy
        if lifeCount > 0 {
            lifeCount = lifeCount - 1
        }
        
        // Set player dead if life count is zero
        if lifeCount == 0 {
            isPlayerAlive = false
        }
        
        let deleteNode = gameInstance.childNode(withName: "live" + String(lifeCount))
        deleteNode?.removeFromParent()
        
    }
    
    // Kill the player instant
    public func killPlayer(gameInstance: GameScene, playerNode: SKSpriteNode){
        // For every life
        for index in 0...lifeCount {
            // Delete it
            let deleteNode = gameInstance.childNode(withName: "live" + String(index))
            deleteNode?.removeFromParent()
        }
        
        // Set player dead
        isPlayerAlive = false
        
        // Delete player node
        // playerNode.removeFromParent() //sieht schöner aus ohne den node zu deleten
    }
    
    
}
