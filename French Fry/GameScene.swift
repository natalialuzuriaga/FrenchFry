//  GameScene.swift
//  French Fry
//
//  Created by Natalia Luzuriaga on 7/24/17.
//  Copyright © 2017 Natalia Luzuriaga. All rights reserved.
//

import SpriteKit
import GameplayKit

struct GlobalData
{
    //global variables - needed for transition between GameScene and Boss Stage
    static var currentScore = 1
    static var currentSaltTotal = 0
    static var bonus = 0
    static var scrollSpeed: CGFloat = 100
    
    //Generate Times
    static var spawnOne: Double = 1.0
    static var spawnThree: Double = 2.8
    static var spawnFourTable: Double = 2.7
    static var spawnFourGrain: Double = 4.05
    static var spawnFiveBottle: Double = 2
    static var spawnFiveDrop: Double = 1
    static var spawnSixStool: Double = 1.5
    static var spawnSixGrain: Double = 2.56
    
}
//also global variables
var highScore = UserDefaults.standard.integer(forKey: "HIGHSCORE")
var saltCollection = UserDefaults.standard.integer(forKey: "COINS")

var backgroundMusic: SKAudioNode!

class GameState {

}
class GameScene: SKScene, SKPhysicsContactDelegate {
    var save: CGFloat = 0
    
    /* COUNT VARS AND OTHER VARS */
    var countSet = 0
    var countSalt = 0
    var countTable = 0
    var countStool = 0
    var countBottles = 0
    var max = 0
    var pattern = 3
    var sets = 0
    
    var jump = false
    var increaseSpeed = false
    var pauseNow = false
    var invincible = false
    var once = false
    
    /* NODE VARS */
    var scrollLayer: SKNode!
    var obstacleLayer: SKNode!
    var light: SKNode!
    var superSalty: SKNode!
    
    var frenchFry: SKSpriteNode!
    var obstacleSource: SKSpriteNode!
    var forkSource: SKSpriteNode!
    var salt: SKSpriteNode!
    var oilDrop: SKSpriteNode!
    var healthBar: SKSpriteNode!
    var nodeRemoval: SKSpriteNode!
    var table: SKSpriteNode!
    var booth: SKSpriteNode!
    var ketchupBottle: SKSpriteNode!
    var ketchupDrop: SKSpriteNode!
    var mustardBottle: SKSpriteNode!
    var mustardDrop: SKSpriteNode!
    var stool: SKSpriteNode!
    var hand: SKSpriteNode!
    var invincibility: SKSpriteNode!
    //var counter: SKNode! - pattern 7
    
    var saltLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    
    var pauseButton: MSButtonNode!
    var continueButton: MSButtonNode!
    var restartButton: MSButtonNode!
    var mainMenuButton: MSButtonNode!
    
    
    
    /* TIME AND SPEED VARS */
    var fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    var spawnObstacleTimer: CFTimeInterval = 0
    var spawnSaltTimer: CFTimeInterval = 0
    var spawnTableTimer: CFTimeInterval = 0
    var spawnBottleTimer: CFTimeInterval = 0
    var spawnStoolTimer: CFTimeInterval = 0
    var invincibilityTimer: CFTimeInterval = 11
    var xPosition: CFTimeInterval = 0
    var distance: CFTimeInterval = CFTimeInterval(Int(GlobalData.currentScore))
    
    /* HEALTH */
    var health: CGFloat = 1.0 {
        didSet {
            /* Scale health bar between 0.0 -> 1.0 e.g 0 -> 100% */
            healthBar.xScale = health
            if health > 1.0 { health = 1.0 }
        }
    }
    //sounds
    let obtainSalt = SKAction.playSoundFileNamed("coin3.mp3", waitForCompletion: false)
    let obtainDrop = SKAction.playSoundFileNamed("waterdrop.mp3", waitForCompletion: false)
    let hit = SKAction.playSoundFileNamed("rub glass 1.mp3", waitForCompletion: false)
    let splat = SKAction.playSoundFileNamed("Splat.mp3", waitForCompletion: false)
    
    //animation
    let frenchFryHop = SKAction(named: "frenchFryHop")!
    
