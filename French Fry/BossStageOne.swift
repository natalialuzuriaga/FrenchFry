//
//  BossStageOne.swift
//  French Fry
//
//  Created by Natalia Luzuriaga on 8/23/17.
//  Copyright © 2017 Natalia Luzuriaga. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class BossStageOne: SKScene, SKPhysicsContactDelegate {
    //KEEPS TRACK OF PEPPER COLLECTED
    var bombs = 0

    var frenchFry: SKSpriteNode!
    var fork: SKSpriteNode!
    var ground: SKSpriteNode!
    var garlicBomb: SKSpriteNode!
    var bossHealthRed: SKSpriteNode!
    
    var arrowLeft: SKSpriteNode!
    var arrowRight: SKSpriteNode!
    
    var bombLayer: SKNode!
    var bossLabel: SKLabelNode!
    
    var pauseButton: MSButtonNode!
    var continueButton: MSButtonNode!
    var restartButton: MSButtonNode!
    var mainMenuButton: MSButtonNode!
    
    var hitGround = false
    var touchObject = false
    var pauseNow = false
    var leftTap = false
    var rightTap = false
    
    //TIMERS
    var labelTimer :CFTimeInterval = 0
    var bombGeneration: CFTimeInterval = 0
    var fixedDelta: CFTimeInterval = 1.0/60.0
    
    /* HEALTH */
    var health: CGFloat = 1.0 {
        didSet {
            /* Scale health bar between 0.0 -> 1.0 e.g 0 -> 100% */
            bossHealthRed.xScale = health
            if health > 1.0 { health = 1.0 }
        }
    }
    
    override func didMove(to view: SKView) {
        //physics!
        physicsWorld.contactDelegate = self
        
        //CONNECTIONS
        frenchFry = self.childNode(withName: "frenchFry") as! SKSpriteNode
        fork = self.childNode(withName: "fork") as! SKSpriteNode
        ground = self.childNode(withName: "ground") as! SKSpriteNode
        garlicBomb = self.childNode(withName: "garlicBomb") as! SKSpriteNode
        bossHealthRed = self.childNode(withName: "bossHealthRed") as! SKSpriteNode
        arrowLeft = self.childNode(withName: "arrowLeft") as! SKSpriteNode
        arrowRight = self.childNode(withName: "arrowRight") as! SKSpriteNode
        
        bossLabel = self.childNode(withName: "bossLabel") as! SKLabelNode
        pauseButton = self.childNode(withName: "pauseButton") as! MSButtonNode
        continueButton = self.childNode(withName: "continueButton") as! MSButtonNode
        restartButton = self.childNode(withName: "restartButton") as! MSButtonNode
        mainMenuButton = self.childNode(withName: "mainMenuButton") as! MSButtonNode
        bombLayer = self.childNode(withName: "bombLayer")
        
        pauseButton.selectedHandler = {
            self.pauseNow = true
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
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        
        //french fry(1) obtains bomb(32)
        if contactA.categoryBitMask == 32 || contactB.categoryBitMask == 32{
            if contactA.categoryBitMask ==  1{
                remove(node: contactB.node!)
                bombs+=1
            }
            if contactB.categoryBitMask == 1{
                remove(node: contactA.node!)
                bombs+=1
            }
        }
        
        
        //fork (2) and ground (4)
        if contactA.categoryBitMask == 4 || contactB.categoryBitMask == 4{
            if contactA.categoryBitMask == 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.hitGround = true
                }
            }
            if contactB.categoryBitMask == 2{
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.hitGround = true
                }
            }
        }
        
        // fork(4) and out of bounds/hit block (8)
        if contactA.categoryBitMask == 8 || contactB.categoryBitMask == 8{
            if contactA.categoryBitMask == 4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.fork.position.x = self.frenchFry.position.x
                    if self.frenchFry.position.x < 50.0 {self.fork.position.x = 50.0}
                    if self.frenchFry.position.x > 511.0 {self.fork.position.x = 511.0}
                    self.hitGround = false
                }
            }
            if contactB.categoryBitMask == 4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.fork.position.x = self.frenchFry.position.x
                    if self.frenchFry.position.x < 50.0 {self.fork.position.x = 50.0}
                    if self.frenchFry.position.x > 511.0 {self.fork.position.x = 511.0}
                    self.hitGround = false
                }
            }
        }
        
        //fork(4) and french fry(1)
        if contactA.categoryBitMask == 4 || contactB.categoryBitMask == 4{
            if contactA.categoryBitMask == 1{
                gameOver()
            }
            if contactB.categoryBitMask == 1{
                gameOver()
            }
        }
        
        //bomb_moving(16) and fork(4)
        if contactA.categoryBitMask == 16 || contactB.categoryBitMask == 16{
            if contactA.categoryBitMask == 4 {
                remove(node: contactB.node!)
                GlobalData.bonus+=10
                health -= 0.1
            }
            if contactB.categoryBitMask == 4 {
                remove(node: contactA.node!)
                GlobalData.bonus+=10
                health -= 0.1
            }
        }
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        
        /* Get touch position in scene */
        let location = touch.location(in: self)
        
        /* IF TOUCH IN RIGHT SIDE, FRENCH FRY MOVES RIGHT */
        if location.x > size.width / 2 && touchObject == false {
            rightTap = true
            remove(node: arrowRight)
            frenchFry.position.x += 10
            frenchFry.xScale = 3
            if frenchFry.position.x >= 557.5 {frenchFry.position.x = 557.5}
        }
        
        /* IF TOUCH IN LEFT SIDE, FRENCH FRY MOVES LEFT */
        if location.x < size.width / 2 && touchObject == false {
            leftTap = true
            remove(node: arrowLeft)
            frenchFry.position.x -= 10
            frenchFry.xScale = -3
            if frenchFry.position.x <= 10.5 {frenchFry.position.x = 10.5}
        }
        
        let positionInScene = touch.location(in: self)
        let touchedNode = self.atPoint(positionInScene)
        
        if let name = touchedNode.name
        {
            if name == "fork"
            {
                //IF FRENCH FRY TAPS ON FORK
                touchObject = true
                if location.x >= frenchFry.position.x {createAndShootRight()} // if fork is more right than fry
                if location.x <= frenchFry.position.x {createAndShootLeft()} // if fry is more right than fork
                
            }
            else if name == "background" {
                touchObject = false
            }
        }
    }

    override func update(_ currentTime: TimeInterval) {
        if (leftTap == true && rightTap == true) {
        //Updates
        bombGeneration+=fixedDelta
        labelTimer+=fixedDelta
        updateGarlicBomb()
        
        //BOSS STAGE LABEL
        if labelTimer >= 5.5 {
            bossLabel.zPosition = -3
        }
        
        //FRY DEFEATS BOSS
        if health <= 0.0 {
            GlobalData.bonus += 100
            GlobalData.currentScore += 1
            cont()
        }
        //FORK ATTACKS
        if hitGround == false {
            if pauseNow == false {forkAttack()}
        }
        //FORK GOES UP
        if hitGround == true {
            if pauseNow == false {forkUp()}
        }
        
    }
    }
    
    func updateGarlicBomb() {
        //EVERY 5 SECONDS, NEW BOMB
        if bombGeneration > 5 {
            let newBomb = garlicBomb.copy() as! SKNode
            bombLayer.addChild(newBomb)
            
            /* Generate new salt position, start just outside screen and with a random x and y value */
            let randomPosition = CGPoint(x: randomValue(highestVal: 544, lowestVal: 25), y: 45)
            
            /* Convert new node position back to obstacle layer space */
            newBomb.position = self.convert(randomPosition, to: bombLayer)
            bombGeneration = 0
        }
        
    }
    
    func createAndShootRight() {
        //a bomb will be generated and shot right
        if bombs > 0 {
            let bomb = Bomb()
            addChild(bomb)
            //position of shot
            bomb.position.x += frenchFry.position.x + 30
            bomb.position.y += frenchFry.position.y + 10
            bomb.zPosition = -1
            bomb.physicsBody?.applyForce(CGVector(dx: 40, dy: 0))
            
            self.frenchFry.xScale = 3
            bombs -= 1
        }
    }
    
    func createAndShootLeft() {
        //a bomb will be generated and shot left
        if bombs > 0 {
            let bomb = Bomb()
            addChild(bomb)
            bomb.position.x += frenchFry.position.x - 30
            bomb.position.y += frenchFry.position.y + 10
            bomb.zPosition = -1
            bomb.physicsBody?.applyForce(CGVector(dx: -40, dy: 0))
            self.frenchFry.xScale = -3
            bombs -= 1
        }
    }
    
    func randomValue(highestVal: Int, lowestVal: Int) -> Int {
        //SELECTS A RANDOM VALUE WITH GIVEN RANGE
        let result = Int(arc4random_uniform(UInt32(highestVal - lowestVal + 1))) + lowestVal
        return result
    }

    func remove(node: SKNode) {
        //remove node
        node.removeFromParent()
    }

    func forkAttack() {
        fork.position.y -= 3
    }
    
    func forkUp() {
        fork.position.y += 3
    }
    
    func cont() {
        let skView = self.view as SKView!
        guard let scene = GameScene(fileNamed:"GameScene") as GameScene! else {
            return
        }
        
        let transition = SKTransition.crossFade(withDuration: 1.0)
        /* Ensure correct aspect mode */
        scene.scaleMode = .aspectFit
        
        /* Restart GameScene */
        skView?.presentScene(scene, transition: transition)
    }
    func gameOver() {
        //adds bonus and score from runner
        GlobalData.currentScore += GlobalData.bonus
        
        //CHECKS IF HIGHSCORE WAS SURPASSED
        if GlobalData.currentScore > highScore {
            saveHighScore()
        }
        //ADDS SALT COLLECTED TO SALT COLLECTION
        setSaltTotal()
        
        
        /* GAME OVER */
        let skView = self.view as SKView!
        guard let scene = SKScene(fileNamed:"GameOver") as SKScene! else {
            return
        }
        /* Ensure correct aspect mode */
        scene.scaleMode = .aspectFit
        
        /* Restart GameScene */
        skView?.presentScene(scene)
    }
    
    func saveHighScore() {
        //SAVES HIGH SCORE
        UserDefaults().set(GlobalData.currentScore, forKey: "HIGHSCORE")
    }
    
    func setSaltTotal() {
        //SETS TOTAL AMOUNT OF SALT COLLECTED
        saltCollection+=GlobalData.currentSaltTotal
        UserDefaults().set(saltCollection, forKey: "COINS")
    }
    
    func pause() {
        //PAUSE BUTTON IN GAMESCENE
        
        frenchFry.physicsBody?.isDynamic = false
        frenchFry.isPaused = true
        fork.physicsBody?.isDynamic = false
        fork.isPaused = true
        
        fixedDelta = 0
        physicsWorld.speed = 0
        
        continueButton.zPosition = 100
        restartButton.zPosition = 100
        mainMenuButton.zPosition = 100
        pauseButton.zPosition = -10
    }
    
    func resume() {
        //CONTINUE BUTTON IN PAUSE MENU
        pauseNow = false
        
        frenchFry.physicsBody?.isDynamic = true
        frenchFry.isPaused = false
        fork.physicsBody?.isDynamic = true
        fork.isPaused = false
        fixedDelta = 1.0 / 60.0
        physicsWorld.speed = 1
        
        
        continueButton.zPosition = -100
        restartButton.zPosition = -100
        mainMenuButton.zPosition = -100
        pauseButton.zPosition = 10
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



}
