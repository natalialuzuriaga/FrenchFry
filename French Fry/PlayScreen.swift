//
//  PlayScreen.swift
//  French Fry
//
//  Created by Natalia Luzuriaga on 7/25/17.
//  Copyright © 2017 Natalia Luzuriaga. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit

class PlayScreen: SKScene, GKGameCenterControllerDelegate {
    //UI Connections
    var playButton: MSButtonNode!
    var tutorialButton: MSButtonNode!
    var informationButton: MSButtonNode!
    var shopButton: MSButtonNode!
    var gameCenterButton: MSButtonNode!
    
    override func didMove(to view: SKView) {
        //Setup scene
        
        //Set UI connections
        playButton = self.childNode(withName: "playButton") as! MSButtonNode
        tutorialButton = self.childNode(withName: "tutorialButton") as! MSButtonNode
        informationButton = self.childNode(withName: "informationButton") as! MSButtonNode
        shopButton = self.childNode(withName: "shopButton") as! MSButtonNode
        gameCenterButton = self.childNode(withName: "gameCenterButton") as! MSButtonNode
        
        playButton.selectedHandler = { [unowned self] in
            self.loadGame()
        }
        
        tutorialButton.selectedHandler = { [unowned self] in
            self.loadTutorial()
        }
        
        informationButton.selectedHandler = { [unowned self] in
            self.loadCredits()
        }
        
        shopButton.selectedHandler = { [unowned self] in
            self.loadShop()
        }
        
        gameCenterButton.selectedHandler = { [unowned self] in
            self.showLeaderboard()
        }
    }
    
    func loadGame() {
        //reset global variables
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

        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView! else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Game scene */
        guard let scene = GameScene(fileNamed: "GameScene") else {
            print("Could not load GameScene with GameScene")
            return
        }
        
        let transition = SKTransition.crossFade(withDuration: 1.0)
        
        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFit
    
        /* 4) Start game scene */
        skView.presentScene(scene, transition: transition)
    }
    
    func loadTutorial() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView! else {
            print("Could not get Skview")
            
            return
        }
        
        /* 2) Load Game scene */
        guard let scene = SKScene(fileNamed: "TemporaryTutorial") else {
            print("Could not load GameScene with GameScene")
            return
        }
        
        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFit
        
        
        /* 4) Start game scene */
        skView.presentScene(scene)
    }
    
    func loadCredits() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView! else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Game scene */
        guard let scene = SKScene(fileNamed: "Information") else {
            print("Could not load GameScene with GameScene")
            return
        }
        
        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFit
        
        /* 4) Start game scene */
        skView.presentScene(scene)
    }
    
    func loadShop() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView! else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Game scene */
        guard let scene = SKScene(fileNamed: "Shop") else {
            print("Could not load GameScene with GameScene")
            return
        }
        
        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFit
        
        /* 4) Start game scene */
        skView.presentScene(scene)
    }
    
    func saveHighscoreGC(number: Int){
        if GKLocalPlayer.localPlayer().isAuthenticated {
            let scoreReporter = GKScore(leaderboardIdentifier: "fryFight.leaderboard")
            
            scoreReporter.value = Int64(number)
            
            let scoreArray : [GKScore] = [scoreReporter]
            GKScore.report(scoreArray,withCompletionHandler: nil)
        }
    }
    
    func showLeaderboard() {
        saveHighscoreGC(number: highScore)
        let viewController = self.view?.window?.rootViewController
        let gcvc = GKGameCenterViewController()
        
        gcvc.gameCenterDelegate = self
        viewController?.present(gcvc, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
