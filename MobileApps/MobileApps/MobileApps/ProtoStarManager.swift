//
//  ProtoStarManager.swift
//  MobileApps
//
//  Created by Bambi on 26.02.18.
//  Copyright © 2018 Silas. All rights reserved.
//

import Foundation
import SpriteKit

class ProtoStarManager {
    
    // ProtoStar texture sheet
    let protoStarTexture = SKTexture(imageNamed: "p_Sprite_0")
    
    // ProtoStar object with sprite sheet
    var protoStarNode: SKSpriteNode = SKSpriteNode()
    
    // ProtoStar sprite sheet scale
    let protoStarNodeScale: CGFloat = 0.5
    
    // Create proto star object
    func addProtoStar(
            gameInstance: GameScene,
            physicsMaskPlayerBullet: UInt32,
            physicsMaskEnemy: UInt32,
            physicsMaskEmpty: UInt32,
            physicsMaskPlayer: UInt32,
            physicsMaskProtoStar: UInt32
        ){
        // TextureSheet-Array
        var protoStarArray = [SKTexture]()
        
        // Append textures to array
        for index in 1...14 {
            protoStarArray.append(SKTexture(imageNamed: "p_Sprite_" + "\(index)"))
        }
        
        // Set root texture
        protoStarNode = SKSpriteNode(texture: protoStarTexture)
        
        // Set Scale
        protoStarNode.setScale(protoStarNodeScale)
        
        // Set random spwan location on x-axis, y: client height + tex height
        protoStarNode.position = CGPoint(
            x: CGFloat(arc4random_uniform(UInt32(gameInstance.size.width))),
            y: gameInstance.size.height + protoStarNode.size.height
        )
        
        // Set proto star rotation (rotate 180 deg)
        protoStarNode.zRotation = CGFloat((CGFloat.pi / 180) * 180)
        
        // Set z-index
        protoStarNode.zPosition = 1
        
        // Collider - Shape
        protoStarNode.physicsBody = SKPhysicsBody(
            texture: protoStarTexture,
            size: CGSize(
                width: protoStarTexture.size().width * protoStarNodeScale,
                height: protoStarTexture.size().height * protoStarNodeScale
            )
        )
        
        // Gravity behavior: no gravity
        protoStarNode.physicsBody?.affectedByGravity = false
        
        // Set physicsBitMask
        protoStarNode.physicsBody?.categoryBitMask = physicsMaskProtoStar
        
        // No physical collision handling
        protoStarNode.physicsBody?.collisionBitMask = 0
        
        // ContactEvent with bullet and player
        protoStarNode.physicsBody?.contactTestBitMask =  physicsMaskPlayerBullet | physicsMaskPlayer
        
        // Set name
        protoStarNode.name = "protoStar"
        
        // Add to scene
        gameInstance.addChild(protoStarNode)
        
        // Action - SpriteSheet
        protoStarNode.run(SKAction.repeatForever(SKAction.animate(with: protoStarArray, timePerFrame: 0.1)))
        
        // Action - transformation
        let moveDown = SKAction.moveTo(y: -protoStarNode.size.height, duration: 10)
        
        // Action - delete
        let delete = SKAction.removeFromParent()
        
        // Action - sequence
        protoStarNode.run(SKAction.sequence([moveDown, delete]))
        
    }
    
}
