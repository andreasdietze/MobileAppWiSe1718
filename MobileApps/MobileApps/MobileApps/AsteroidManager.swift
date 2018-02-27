//
//  AsteroidManager.swift
//  MobileApps
//
//  Created by Bambi on 26.02.18.
//  Copyright © 2018 Silas. All rights reserved.
//

import Foundation
import SpriteKit

class AsteroidManager {
    // ProtoStar texture sheet
    var asteroidTexture: SKTexture = SKTexture()
    
    // ProtoStar object with sprite sheet
    var asteroidNode: SKSpriteNode = SKSpriteNode()
    
    // ProtoStar sprite sheet scale
    var asteroidNodeScale: CGFloat = 0.25
    
    // Create proto star object
    func addAsteroid(
        gameInstance: GameScene,
        physicsMaskPlayerBullet: UInt32,
        physicsMaskEnemy: UInt32,
        physicsMaskEmpty: UInt32,
        physicsMaskPlayer: UInt32,
        physicsMaskAsteroid: UInt32
        ){
 
        // Random texture (4 available)
        let texRND = arc4random_uniform(65536) % 4
        if texRND == 0 {
            asteroidTexture = SKTexture(imageNamed: "aestroid_brown")
        }
        
        if texRND == 1 {
            asteroidTexture = SKTexture(imageNamed: "aestroid_gray")
        }
        
        if texRND == 2 {
            asteroidTexture = SKTexture(imageNamed: "aestroid_dark")
        }
        
        if texRND == 3 {
            asteroidTexture = SKTexture(imageNamed: "aestroid_gay_2")
        }
        
        // Set root texture
        asteroidNode = SKSpriteNode(texture: asteroidTexture)
        
        // Set random scale between 0.05 and 0.25
        let lowerScale : UInt32 = 5
        let upperScale : UInt32 = 25
        let scale : UInt32 = arc4random_uniform(upperScale - lowerScale) + lowerScale
        asteroidNodeScale = CGFloat(scale) / 100
        asteroidNode.setScale(asteroidNodeScale)
        
        // Set random spwan location on x-axis, y: client height + tex height
        asteroidNode.position = CGPoint(
            x: CGFloat(arc4random_uniform(UInt32(gameInstance.size.width))),
            y: gameInstance.size.height + asteroidNode.size.height
        )
        
        // Set asteroid rotation random between 0 and 359
        asteroidNode.zRotation = CGFloat((CGFloat.pi / 180) * (CGFloat(arc4random_uniform(65536) % 359)))
        
        // Set z-index
        asteroidNode.zPosition = 1
        
        // Collider - Shape
        asteroidNode.physicsBody = SKPhysicsBody(
            texture: asteroidTexture,
            size: CGSize(
                width: asteroidTexture.size().width * asteroidNodeScale,
                height: asteroidTexture.size().height * asteroidNodeScale
            )
        )
        
        // Gravity behavior: no gravity
        asteroidNode.physicsBody?.affectedByGravity = false
        
        // Set physicsBitMask
        asteroidNode.physicsBody?.categoryBitMask = physicsMaskAsteroid
        
        // No physical collision handling
        asteroidNode.physicsBody?.collisionBitMask = physicsMaskAsteroid | physicsMaskPlayer
        
        // ContactEvent with bullet and player
        asteroidNode.physicsBody?.contactTestBitMask =  physicsMaskPlayerBullet | physicsMaskPlayer | physicsMaskAsteroid
        
        // Set name
        asteroidNode.name = "asteroid"
        
        // Add to scene
        gameInstance.addChild(asteroidNode)
        
        // Action - transformation: random speed
        let lower : UInt32 = 5
        let upper : UInt32 = 20
        let duration : UInt32 = arc4random_uniform(upper - lower) + lower // 5 - 20
        let moveDown = SKAction.moveTo(y: -asteroidNode.size.height, duration: TimeInterval(duration))
        
        // Action - delete
        let delete = SKAction.removeFromParent()
        
        // Action - sequence
        asteroidNode.run(SKAction.sequence([moveDown, delete]))
        
    }
}
