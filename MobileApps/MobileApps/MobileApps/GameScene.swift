//
//  GameScene.swift
//  MobileApps
//
//  Created by Silas on 05.02.18.
//  Copyright © 2018 Silas. All rights reserved.
//

import SpriteKit
import CoreMotion
//import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {

    // Global class/game objects
    var backgroundManager = BackgroundManager()
    var audioManager = AudioManager()
    var protoStarManager = ProtoStarManager()
    var asteroidManager = AsteroidManager()
    var player = Player()
    var enemy = Enemy()
    var health = Health()
    var highScoreLabel = SKLabelNode(fontNamed: "Arial")
    var currentScoreLabel = SKLabelNode(fontNamed: "Arial")
    var currentScore = 0
    var highScore = UserDefaults.standard.integer(forKey: "HIGHSCORE")
    var totalGameTime: Int = 0
    var motionManager = CMMotionManager()
    
    var gyroLevel = CGFloat(0)

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
        
        // ProtoStar
        let protoStarMask:      UInt32  = 0b100000  // binary 32
        
        // Asteroid
        let asteroidMask:       UInt32  = 0b1000000 // binary 64
        
        // Health
        let healthMask:         UInt32 = 128
        
    }
    
    // Define game stages
    struct Stages {
        static let stageOne:    UInt8 = 0
        static let stageTwo:    UInt8 = 1
        static let stageThree:  UInt8 = 2
        static let stageFour:   UInt8 = 3
    }
    
    // Five seconds pause between a change of a stage
    let switchToStageTwo: UInt32 = 33   // 2.5 * 10 + 2.5 + 5 rounded
    let switchToStageThree: UInt32 = 30
    let switchToStageFour: UInt32 = 45
    var switchTrigger: Bool = true
    
    // Stage one parameters : 2.5 * 10 + 5 = 30 sec --> start time for stage two
    var stageOneTrigger: Bool = true
    let stageOneStartTime: UInt32 = 5
    var timerStageOne = Timer()
    let stageOneSpawnDuration: Double = 2.5
    var enemyCountStageOne : Int = 0
    let enemyMaxCountStageOne : Int = 10
    
    // Stage two parameters : 2.5 * 5 = 12.5 + 5 = 18 sec + 30 sec = 48 sec
    var stageTwoTrigger: Bool = true
    let stageTwoStartTime: UInt32 = 30
    var timerStageTwo = Timer()
    let stageTwoSpawnDuration: Double = 2.5
    var enemyCountStageTwo : Int = 0
    let enemyMaxCountStageTwo : Int = 5
    
    // Stage three parameters : 2 * 10 = 20 + 48 = 68
    var stageThreeTrigger: Bool = true
    let stageThreeStartTime: UInt32 = 48
    var timerStageThree = Timer()
    let stageThreeSpawnDuration: Double = 2.5
    var enemyCountStageThree : Int = 0
    let enemyMaxCountStageThree : Int = 10
    
    // Stage four parameters : run forever
    var stageFourTrigger: Bool = true
    let stageFourStartTime: UInt32 = 68
    var timerStageFour = Timer()
    var timerEnemyStageFour = Timer()
    var stageFourHelper = 0
    
    // health timer
    var healthTimer = Timer()
    
    var physicsBodyMask = PhysicsBodyMasks()
    
    func gameTimer(){
        let wait: SKAction = SKAction.wait(forDuration: 1)
        let finishTimer: SKAction = SKAction.run {
            
            self.totalGameTime += 1
            
            //print(self.totalGameTime)
            
            self.gameTimer()
        }
        
        let seq: SKAction = SKAction.sequence([wait, finishTimer])
        self.run(seq)
    }

    //var gyroData: CMGyroData? { get }
    override func didMove(to view: SKView) {
        
        // Set update interval for gyro sensor
        motionManager.gyroUpdateInterval = 0.2
        
        // Triger sequential update (read data in func update)
        motionManager.startGyroUpdates()

        
        // GameTime in seconds
        self.gameTimer()
        
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
            physicsMaskPlayer: physicsBodyMask.playerMask,      // PlayerCollisionMask
            physicsMaskEnemy: physicsBodyMask.enemyMask,        // EnemyCollisionMask
            physicalMaskEmpty: physicsBodyMask.emptyMask,       // EmptyCollisionMask
            physicsMaskAsteroid: physicsBodyMask.asteroidMask   // AsteroidCollisionMask
        )
        
        // persistent Score
        highScoreLabel.fontSize = 20
        highScoreLabel.text = "Highscore: \(UserDefaults.standard.integer(forKey: "HIGHSCORE"))"
        highScoreLabel.zPosition = 3
        highScoreLabel.position = CGPoint(x: self.size.width - highScoreLabel.frame.size.width - 10, y: self.size.height - highScoreLabel.frame.size.height - 10)
        self.addChild(highScoreLabel)
        
        currentScoreLabel.fontSize = 20
        currentScoreLabel.text = "Score: \(currentScore)"
        currentScoreLabel.zPosition = 3
        currentScoreLabel.position = CGPoint(x: highScoreLabel.position.x, y: highScoreLabel.position.y - currentScoreLabel.frame.size.height - 10)
        self.addChild(currentScoreLabel)
        
        spawnHealthTimer()
    }
    
    func saveScore() {
        UserDefaults.standard.set(currentScore, forKey: "HIGHSCORE")
        highScoreLabel.text = "Highscore: \(UserDefaults.standard.integer(forKey: "HIGHSCORE"))"
    }
    
    func saveLastScore() {
        UserDefaults.standard.set(currentScore, forKey: "LASTSCORE")
    }
    
    // Handle player bullet - enemy collision
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
        
        currentScore += 1
        currentScoreLabel.text = "Score: \(currentScore)"
    }
    
    // Handle playerBullet - protoStar collision. Just remove the bullet, a proto star cannot be killed
    func getContactPlayerBulletWithProtoStar(playerBulletNode: SKSpriteNode, protoStarNode: SKSpriteNode){
        // If bodyA is the bullet, delte bodyA
        if playerBulletNode.name == "bullet" {
            playerBulletNode.removeFromParent()
        }
        
        // if bodyB is the bullet, delete bodyB
        if protoStarNode.name == "bullet" {
            protoStarNode.removeFromParent()
        }
    }
    
    // Handle playerBullet - asteroid collision. Just remove the bullet, a asteroid cannot be killed
    func getContactPlayerBulletWithAsteroid(playerBulletNode: SKSpriteNode, asteroidNode: SKSpriteNode) {
        // If bodyA is the bullet, delte bodyA
        if playerBulletNode.name == "bullet" {
            playerBulletNode.removeFromParent()
        }
        
        // if bodyB is the bullet, delete bodyB
        if asteroidNode.name == "bullet" {
            asteroidNode.removeFromParent()
        }
    }
    
    //Handle player - health collision
    func getContactPlayerWithHealth(playerNode: SKSpriteNode, healthNode: SKSpriteNode) {
        // audio
        audioManager.playHealthSound()
        
        // Trigger 1 up
        if health.contactBegin {
            player.increaseLifeCount(gameInstance: self)
            health.contactBegin = false
        }
        
        healthNode.removeFromParent()
    }
    
    // Handle player - enemy collision
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
    
    func getContactPlayerWithProtoStar(playerNode: SKSpriteNode, protoStarNode: SKSpriteNode){
        player.killPlayer(gameInstance: self, playerNode: playerNode)
        
        // TODO: End the game, go back to start menue
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
            //print("Mask of B: " + String(contact.bodyB.categoryBitMask))

            // Handle collision
            getContactPlayerBulletWithEnemy(
                playerBulletNode: nodeB as! SKSpriteNode,   // Cast to SKSPriteNode
                enemyNode: nodeA as! SKSpriteNode           // Cast to SKSPriteNode
            )
            break
            
    
        // PlayerBullet collide with protoStar
        case physicsBodyMask.playerBulletMask | physicsBodyMask.protoStarMask :
            
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
            // print("Collision: PlayerBullet collide with ProtoStar")
            
            // BodyA: protoStar with mask 32
            // print("Mask of A: " + String(contact.bodyA.categoryBitMask))
            
            // BodyB: playerBullet with mask 2
            // print("Mask of B: " + String(contact.bodyB.categoryBitMask))
            
            // Handle collision
            getContactPlayerBulletWithProtoStar(
                playerBulletNode: nodeB as! SKSpriteNode,   // Cast to SKSPriteNode
                protoStarNode: nodeA as! SKSpriteNode           // Cast to SKSPriteNode
            )
            break
            
        // PlayerBullet collide with asteroid
        case physicsBodyMask.playerBulletMask | physicsBodyMask.asteroidMask :
            
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
            // print("Collision: PlayerBullet collide with Asteroid")
            
            // BodyA: protoStar with mask 64
            // print("Mask of A: " + String(contact.bodyA.categoryBitMask))
            
            // BodyB: playerBullet with mask 2
            // print("Mask of B: " + String(contact.bodyB.categoryBitMask))
            
            // Handle collision
            getContactPlayerBulletWithAsteroid(
                playerBulletNode: nodeB as! SKSpriteNode,   // Cast to SKSPriteNode
                asteroidNode: nodeA as! SKSpriteNode        // Cast to SKSPriteNode
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
        // Player collide with health
        case physicsBodyMask.playerMask | physicsBodyMask.healthMask :
            
            // Check if nodes are available, catch otherwise
            guard let nodeA = contact.bodyA.node else {
                print("Node A not found")
                return
            }
            
            guard let nodeB = contact.bodyB.node else {
                print("Node B not found")
                return
            }
            
            // Handle collision
            getContactPlayerWithHealth(playerNode: nodeA as! SKSpriteNode,
                                       healthNode: nodeB as! SKSpriteNode
            )
            
            break
            
        // Player collide with enemy
        case physicsBodyMask.playerMask | physicsBodyMask.protoStarMask :
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
            //print("Collision: Player collide with ProtoStar")
            
            // BodyA: player with mask 1
            // print("Mask of A: " + String(contact.bodyA.categoryBitMask))
            
            // BodyB: enemy with mask 32
            // print("Mask of B: " + String(contact.bodyB.categoryBitMask))
            
            // Handle collision
            getContactPlayerWithProtoStar(
                playerNode: nodeA as! SKSpriteNode,     // Cast to SKSPriteNode
                protoStarNode: nodeB as! SKSpriteNode   // Cast to SKSPriteNode
            )
            break
            
        default:
            break
        }
    }
    
    // Wird komischerweise nicht aufgerufen ???? --> Wird aufgerufen, wenn für elemente kein case erstellt wurde (was zur ...)
    func didEnd(_ contact: SKPhysicsContact) {
        
        // print("Contact finished")
        
        if contact.bodyA.node?.name == "bullet" || contact.bodyB.node?.name == "bullet"
        || contact.bodyA.node?.name == "ship"   || contact.bodyB.node?.name == "ship" {
            enemy.contactBegin = true
             //print("Contact finished")
            
        }
        //if contact.bodyA.node?.name == "health" || contact.bodyB.node?.name == "health" {
        //    health.contactBegin = true
        //}
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            //player.playerNode.position.x = touch.location(in: self).x
            player.playerNodeSheet.position.x = touch.location(in: self).x
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let locationUser = touch.location(in: self)
            
            if atPoint(locationUser) == player.playerNodeSheet {
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
        
        if !player.isPlayerAlive {
            let transition = SKTransition.fade(withDuration: 4)
            let retry = Retry(size: self.size)
            audioManager.stopBackgroundMusic()
            self.view?.presentScene(retry, transition: transition)
        }
        // Update background
        backgroundManager.updateBackground()

        // Player collision with viewport (half size of texture bonus).
        // Player is not able to kill himself (mouse and touch) cause he never can reach
        // a position less/greater than the viewport minimum/maximum size in any direction
        // due to the anchor point is the center of the sprite.
        if  player.playerNodeSheet.position.x < 0 ||
            player.playerNodeSheet.position.y < 0 ||
            player.playerNodeSheet.position.x > self.size.width {
            // Kill player
            player.killPlayer(gameInstance: self, playerNode: player.playerNodeSheet)
        }
        
        // Score handling
        if currentScore > UserDefaults.standard.integer(forKey: "HIGHSCORE") {
            saveScore()
        }
        saveLastScore()
        
        // Spawn enemies for stage one (ships)
        if totalGameTime > stageOneStartTime && stageOneTrigger {
            //stageOne(repeats: true)
            spawnTimerStageOne()
            stageOneTrigger = false
        }
        
        // Spawn enemies for stage two (stars)
        if totalGameTime > stageTwoStartTime && stageTwoTrigger {
            //stageTwo(repeats: true)
            spawnTimerStageTwo()
            stageTwoTrigger = false
        }

        // Spawn enemies for stage three (asteroids)
        if totalGameTime > stageThreeStartTime && stageThreeTrigger {
            //stageThree(repeats: true)
            spawnTimerStageThree()
            stageThreeTrigger = false
        }
        
        
        // Spawn enemies for stage four (mixed)
        if totalGameTime > stageFourStartTime && stageFourTrigger {
            stageFour(repeats: true)
            stageFourTrigger = false
        }
        
        // hässlicher, aber effektiver workaround für life.increase-dosierungs-problem bei kollision mit health
        if totalGameTime % 4 == 0 {
            health.contactBegin = true
        }
        
        // If gyro-x is less than 0
        gyroLevel = CGFloat((motionManager.gyroData?.rotationRate.x)!) * 4
        if gyroLevel <= 0 {
            gyroLevel = 0 // set gyro value to 0
        }
        
        // Add only positive gyro-x values
        player.playerNodeSheet.position.y += gyroLevel
        
        // The boarder the player can boost to with gyro-x
        if player.playerNodeSheet.position.y >= self.size.height / 4 {
            player.playerNodeSheet.position.y = self.size.height / 4
        }
        
        
    }
    
    func spawnHealthTimer(){
        
        let wait: SKAction = SKAction.wait(forDuration: 24)
        let finishTimer: SKAction = SKAction.run {
            
            self.spawnHealth()
        }
        
        let seq: SKAction = SKAction.sequence([wait, finishTimer])
        self.run(seq)
        
    }
    
    func spawnHealth(){
        healthTimer = Timer.scheduledTimer(withTimeInterval: 16, repeats: true){
            
            //"[weak self]" creates a "capture group" for timer
            [weak self] timer in
            
            //Add a guard statement to bail out of the timer code
            //if the object has been freed.
            guard let strongSelf = self else {
                return
            }
            
            // spawn health
            
            strongSelf.health.addHealth(gameInstance: strongSelf,
                                        physicsMaskHealth: strongSelf.physicsBodyMask.healthMask,
                                        physicsMaskPlayer: strongSelf.physicsBodyMask.playerMask,
                                        physicsMaskEmpty: strongSelf.physicsBodyMask.emptyMask
            )
        }
    }
    
    func spawnTimerStageOne(){
        
        let wait: SKAction = SKAction.wait(forDuration: stageOneSpawnDuration)
        let finishTimer: SKAction = SKAction.run {
            self.enemyCountStageOne = self.enemyCountStageOne + 1
            
            self.stageOne(repeats: false)
            
            if self.enemyCountStageOne < self.enemyMaxCountStageOne {
                self.spawnTimerStageOne()
            }
        }
        
        let seq: SKAction = SKAction.sequence([wait, finishTimer])
        self.run(seq)
    }
    
    // Spawn enemies for 1. stage
    func stageOne(repeats: Bool) {
        
        timerStageOne = Timer.scheduledTimer(withTimeInterval: 0, repeats: repeats){
            
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
        }
    }

    func spawnTimerStageTwo(){
        
        let wait: SKAction = SKAction.wait(forDuration: stageTwoSpawnDuration)
        let finishTimer: SKAction = SKAction.run {
            self.enemyCountStageTwo = self.enemyCountStageTwo + 1
            
            self.stageTwo(repeats: false)
            
            if self.enemyCountStageTwo < self.enemyMaxCountStageTwo {
                self.spawnTimerStageTwo()
            }
        }
        
        let seq: SKAction = SKAction.sequence([wait, finishTimer])
        self.run(seq)
    }
    
    // Spawn enemies for 2. stage
    func stageTwo(repeats: Bool) {
        timerStageTwo = Timer.scheduledTimer(withTimeInterval: 0, repeats: repeats){
            
            //"[weak self]" creates a "capture group" for timer
            [weak self] timer in
            
            //Add a guard statement to bail out of the timer code
            //if the object has been freed.
            guard let strongSelf = self else {
                return
            }
            
            // Spawn proto stars
            strongSelf.protoStarManager.addProtoStar(
            gameInstance: strongSelf,
            physicsMaskPlayerBullet: strongSelf.physicsBodyMask.playerBulletMask,   // PlayerBulletCollisionMask
            physicsMaskEnemy: strongSelf.physicsBodyMask.enemyMask,                 // EnemyCollisionMask
            physicsMaskEmpty: strongSelf.physicsBodyMask.emptyMask,                 // EmptyCollisionMask
            physicsMaskPlayer: strongSelf.physicsBodyMask.playerMask,               // PlayerCollisionMask
            physicsMaskProtoStar: strongSelf.physicsBodyMask.protoStarMask          // ProtoStarCollsionMask
             
            )
        }
    }
    
    func spawnTimerStageThree(){
        
        let wait: SKAction = SKAction.wait(forDuration: stageThreeSpawnDuration)
        let finishTimer: SKAction = SKAction.run {
            self.enemyCountStageThree = self.enemyCountStageThree + 1
            
            self.stageThree(repeats: false)
            
            if self.enemyCountStageThree < self.enemyMaxCountStageThree {
                self.spawnTimerStageThree()
            }
        }
        
        let seq: SKAction = SKAction.sequence([wait, finishTimer])
        self.run(seq)
    }
    
    // Spawn enemies for 3. stage
    func stageThree(repeats: Bool) {
        timerStageThree = Timer.scheduledTimer(withTimeInterval: 2.4, repeats: repeats){
            
            //"[weak self]" creates a "capture group" for timer
            [weak self] timer in
            
            //Add a guard statement to bail out of the timer code
            //if the object has been freed.
            guard let strongSelf = self else {
                return
            }
            
            // Spawn proto stars
            strongSelf.asteroidManager.addAsteroid(
                gameInstance: strongSelf,
                physicsMaskPlayerBullet: strongSelf.physicsBodyMask.playerBulletMask,   // PlayerBulletCollisionMask
                physicsMaskEnemy: strongSelf.physicsBodyMask.enemyMask,                 // EnemyCollisionMask
                physicsMaskEmpty: strongSelf.physicsBodyMask.emptyMask,                 // EmptyCollisionMask
                physicsMaskPlayer: strongSelf.physicsBodyMask.playerMask,               // PlayerCollisionMask
                physicsMaskAsteroid: strongSelf.physicsBodyMask.asteroidMask            // ProtoStarCollsionMask
            )
        }
    }
    
    // Spawn enemies for 4. stage
    func stageFour (repeats: Bool) {
        // Enemies
        // https://stackoverflow.com/questions/40613556/timer-scheduledtimer-does-not-work-in-swift-3
        timerStageFour = Timer.scheduledTimer(withTimeInterval: 8, repeats: repeats){
            //"[weak self]" creates a "capture group" for timer
            [weak self] timer in
            
            //Add a guard statement to bail out of the timer code
            //if the object has been freed.
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.stageFourHelper += 1
            strongSelf.stageFourHelper %= 3
        }
        
        timerEnemyStageFour = Timer.scheduledTimer(withTimeInterval: 2.4, repeats: true){
            
            //"[weak self]" creates a "capture group" for timer
            [weak self] timer in
            
            //Add a guard statement to bail out of the timer code
            //if the object has been freed.
            guard let strongSelf = self else {
                return
            }
            
            switch(strongSelf.stageFourHelper){
            case 0:
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
            case 1:
                strongSelf.asteroidManager.addAsteroid(
                    gameInstance: strongSelf,
                    physicsMaskPlayerBullet: strongSelf.physicsBodyMask.playerBulletMask,   // PlayerBulletCollisionMask
                    physicsMaskEnemy: strongSelf.physicsBodyMask.enemyMask,                 // EnemyCollisionMask
                    physicsMaskEmpty: strongSelf.physicsBodyMask.emptyMask,                 // EmptyCollisionMask
                    physicsMaskPlayer: strongSelf.physicsBodyMask.playerMask,               // PlayerCollisionMask
                    physicsMaskAsteroid: strongSelf.physicsBodyMask.asteroidMask            // ProtoStarCollsionMask
                )
            case 2:
                strongSelf.protoStarManager.addProtoStar(
                    gameInstance: strongSelf,
                    physicsMaskPlayerBullet: strongSelf.physicsBodyMask.playerBulletMask,   // PlayerBulletCollisionMask
                    physicsMaskEnemy: strongSelf.physicsBodyMask.enemyMask,                 // EnemyCollisionMask
                    physicsMaskEmpty: strongSelf.physicsBodyMask.emptyMask,                 // EmptyCollisionMask
                    physicsMaskPlayer: strongSelf.physicsBodyMask.playerMask,               // PlayerCollisionMask
                    physicsMaskProtoStar: strongSelf.physicsBodyMask.protoStarMask          // ProtoStarCollsionMask
                    
                )
            default:
                print("wrong case!")
            }
        }
    }
    
    
    // Global access to game instance
    // https://stackoverflow.com/questions/29809643/how-to-make-a-global-variable-that-uses-self-in-swift
    //class var sharedInstance: GameScene {
      //  return _SingletonSharedInstance
    //}
    
}

// Global access to game instance --> not working T_T
//private let _SingletonSharedInstance = GameScene()

