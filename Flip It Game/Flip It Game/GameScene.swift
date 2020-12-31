//
//  GameScene.swift
//  Flip It Game
//
//  Created by Khoi Huu Minh Le on 5/5/20.
//  Copyright © 2020 Khoi Huu Minh Le. All rights reserved.
//

import SpriteKit
import GameplayKit

// Assign bit property to object
struct gamePhysics {
    
    static let RedBall : UInt32 = 0x1 << 1
    static let BlueBall : UInt32 = 0x1 << 2
    static let GreenBall : UInt32 = 0x1 << 3
    static let YellowBall : UInt32 = 0x1 << 4
    static let RedLine : UInt32 = 0x1 << 5
    static let BlueLine : UInt32 = 0x1 << 6
    static let GreenLine : UInt32 = 0x1 << 7
    static let YellowLine : UInt32 = 0x1 << 8
}

// Declare the class for variable

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Declare type for Ball
    var redBall = SKSpriteNode()
    var blueBall = SKSpriteNode()
    var yellowBall = SKSpriteNode()
    var greenBall = SKSpriteNode()
    
    // Declare type for energy line
    var redLine = SKSpriteNode()
    var blueLine = SKSpriteNode()
    var yellowLine = SKSpriteNode()
    var greenLine = SKSpriteNode()
    
    // Declare empty node for ball and energy line, highscore and instruction for UI/UX
    var ballNode = SKNode()
    var lineNode = SKNode()
    var scoreLabel = SKLabelNode()
    var tapToPlay = SKLabelNode()
    var highScoreLabel = SKLabelNode()
    
    var restartButton = SKSpriteNode()
    
    var rightRotation = SKSpriteNode()
    var leftRotation = SKSpriteNode()
    var died = Bool()
    var currentScore = 0
    var highScore = 0
    var gameStarted = Bool()
    
    var soundManager = SoundManager()
    
    //Create initial scene
    func createScene() {
        
        self.physicsWorld.contactDelegate = self
        
        if let particles = SKEmitterNode(fileNamed: "Magic") {
            
            particles.position = CGPoint(x: 0, y: 0)
            particles.zPosition = -1
            addChild(particles)
            
        }
        
        let highScoreDefault = UserDefaults.standard
        
        if highScoreDefault.value(forKey: "Best") != nil {
            
            highScore = highScoreDefault.value(forKey: "Best") as! Int
            
        }
        
        // Run the score
        scoreLabel.position = CGPoint(x: 0, y: self.frame.height/2-250)
        scoreLabel.text = "\(currentScore)"
        scoreLabel.zPosition = 5
        scoreLabel.fontSize = 100
        scoreLabel.fontName = "Super Mario 256"
        //scoreLabel.fontName = "Papyrus"
        scoreLabel.fontColor = UIColor.white
        self.addChild(scoreLabel)
        
        
        // Tap to play instruction:
        tapToPlay.position = CGPoint(x: 0, y: 100 - self.frame.height/4)
        tapToPlay.text = "Rotate the Ball to match the EnergyLine's color"
        tapToPlay.zPosition = 10
        tapToPlay.fontSize = 17
        tapToPlay.fontName = "Super Mario 256"
        tapToPlay.fontColor = UIColor.white
        self.addChild(tapToPlay)
        
        Ball()
        rotateLeft()
        rotateRight()

    }
    
    override func didMove(to view: SKView) {
        createScene()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameStarted == false {
            // Reset the gameStarted variable
            soundManager.playSound()
            //playSoundGame()
            gameStarted = true
            let spawnLine = SKAction.run({
                () in
                self.line()
            })
            let removeLine = SKAction.removeFromParent()
            let delayLine = SKAction.wait(forDuration: 0.8)
            let sequenceLine = SKAction.sequence([spawnLine, removeLine,delayLine])
            let runLine = SKAction.repeatForever(sequenceLine)
            
            self.run(runLine)
            tapToPlay.removeFromParent()
        }
        else {
            if died == true {
                self.removeAllActions()
            }
            else {
                
            }
        }
        
        for touch in touches {
            let location = touch.location(in: self)
            
            if leftRotation.contains(location) {
                let rotateToLeft = SKAction.rotate(byAngle: 0.5 * .pi, duration: 0.3)
                ballNode.run(rotateToLeft)
            }
            
            if rightRotation.contains(location) {
                let rotateToRight = SKAction.rotate(byAngle:  0.5 * (-.pi), duration: 0.3)
                ballNode.run(rotateToRight)
            }
            
            if died == true {
                if restartButton.contains(location) {
                    self.removeAllActions()
                    soundManager.audioPlayer?.stop()
                    restartScene()
                    
                }
            }
            else {
                
            }
        }
        
    }
    
    func Ball() {
        
        // Add Physics Properties and initial location for balls
        ballNode = SKNode()
        redBall = SKSpriteNode(imageNamed: "redball")
        blueBall = SKSpriteNode(imageNamed: "blueball")
        yellowBall = SKSpriteNode(imageNamed: "yellowball")
        greenBall = SKSpriteNode(imageNamed: "greenball")

        let ballArray = [redBall,blueBall,yellowBall,greenBall]
        
        redBall.setScale(0.4)
        blueBall.setScale(0.4)
        yellowBall.setScale(0.4)
        greenBall.setScale(0.4)
        
        redBall.position = CGPoint(x: -30, y: 0)
        blueBall.position = CGPoint(x: 30, y: 0)
        yellowBall.position = CGPoint(x: 0, y: 30)
        greenBall.position = CGPoint(x: 0, y: -30)
        
        // Add physics - creating a physics body before assigning a category bitmask
        for i in 0...3 {
            ballArray[i].physicsBody = SKPhysicsBody(circleOfRadius: 20)
        }
        
        ballArray[0].physicsBody?.categoryBitMask = gamePhysics.RedBall
        ballArray[1].physicsBody?.categoryBitMask = gamePhysics.BlueBall
        ballArray[2].physicsBody?.categoryBitMask = gamePhysics.YellowBall
        ballArray[3].physicsBody?.categoryBitMask = gamePhysics.GreenBall
        
        for i in 0...3 {
            ballArray[i].physicsBody?.collisionBitMask = gamePhysics.RedLine | gamePhysics.BlueLine | gamePhysics.YellowLine | gamePhysics.GreenLine
            ballArray[i].physicsBody?.contactTestBitMask = gamePhysics.RedLine | gamePhysics.BlueLine | gamePhysics.YellowLine | gamePhysics.GreenLine
            ballArray[i].physicsBody?.affectedByGravity = false
            ballArray[i].physicsBody?.isDynamic = false
        }
        
        ballNode.addChild(redBall)
        ballNode.addChild(greenBall)
        ballNode.addChild(yellowBall)
        ballNode.addChild(blueBall)
        
        self.addChild(ballNode)
    }
    
    // Add Physics Properties and initial location for lines
    func line() {
        
        lineNode = SKNode()
        redLine = SKSpriteNode(imageNamed: "redline")
        blueLine = SKSpriteNode(imageNamed: "blueline")
        yellowLine = SKSpriteNode(imageNamed: "yellowline")
        greenLine = SKSpriteNode(imageNamed: "greenline")
        
        redLine.name = "line"
        blueLine.name = "line"
        yellowLine.name = "line"
        greenLine.name = "line"
        
        let lineArray = [redLine,blueLine,yellowLine,greenLine]
        
        // Add physics for lines
        for i in 0...3 {
            lineArray[i].physicsBody = SKPhysicsBody(circleOfRadius: 10)
        }
        
        lineArray[0].physicsBody?.categoryBitMask = gamePhysics.RedLine
        lineArray[1].physicsBody?.categoryBitMask = gamePhysics.BlueLine
        lineArray[2].physicsBody?.categoryBitMask = gamePhysics.YellowLine
        lineArray[3].physicsBody?.categoryBitMask = gamePhysics.GreenLine
        
        for i in 0...3 {
            lineArray[i].physicsBody?.collisionBitMask = gamePhysics.RedBall | gamePhysics.BlueBall | gamePhysics.YellowBall | gamePhysics.GreenBall
            lineArray[i].physicsBody?.contactTestBitMask = gamePhysics.RedBall | gamePhysics.BlueBall | gamePhysics.YellowBall | gamePhysics.GreenBall
            lineArray[i].physicsBody?.affectedByGravity = false
            lineArray[i].physicsBody?.isDynamic = true
        }
        
        // Move line accross the map
        let randomLine:SKSpriteNode! = lineArray.randomElement()
        randomLine.name = "line"
        let positionCoordinate = [[0,600],[600,0],[0,-600],[-600,0]]
        
        let linePosition = positionCoordinate.randomElement()
        let xCoordinate:Int = linePosition![0]
        let yCoordinate:Int = linePosition![1]
        
        lineNode.addChild(randomLine)
        self.addChild(lineNode)
        
        // Create random line at random appointed locations
        randomLine.position = CGPoint(x: xCoordinate, y: yCoordinate)
        if xCoordinate == 0 {
            randomLine.size = CGSize(width: 1000, height: 10)
        }
        else {
            randomLine.size = CGSize(width: 10, height: 1300)
        }
        let dx:Int! = 0 - xCoordinate
        let dy:Int! = 0 - yCoordinate
        
        let moveLine = SKAction.move(by: CGVector(dx: dx, dy: dy), duration: 2)
        let delay = SKAction.wait(forDuration: 0.3)
        let removeLine = SKAction.removeFromParent()
        
        randomLine.run(SKAction.sequence([moveLine,delay,removeLine]))
    }
    
    // Create a button to rotate the balls 90 degree counter clockwise
    func rotateLeft() {
        leftRotation = SKSpriteNode(imageNamed: "rotateleft")
        leftRotation.setScale(1)
        leftRotation.position = CGPoint(x: 0 - self.frame.size.width/2 + 150, y: 0 - self.frame.size.height/4)
        leftRotation.zPosition = 5
        leftRotation.alpha = 0.5
        self.addChild(leftRotation)
    }
    
    // Create a button to rotate the balls 90 degree clockwise
    func rotateRight() {
        rightRotation = SKSpriteNode(imageNamed: "rotateright")
        rightRotation.setScale(1)
        rightRotation.position = CGPoint(x: self.frame.size.width/2 - 150, y: 0 - self.frame.size.height/4)
        rightRotation.zPosition = 5
        rightRotation.alpha = 0.5
        self.addChild(rightRotation)
    }
    
    // Function to start game when tap
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        //Detect what will happen if lines collide with balls
        if (firstBody.categoryBitMask == gamePhysics.RedBall && secondBody.categoryBitMask == gamePhysics.RedLine) || (firstBody.categoryBitMask == gamePhysics.BlueBall && secondBody.categoryBitMask == gamePhysics.BlueLine) || (firstBody.categoryBitMask == gamePhysics.YellowBall && secondBody.categoryBitMask == gamePhysics.YellowLine) || (firstBody.categoryBitMask == gamePhysics.GreenBall && secondBody.categoryBitMask == gamePhysics.GreenLine) {
            
            currentScore += 1
            secondBody.node?.removeFromParent()
            scoreLabel.text = "\(currentScore)"
            
        } else if (firstBody.categoryBitMask == gamePhysics.RedLine && secondBody.categoryBitMask == gamePhysics.RedBall) || (firstBody.categoryBitMask == gamePhysics.BlueLine && secondBody.categoryBitMask == gamePhysics.BlueBall) || (firstBody.categoryBitMask == gamePhysics.YellowLine && secondBody.categoryBitMask == gamePhysics.YellowBall) || (firstBody.categoryBitMask == gamePhysics.GreenLine && secondBody.categoryBitMask == gamePhysics.GreenBall) {
            
            currentScore += 1
            firstBody.node?.removeFromParent()
            scoreLabel.text = "\(currentScore)"
            
        } else {
            if died == false {
                died = true
                self.removeAllActions()
                ballNode.removeFromParent()
                createButton()
            }
        }
    }
    
    // Create a "restart" button and show high score
    func createButton() {
        
        restartButton = SKSpriteNode(imageNamed: "restart")
        restartButton.size = CGSize(width: 200, height: 200)
        restartButton.position = CGPoint(x: 0, y: 0)
        restartButton.zPosition = 8
        restartButton.setScale(0)
        self.addChild(restartButton)
        restartButton.run(SKAction.scale(to: 1.0, duration: 0.3))
        trackHighScore()
    }
    
    // Reset when restart the game
    func restartScene() {
        
        self.removeAllActions()
        self.removeAllChildren()
        died = false
        gameStarted = false
        createScene()
        
    }
    
    // Track highscore function
    func trackHighScore() {
        if currentScore > highScore {
            highScore = currentScore
            let highScoreDefault = UserDefaults.standard
            highScoreDefault.set(highScore, forKey: "Best")
            highScoreDefault.synchronize()
        }
        
        highScoreLabel.position = CGPoint(x: 0, y: self.frame.height/5 - 150)
        highScoreLabel.text = NSString(format: "Best: \(highScore)" as NSString, highScore) as String
        highScoreLabel.zPosition = 5
        highScoreLabel.fontSize = 100
        highScoreLabel.fontName = "Super Mario 256"
        highScoreLabel.fontColor = UIColor.white
        self.addChild(highScoreLabel)
        currentScore = 0
        return
    }
    
}