    override func didMove(to view: SKView) {
        
        self.view?.showsPhysics = false
        
        /* ONCE GAME BEGINS, SETS MAX */
        max = randomValue(highestVal: 5, lowestVal: 3)
        
        /* CONNECTIONS */
        frenchFry = childNode(withName: "frenchFry") as! SKSpriteNode
        frenchFry.physicsBody?.usesPreciseCollisionDetection = true
        
        obstacleSource = self.childNode(withName: "obstacle") as! SKSpriteNode
        forkSource = self.childNode(withName: "fork") as! SKSpriteNode
        salt = self.childNode(withName: "grainOfSalt") as! SKSpriteNode
        scrollLayer = self.childNode(withName: "scrollLayer")
        obstacleLayer = self.childNode(withName: "obstacleLayer")
        healthBar = self.childNode(withName: "healthBar") as! SKSpriteNode
        oilDrop = self.childNode(withName: "oilDrop") as! SKSpriteNode
        table = self.childNode(withName: "table") as! SKSpriteNode
        booth = self.childNode(withName: "booth") as! SKSpriteNode
        ketchupBottle = self.childNode(withName: "ketchupBottle") as! SKSpriteNode
        ketchupDrop = self.childNode(withName: "ketchupDrop") as! SKSpriteNode
        mustardBottle = self.childNode(withName: "mustardBottle") as! SKSpriteNode
        mustardDrop = self.childNode(withName: "mustardDrop") as! SKSpriteNode
        nodeRemoval = self.childNode(withName: "nodeRemoval") as! SKSpriteNode
        stool = self.childNode(withName: "stool") as! SKSpriteNode
        hand = self.childNode(withName: "hand") as! SKSpriteNode
        invincibility = self.childNode(withName: "invincibility") as! SKSpriteNode
        
        saltLabel = self.childNode(withName: "saltLabel") as! SKLabelNode
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        light  = self.childNode(withName: "light")
        superSalty = self.childNode(withName: "superSalty")
        //counter = self.childNode(withName: "counter") pattern 7
        
        pauseButton = self.childNode(withName: "pauseButton") as! MSButtonNode
        continueButton = self.childNode(withName: "continueButton") as! MSButtonNode
        restartButton = self.childNode(withName: "restartButton") as! MSButtonNode
        mainMenuButton = self.childNode(withName: "mainMenuButton") as! MSButtonNode
        
        /* PHYSICS CONTACT DELEGATE CONNECTION */
        physicsWorld.contactDelegate = self
        
        pauseButton.selectedHandler = { [unowned self] in
            self.pause()
        }
        continueButton.selectedHandler = { [unowned self] in
            self.resume()
        }
        restartButton.selectedHandler = { [unowned self] in
            self.loadGame()
        }
        mainMenuButton.selectedHandler = { [unowned self] in
            self.loadMainMenu()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        /* PHYSICS CONTACT DELEGATE IMPLEMENTATION */
        
        /* Get references to the bodies involved in the collision */
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        
        /* Get references to the physics body parent SKSpriteNode */
        
        //KILL WHEN HAND AND FRENCH FRY COLLIDE
        if invincible == false {
            if contactA.categoryBitMask == 8192 || contactB.categoryBitMask == 8192 {
                if contactA.categoryBitMask == 1 {
                    gameOver()
                }
                if contactB.categoryBitMask == 1 {
                    gameOver()
                }
            }
        }
        
        //FRENCH FRY AND KNIVE/FORK
        if invincible == false {
            if contactA.categoryBitMask == 2 || contactB.categoryBitMask == 2 {
                if contactA.categoryBitMask == 1 {
                    if let node = contactB.node {
                        run(hit)
                        health -= 0.05
                        remove(node: node)
                    }
                }
                if contactB.categoryBitMask == 1 {
                    if let node = contactA.node {
                        run(hit)
                        health -= 0.05
                        remove(node: node)
                    }
                }
            }
        }
        
        //FRENCH FRY AND SALT
        if contactA.categoryBitMask == 4 || contactB.categoryBitMask == 4 {
            if let node = contactB.node {
                if contactA.categoryBitMask == 1 {
                    GlobalData.currentSaltTotal += 1
                    run(obtainSalt)
                    remove(node: node)
                }
            }
            if contactB.categoryBitMask == 1 {
                if let node = contactA.node {
                    GlobalData.currentSaltTotal+=1
                    run(obtainSalt)
                    remove(node: node)
                }
                
            }
        }
        //FRENCH FRY AND OIL DROP
        if contactA.categoryBitMask == 8 || contactB.categoryBitMask == 8 {
            if contactA.categoryBitMask == 1 {
                if let node = contactB.node {
                    remove(node: node)
                    health += 0.05
                    run(obtainDrop)
                }
            }
            
            if contactB.categoryBitMask == 1 {
                if let node = contactA.node {
                    remove(node: node)
                    health += 0.05
                    run(obtainDrop)
                }
            }
        }
        //FRENCH FRY AND INVINCIBILITY
        if contactA.categoryBitMask == 32768 || contactB.categoryBitMask == 32768 {
            if contactA.categoryBitMask == 1 {
                if let node = contactB.node {
                    remove(node:node)
                    invincible = true
                }
            }
            if contactB.categoryBitMask == 1 {
                if let node = contactA.node {
                    remove(node:node)
                    invincible = true
                }
            }
        }
        
        //OUT OF BOUNDS DELETION
        if contactA.categoryBitMask == 512 || contactB.categoryBitMask == 512 {
            if contactA.categoryBitMask != 512 {
                if let node = contactA.node {
                    remove(node: node)
                }
            }
            if contactB.categoryBitMask != 512 {
                if let node = contactB.node {
                    remove(node: node)
                }
            }
        }
        //SINGLE JUMP CHECK
        if contactA.categoryBitMask == 32 || contactB.categoryBitMask == 32 || contactA.categoryBitMask == 64 || contactB.categoryBitMask == 64 || contactA.categoryBitMask == 128 || contactB.categoryBitMask == 128 || contactA.categoryBitMask == 256 || contactB.categoryBitMask == 256  || contactA.categoryBitMask == 2048 || contactB.categoryBitMask == 2048 {
            if contactA.categoryBitMask == 1 {
                frenchFry.run(frenchFryHop)
                frenchFry.isPaused = false
                jump = true
            }
            if contactB.categoryBitMask == 1 {
                frenchFry.run(frenchFryHop)
                frenchFry.isPaused = false
                jump = true
            }
        }
        
        //KNIVES AND GROUND
        if contactA.categoryBitMask == 2 || contactB.categoryBitMask == 2 {
            if contactA.categoryBitMask == 32 {
                if let node = contactB.node {
                    remove(node: node)
                }
            }
            if contactB.categoryBitMask == 32 {
                if let node = contactA.node {
                    remove(node: node)
                }
            }
        }
        
        // KETCHUP & MUSTARD DROP AND GROUND
        if contactA.categoryBitMask == 1024 || contactB.categoryBitMask == 1024 || contactA.categoryBitMask == 16384 || contactB.categoryBitMask == 16384 {
            if contactA.categoryBitMask == 32{
                if let node = contactB.node {
                    remove(node: node)
                }
            }
            if contactB.categoryBitMask == 32{
                if let node = contactA.node {
                    remove(node: node)
                }
            }
        }
        
        //KETCHUP DROP AND FRENCH FRY
        if invincible == false {
            if contactA.categoryBitMask == 1024 || contactB.categoryBitMask == 1024 {
                if contactA.categoryBitMask == 1 {
                    if let node = contactB.node {
                        run(splat)
                        health -= 0.05
                        remove(node: node)
                        let yourNode = SKSpriteNode(imageNamed: "fryReScaled")
                        yourNode.colorBlendFactor = 0
                        frenchFry.run(SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: 0.50))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.frenchFry.run(SKAction.colorize(with: UIColor.yellow, colorBlendFactor: 1, duration: 0.50))
                        }
                    }
                }
                
                if contactB.categoryBitMask == 1 {
                    if let node = contactA.node {
                        run(splat)
                        health -= 0.05
                        remove(node: node)
                        let yourNode = SKSpriteNode(imageNamed: "fryReScaled")
                        yourNode.colorBlendFactor = 0
                        frenchFry.run(SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: 0.50))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.frenchFry.run(SKAction.colorize( with: UIColor.yellow,colorBlendFactor: 1, duration: 0.50))
                        }
                    }
                }
            }
        }
        
        //MUSTARD DROP AND FRENCH FRY
        if invincible == false {
            if contactA.categoryBitMask == 16384 || contactB.categoryBitMask == 16384 {
                if contactA.categoryBitMask == 1 {
                    if let node = contactB.node {
                        run(splat)
                        health -= 0.05
                        remove(node: node)
                        frenchFry.run(SKAction.colorize(with: UIColor.green, colorBlendFactor: 1.0, duration: 0.50))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.frenchFry.run(SKAction.colorize(with: UIColor.yellow,colorBlendFactor: 1, duration: 0.50))
                        }
                    }
                }
                
                if contactB.categoryBitMask == 1 {
                    if let node = contactA.node {
                        run(splat)
                        health -= 0.05
                        remove(node: node)
                        frenchFry.run(SKAction.colorize(with: UIColor.green, colorBlendFactor: 1.0, duration: 0.50))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.frenchFry.run(SKAction.colorize(with: UIColor.yellow, colorBlendFactor: 1, duration: 0.50))
                        }
                    }
                }
            }
        }
    }
    
    func updateInvincibility() {
        //INVINCIBILITY POWERUP GENERATES
        let newInv = invincibility.copy() as! SKNode
        obstacleLayer.addChild(newInv)
        let randomPosition = CGPoint(x: 714, y: 90)
        newInv.position = self.convert(randomPosition, to: obstacleLayer)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //SINGLE JUMP CHECK
        if jump == true {
            frenchFry.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            frenchFry.physicsBody?.applyImpulse(CGVector(dx: 0, dy:60))
            frenchFry.isPaused = true
            frenchFry.texture = SKTexture(imageNamed: "fryReScaled")
            jump = false
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // SCROLLS
        scrollWorld()
        obstacleLayer.position.x -= GlobalData.scrollSpeed * CGFloat(fixedDelta)
        
        //INCREASE SPEED EVERY 2 SETS
        if increaseSpeed == true {
            GlobalData.scrollSpeed += 5
            updateTime()
            increaseSpeed = false
        }
        
        //every 300 points, loads Boss Stage
        if GlobalData.currentScore % 300 == 0 {
            loadBoss()
        }
        
        //GENERATE INVINCIBILITY POWERUP
        if GlobalData.currentScore % 100 == 0 && once == false {
            self.updateInvincibility()
            self.once = true
        }
        if GlobalData.currentScore % 350 == 0 {
            self.once = false
        }
        
        // INVINCIBILITY ACTIVATED
        if invincible == true {
            invincibilityTimer-=fixedDelta
            scoreLabel.text = "Invincibility: \(Int(invincibilityTimer))"
            if invincibilityTimer <= 0 {
                invincible = false
                invincibilityTimer = 11
                scoreLabel.text = String(Int(distance))
            }
        }
        
        // HAND FOLLOWING FRY
        if pauseNow == false {
            // HAND WILL NOT MOVE WHEN IN GROUND LEVEL
            if hand.position.y < 70{
                hand.position.y = 70
            }
            
            // HAND WILL FOLLOW FRENCH FRY AT A DELAY IF HIGHER
            if hand.position.y > frenchFry.position.y {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.hand.position.y -= 1
                }
            }
            
            // HAND WILL FOLLOW FRENCH FRY AT A DELAY IF LOWER
            if hand.position.y < frenchFry.position.y{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.hand.position.y += 1
                }
            }
        }
        
        //EVERY 5 SECONDS, FRENCH FRY MOVES TO THE RIGHT OF THE SCREEN
        xPosition+=fixedDelta
        if frenchFry.position.x < 225 && xPosition >= 3.5 {
            for _ in 1...10 {
                frenchFry.position.x += 1
            }
            xPosition = 0
        }
        
        //PREVENT FROM GOING OUT OF BOUNDS
        if frenchFry.position.y > 320 {
            frenchFry.position.y = 320
        }
        
        //PREVENT FROM GOING TOO FAR UP
        if frenchFry.position.x > 225 {
            frenchFry.position.x = 225
        }
        
        //IF OFF SCREEN, GAME OVER
        if frenchFry.position.x < 0 {
            frenchFry.position.x = 0
        }
        
        //HEALTH
        health -= 0.0001 //Progressively Decreases
        if health < 0 {
            gameOver() // Game Over when health reaches 0
        }
        
        //COLLECTED SALT
        saltLabel.text = String(GlobalData.currentSaltTotal)
        
        //SCORE CALCULATION
        distance+=fixedDelta * 5
        if invincible == false {
            scoreLabel.text = String(Int(distance))
        }
        GlobalData.currentScore = Int(distance)
        //RANDOMIZES PATTERN
        switch pattern {
        case 1:
            spawnSaltTimer+=fixedDelta
            updatePatternOne()
        case 2:
            spawnSaltTimer+=fixedDelta
            updatePatternTwo()
            
        case 3:
            spawnTableTimer+=fixedDelta
            updatePatternThree()
            spawnObstacleTimer+=fixedDelta
            updateObstacles(pattern: 3)
            
        case 4:
            spawnTableTimer+=fixedDelta
            spawnSaltTimer+=fixedDelta
            updatePatternFour()
            spawnObstacleTimer+=fixedDelta
            updateObstacles(pattern: 4)
        case 5:
            spawnBottleTimer+=fixedDelta
            updatePatternFive()
            spawnObstacleTimer+=fixedDelta
            updateObstacles(pattern: 5)
            
        case 6:
            spawnStoolTimer+=fixedDelta
            spawnSaltTimer+=fixedDelta
            updatePatternSix()
            spawnObstacleTimer+=fixedDelta
            updateObstacles(pattern: 6)
            
        default:
            break
        }
    }
    
    func updateObstacles(pattern: Int) {
        /* UPDATE KNIVES */
        
        let randomPosition: CGPoint
        
        //GENERATES EVERY 1.5 SECONDS
        if spawnObstacleTimer >= 1.5 {
            /* Create a new obstacle by copying the source obstacle */
            var newObstacle: SKNode?
            switch randomValue(highestVal: 2, lowestVal: 1) {
            case 1:
                newObstacle = obstacleSource.copy() as? SKNode
            case 2:
                newObstacle = forkSource.copy() as? SKNode
            default:
                break
            }
            
            obstacleLayer.addChild(newObstacle!)
            
            //DEPENDING ON PATTERN, GENERATES KNIVES WITHIN A CERTAIN RANGE
            switch pattern {
            case 3:
                randomPosition = CGPoint(x:randomValue(highestVal: 600, lowestVal: 593), y:randomValue(highestVal: 310, lowestVal:  240))
                newObstacle?.position = self.convert(randomPosition, to: obstacleLayer)
                
            case 4:
                randomPosition = CGPoint(x:randomValue(highestVal: 600, lowestVal: 593), y:randomValue(highestVal: 220, lowestVal:  70))
                newObstacle?.position = self.convert(randomPosition, to: obstacleLayer)
                
            case 5:
                randomPosition = CGPoint(x:randomValue(highestVal: 600, lowestVal: 593), y:randomValue(highestVal: 210, lowestVal:  45))
                newObstacle?.position = self.convert(randomPosition, to: obstacleLayer)
                
            case 6:
                randomPosition = CGPoint(x:randomValue(highestVal: 600, lowestVal: 593), y:randomValue(highestVal: 220, lowestVal:  80))
                newObstacle?.position = self.convert(randomPosition, to: obstacleLayer)
                
            default:
                break
            }
            
            //FORCE
            newObstacle?.physicsBody?.applyForce(CGVector(dx: -125, dy: 0))
            
            // RESET TIMER
            spawnObstacleTimer = 0
        }
    }
    
    func updatePatternOne() {
        /* UPDATE LINES OF OIL AND SALT */
        
        //GENERATES EVERY 1 SECONDS
        if countSalt <= max {
            if spawnSaltTimer >= GlobalData.spawnOne {
                countSalt += 1
                switch randomValue(highestVal: 5, lowestVal: 1) {
                case 1, 2, 4, 5:
                    /* Create a new salt by copying the source salt */
                    let newSalt = salt.copy() as! SKNode
                    obstacleLayer.addChild(newSalt)
                    
                    /* Generate new salt position, start just outside screen and with a random x and y value */
                    let randomPosition = CGPoint(x: 586, y: 50)
                    
                    /* Convert new node position back to obstacle layer space */
                    newSalt.position = self.convert(randomPosition, to: obstacleLayer)
                    newSalt.physicsBody?.usesPreciseCollisionDetection = true
                    
                    //reset timer
                    spawnSaltTimer = 0
                case 3:
                    // 20% CHANCE WILL BE SPAWNED
                    let newOil = oilDrop.copy() as! SKNode
                    obstacleLayer.addChild(newOil)
                    let randomPosition = CGPoint(x: 586, y: 50)
                    newOil.position = self.convert(randomPosition, to: obstacleLayer)
                    
                    //reset timer
                    spawnSaltTimer = 0
                default:
                    break
                }
            }
        }
        else {
            //WHEN SPAWNING IS COMPLETE
            reset(set: 1)
        }
    }
    
    func updatePatternTwo() {
        /* UPDATE LINES OF OIL AND SALT OF DIFFERING HEIGHTS*/
        if countSalt < max {
            if spawnSaltTimer >= GlobalData.spawnOne{
                countSalt += 1
                switch randomValue(highestVal: 5, lowestVal: 1) {
                case 1, 2, 4, 5:
                    let newSalt = salt.copy() as! SKNode
                    obstacleLayer.addChild(newSalt)
                    let randomPosition = CGPoint(x: 586, y: randomPick(valOne: 50, valTwo: 100))
                    newSalt.position = self.convert(randomPosition, to: obstacleLayer)
                    
                    // Reset spawn timer
                    spawnSaltTimer = 0
                    
                case 3:
                    let newOil = oilDrop.copy() as! SKNode
                    obstacleLayer.addChild(newOil)
                    let randomPosition = CGPoint(x: 586, y:randomPick(valOne: 50, valTwo: 100))
                    newOil.position = self.convert(randomPosition, to: obstacleLayer)
                    spawnSaltTimer = 0
                    
                default:
                    break
                }
            }
        }
        else {
            //WHEN SPAWNING IS COMPLETE
            reset(set: 2)
        }
    }
    
    func updatePatternThree() {
        /* UPDATE TABLE, BOOTH AND LIGHTS */
        
        //GENERATES EVERY 2.8 SECONDS
        if countSet < max {
            if spawnTableTimer >= GlobalData.spawnThree {
                countSet += 1
                
                let newTable = table.copy() as! SKNode
                obstacleLayer.addChild(newTable)
                let randomPosition = CGPoint(x: 714, y: 54.664)
                newTable.position = self.convert(randomPosition, to: obstacleLayer)
                newTable.physicsBody?.usesPreciseCollisionDetection = true
                
                updateBooth() //CALLS BOOTHS
                updateLight() //CALLS LIGHT
                spawnTableTimer = 0 // Reset spawn timer
            }
        }
        else {
            //WHEN SPAWNING IS COMPLETE
            reset(set: 3)
        }
    }
    
    func updatePatternFour() {
        if countTable < max {
            if spawnSaltTimer >= GlobalData.spawnFourGrain{
                
                switch randomValue(highestVal: 2, lowestVal: 1) {
                case 1:
                    let newSalt = salt.copy() as! SKNode
                    obstacleLayer.addChild(newSalt)
                    let randomPosition = CGPoint(x: 586, y: 200)
                    newSalt.position = self.convert(randomPosition, to: obstacleLayer)
                    
                    //reset timer
                    spawnSaltTimer = 0
                case 2:
                    // 20% CHANCE WILL BE SPAWNED
                    let newOil = oilDrop.copy() as! SKNode
                    obstacleLayer.addChild(newOil)
                    let randomPosition = CGPoint(x: 586, y: 200)
                    newOil.position = self.convert(randomPosition, to: obstacleLayer)
                    
                    //reset timer
                    spawnSaltTimer = 0
                default:
                    break
                }
            }
            if spawnTableTimer >= GlobalData.spawnFourTable {
                countTable += 1
                
                let newTable = table.copy() as! SKNode
                obstacleLayer.addChild(newTable)
                let randomPosition = CGPoint(x: 714, y: 54.664)
                newTable.position = self.convert(randomPosition, to: obstacleLayer)
                newTable.physicsBody?.usesPreciseCollisionDetection = true
                
                spawnTableTimer = 0 // Reset spawn timer
            }
        }
        else {
            //WHEN SPAWNING IS COMPLETE
            reset(set: 4)
        }
    }
    
    func updatePatternFive() {
        if countBottles <= max {
            if spawnBottleTimer > GlobalData.spawnFiveBottle {
                countBottles+=1
                switch randomValue(highestVal: 2, lowestVal: 1) {
                case 1:
                    let newBottle = ketchupBottle.copy() as! SKNode
                    obstacleLayer.addChild(newBottle)
                    let randomPosition = CGPoint(x: 654, y: 275)
                    newBottle.position = self.convert(randomPosition, to: obstacleLayer)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + GlobalData.spawnFiveDrop) {
                        let newDrop = self.ketchupDrop.copy() as! SKNode
                        self.obstacleLayer.addChild(newDrop)
                        let position = CGPoint(x: newBottle.position.x, y: 230)
                        newDrop.position = position
                        newDrop.physicsBody?.applyForce(CGVector(dx: 0, dy: -8.3))}
                case 2:
                    let newBottle = mustardBottle.copy() as! SKNode
                    obstacleLayer.addChild(newBottle)
                    let randomPosition = CGPoint(x: 654, y: 270)
                    newBottle.position = self.convert(randomPosition, to: obstacleLayer)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        let newDrop = self.mustardDrop.copy() as! SKNode
                        self.obstacleLayer.addChild(newDrop)
                        let position = CGPoint(x: newBottle.position.x, y: 230)
                        newDrop.position = position
                        newDrop.physicsBody?.applyForce(CGVector(dx: 0, dy: -8.3))}
                default:
                    break
                }
                spawnBottleTimer = 0
            }
        }
        else {
            //WHEN SPAWNING IS COMPLETE
            reset(set: 5)
        }
    }
    
    func updatePatternSix() {
        if countStool < max {
            if spawnSaltTimer >= GlobalData.spawnSixGrain {
                
                switch randomValue(highestVal: 5, lowestVal: 1) {
                case 1, 3, 5:
                    // 60% CHANCE SALT WILL BE SPAWNED
                    let newSalt = salt.copy() as! SKNode
                    obstacleLayer.addChild(newSalt)
                    let randomPosition = CGPoint(x: 586, y: 200)
                    newSalt.position = self.convert(randomPosition, to: obstacleLayer)
                    
                    //reset timer
                    spawnSaltTimer = 0
                case 2, 4:
                    // 40% CHANCE OIL WILL BE SPAWNED
                    let newOil = oilDrop.copy() as! SKNode
                    obstacleLayer.addChild(newOil)
                    let randomPosition = CGPoint(x: 586, y: 200)
                    newOil.position = self.convert(randomPosition, to: obstacleLayer)
                    
                    //reset timer
                    spawnSaltTimer = 0
                default:
                    break
                }
            }
            if spawnStoolTimer >= GlobalData.spawnSixStool {
                countStool += 1
                
                let newTable = stool.copy() as! SKNode
                obstacleLayer.addChild(newTable)
                let randomPosition = CGPoint(x: 586, y: 58.54)
                newTable.position = self.convert(randomPosition, to: obstacleLayer)
                newTable.physicsBody?.usesPreciseCollisionDetection = true
                
                spawnStoolTimer = 0 // Reset spawn timer
            }
        }
        else {
            //WHEN SPAWNING IS COMPLETE
            reset(set: 6)
        }
    }
    
    func updateBooth() {
        /* UPDATE BOOTHS */
        //CALLED IN updateTable()
        
        let newBooth = booth.copy() as! SKNode
        obstacleLayer.addChild(newBooth)
        let randomPosition = CGPoint(x: 854.285, y: 72.064)
        newBooth.position = self.convert(randomPosition, to: obstacleLayer)
        
    }
    
    func updateLight() {
        /* UPDATE LIGHT */
        //CALLED IN updateTable()
        let newLight = light.copy() as! SKNode
        obstacleLayer.addChild(newLight)
        let randomPosition = CGPoint(x: 714, y: 297.742)
        newLight.position = self.convert(randomPosition, to: obstacleLayer)
        
        updateOilLeft()
        updateOilRight()
    }
    
    func updateOilLeft() {
        /* UPDATE OIL */
        let newOil = oilDrop.copy() as! SKNode
        obstacleLayer.addChild(newOil)
        let randomPosition = CGPoint(x: 688.033, y: 247.742)
        newOil.position = self.convert(randomPosition, to: obstacleLayer)
    }
    
    func updateOilRight() {
        /* UPDATE OIL */
        let newOil = oilDrop.copy() as! SKNode
        obstacleLayer.addChild(newOil)
        let randomPosition = CGPoint(x: 740.194, y: 247.742)
        newOil.position = self.convert(randomPosition, to: obstacleLayer)
    }
    
    func updateTime() {
        //WHEN SCROLLSPEED INCREASES
        GlobalData.spawnOne -= 0.02 //set 1 and set 2
        GlobalData.spawnThree -= 0.1 //set 3
        GlobalData.spawnFourTable -= 0.06 // set 4
        GlobalData.spawnFourGrain = (GlobalData.spawnFourTable * 1.5) - 0.02 // set 4
        GlobalData.spawnFiveBottle -= 0.1 // set 5
        GlobalData.spawnFiveDrop -= (GlobalData.spawnFiveBottle/2) //set 5
        GlobalData.spawnSixStool -= 0.02 //set 6
        GlobalData.spawnSixGrain = (GlobalData.spawnSixStool * 1.5) - 0.02 //set 6 ?may change?
    }
    
    func reset(set: Int) {
        sets+=1
        increaseSpeed = true
        if pattern >= 3 {
            max = randomValue(highestVal: 5, lowestVal: 3)
        }
        else
        {
            max = randomValue(highestVal: 10, lowestVal: 5)
        }
        switch set {
        case 1, 2:
            countSalt = 0 //reset
            pattern = randomValue(highestVal: 6, lowestVal: 3) //selects another pattern
        case 3, 4, 5, 6:
            countSet = 0 //set 3
            countTable = 0 //set 4
            countBottles = 0 //set 5
            countStool = 0 //set 6
            pattern = randomValue(highestVal:  6, lowestVal: 2)
            
        default:
            break
        }
    }

    
    func gameOver() {
        //CHECKS IF HIGHSCORE WAS SURPASSED
        GlobalData.currentScore += GlobalData.bonus
        if GlobalData.currentScore > highScore {
            saveHighScore()
        }
        //ADDS SALT COLLECTED TO SALT COLLECTION
        setSaltTotal()
        
        /* GAME OVER */
        let skView = self.view as SKView!
        guard let scene = GameScene(fileNamed:"GameOver") as GameScene! else {
            return
        }
        /* Ensure correct aspect mode */
        scene.scaleMode = .aspectFit
        
        /* Restart GameScene */
        skView?.presentScene(scene)
    }
    
    func scrollWorld() {
        /* SCROLL WORLD */
        scrollLayer.position.x -= GlobalData.scrollSpeed * CGFloat(fixedDelta)
        
        /* Loop through scroll layer nodes */
        for ground in scrollLayer.children as! [SKSpriteNode] {
            
            /* Get ground node position, convert node position to scene space */
            let groundPosition = scrollLayer.convert(ground.position, to: self)
            
            /* Check if ground sprite has left the scene */
            if groundPosition.x <= -ground.size.width / 2 + 2.7 {
                
                /* Reposition ground sprite to the second starting position */
                let newPosition = CGPoint(x: (self.size.width / 2) + ground.size.width, y: groundPosition.y)
                
                /* Convert new node position back to scroll layer space */
                ground.position = self.convert(newPosition, to: scrollLayer)
            }
        }
    }
    
    func randomValue(highestVal: Int, lowestVal: Int) -> Int {
        //SELECTS A RANDOM VALUE WITH GIVEN RANGE
        let result = Int(arc4random_uniform(UInt32(highestVal - lowestVal + 1))) + lowestVal
        return result
    }
    
    func randomPick(valOne: Int, valTwo: Int) -> Int {
        //Y VALUE OF UPDATEPATTERNTWO()
        let result = Int(arc4random_uniform(UInt32(2 - 1 + 1))) + 1
        
        if result == 1 {
            return 50
        }
        else {
            return 100
        }
    }
    func remove(node: SKNode) {
        //REMOVES NODE FROM SCENE
        node.removeFromParent()
    }
    
    
    func saveHighScore() {
        //SAVES HIGH SCORE
        UserDefaults().set(GlobalData.currentScore, forKey: "HIGHSCORE")
    }
    
    func setSaltTotal() {
        //SETS TOTAL AMOUNT OF SALT COLLECTED
        saltCollection += GlobalData.currentSaltTotal
        UserDefaults().set(saltCollection, forKey: "COINS")
    }
    
    func pause() {
        //PAUSE BUTTON IN GAMESCENE
        pauseNow = true
        save = GlobalData.scrollSpeed
        
        frenchFry.physicsBody?.isDynamic = false
        obstacleSource.physicsBody?.isDynamic = false
        scrollLayer.isPaused = true
        obstacleLayer.isPaused = true
        frenchFry.isPaused = true
        
        fixedDelta = 0
        frenchFryHop.speed = 0
        physicsWorld.speed = 0
        
        GlobalData.scrollSpeed = 0
        
        continueButton.zPosition = 100
        restartButton.zPosition = 100
        mainMenuButton.zPosition = 100
        pauseButton.zPosition = -10
    }
    
    func resume() {
        //CONTINUE BUTTON IN PAUSE MENU
        GlobalData.scrollSpeed = save
        
        frenchFry.physicsBody?.isDynamic = true
        obstacleSource.physicsBody?.isDynamic = true
        scrollLayer.isPaused = false
        obstacleLayer.isPaused = false
        frenchFry.isPaused = false
        pauseNow = false
        fixedDelta = 1.0 / 60.0
        frenchFryHop.speed = 0.5
        physicsWorld.speed = 1
        
        
        continueButton.zPosition = -100
        restartButton.zPosition = -100
        mainMenuButton.zPosition = -100
        pauseButton.zPosition = 10
    }
    
    func loadBoss() {
        //QUIT BUTTON IN PAUSE MENU
        guard let skView = self.view as SKView! else {
            print("Could not get Skview")
            
            return
        }
        
        guard let scene = SKScene(fileNamed: "BossStageOne") else {
            print("Could not load GameScene with GameScene")
            return
        }
        let transition = SKTransition.doorsOpenHorizontal(withDuration: 2.0)
        
        scene.scaleMode = .aspectFit
        
        skView.presentScene(scene, transition:transition)
    }

    
    func loadMainMenu() {
        //QUIT BUTTON IN PAUSE MENU
        guard let skView = self.view as SKView! else {
            print("Could not get Skview")
            
            return
        }
        
        guard let scene = SKScene(fileNamed: "PlayScreen") else {
            print("Could not load GameScene with GameScene")
            return
        }
        
        scene.scaleMode = .aspectFit
        
        skView.presentScene(scene)
    }
    
    func loadGame() {
        //rest global variables
        GlobalData.currentScore = 1
        GlobalData.currentSaltTotal = 0
        GlobalData.bonus = 0
        
        GlobalData.spawnOne = 1.0
        GlobalData.spawnThree = 2.8
        GlobalData.spawnFourTable = 2.7
        GlobalData.spawnFourGrain = 4.05
        GlobalData.spawnFiveBottle = 2
        GlobalData.spawnFiveDrop = 1
        GlobalData.spawnSixStool = 1.5
        GlobalData.spawnSixGrain = 2.56
        
        GlobalData.scrollSpeed = 100
        // RESTART BUTTON IN PAUSE MENU
        guard let skView = self.view as SKView! else {
            print("Could not get Skview")
            return
        }
        
        guard let scene = GameScene(fileNamed: "GameScene") else {
            print("Could not load GameScene with GameScene")
            return
        }
        
        scene.scaleMode = .aspectFit
        
        skView.presentScene(scene)
    }
    
}
