//
//  GameScene.swift
//  FlappyBird
//
//  Created by 田中舜一 on 2016/08/08.
//  Copyright © 2016年 田中舜一. All rights reserved.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scrollNode:SKNode!
    var wallNode:SKNode!
    var bird:SKSpriteNode!
    
    let birdCategory: UInt32 = 1 << 0
    let groundCategory:UInt32 = 1 << 1
    let wallCategory:UInt32 = 1 << 2
    let scoreCategory:UInt32 = 1 << 3
    
    var score = 0
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    override func didMoveToView(view: SKView) {
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -4.0)
        physicsWorld.contactDelegate = self
        
        backgroundColor = UIColor(colorLiteralRed:0.15,green:0.75,blue:0.9,alpha: 1)
        
        scrollNode = SKNode()
        addChild(scrollNode)
        
        wallNode = SKNode()
        addChild(wallNode)
        
        bird = SKSpriteNode()
        addChild(bird)
        
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupScrollLabel()
    }
    
    func setupGround() {
    
        let groundTexture = SKTexture(imageNamed:"ground")
        groundTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        let needNumber = 2.0 + (frame.size.width/groundTexture.size().width)
        
        let moveGround = SKAction.moveByX(-groundTexture.size().width, y:0, duration: 5.0)
        
        let resetGround = SKAction.moveByX(groundTexture.size().width,y:0,duration: 0.0)
        
        let repeatScrollGround = SKAction.repeatActionForever(SKAction.sequence([moveGround,resetGround]))
        
        CGFloat(0).stride(to: needNumber, by: 1.0).forEach { i in
            let sprite = SKSpriteNode(texture: groundTexture)
            
            sprite.position = CGPoint(x:i * sprite.size.width,y:groundTexture.size().height/2)
            
            sprite.runAction(repeatScrollGround)
            
            sprite.physicsBody = SKPhysicsBody(rectangleOfSize: groundTexture.size())
            
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            sprite.physicsBody?.dynamic = false
            
            scrollNode.addChild(sprite)
            
        }
        //let groundSprite = SKSpriteNode(texture: groundTexture)
        
        //groundSprite.position = CGPoint(x:size.width/2 ,y:groundTexture.size().height/2)
        
        //addChild(groundSprite)
    }
    
    func setupCloud() {
        
        let cloudTexture = SKTexture(imageNamed:"cloud")
        cloudTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        let needCloudNumber = 2.0 + (frame.size.width / cloudTexture.size().width)
        
        let moveCloud = SKAction.moveByX(-cloudTexture.size().width, y: 0, duration: 20.0)
        
        let resetCloud = SKAction.moveByX(cloudTexture.size().width, y: 0, duration: 0.0)
        
        let repeatScrollCloud = SKAction.repeatActionForever(SKAction.sequence([moveCloud, resetCloud]))

        
        CGFloat(0).stride(to: needCloudNumber, by: 1.0).forEach{ i in
            let sprite = SKSpriteNode(texture: cloudTexture)
            
            sprite.zPosition = -100
            
            sprite.position = CGPoint(x: i * sprite.size.width, y: size.height - cloudTexture.size().height/2)
            
            sprite.runAction(repeatScrollCloud)
            
            scrollNode.addChild(sprite)
        }
    }
    
    func setupWall() {
        
        let wallTexture = SKTexture(imageNamed:"wall")
        wallTexture.filteringMode = .Linear
        
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width*2)
        
        let moveWall = SKAction.moveByX(-movingDistance, y: 0.0, duration: 4.0)
        
        let removeWall = SKAction.removeFromParent()
        
        let wallAnimation = SKAction.sequence([moveWall,removeWall])
        
        let createWallAnimation = SKAction.runBlock({
            
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width*2, y: 0.0)
            wall.zPosition = -50
            
            let center_y = self.frame.size.height/2
            
            let random_y_range = self.frame.size.height / 4
            
            let under_wall_lowest_y = UInt32( center_y - wallTexture.size().height / 2 -  random_y_range / 2)
            
            let random_y = arc4random_uniform(UInt32(random_y_range))
            
            let under_wall_y = CGFloat(under_wall_lowest_y + random_y)
            
            let slit_length = self.frame.size.width / 4
            
            
            //under Wall Create
            let under = SKSpriteNode(texture: wallTexture)
            
            under.position = CGPoint(x: 0.0, y: under_wall_y)
            wall.addChild(under)
            
            under.physicsBody = SKPhysicsBody(rectangleOfSize: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            
            under.physicsBody?.dynamic = false
            
            //upper Wall Create
            let upper = SKSpriteNode(texture: wallTexture)
            
            upper.position = CGPoint(x: 0.0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            upper.physicsBody = SKPhysicsBody(rectangleOfSize: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory
            
            upper.physicsBody?.dynamic = false
            
            wall.addChild(upper)
            
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + self.bird.size.width / 2, y: self.frame.height / 2)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width:upper.size.width,height:self.frame.size.height))
            scoreNode.physicsBody?.dynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(scoreNode)
            
            wall.runAction(wallAnimation)
            
            self.wallNode?.addChild(wall)
            
        })
        
        let waitAnimation = SKAction.waitForDuration(2)
        
        let repeatForeverAnimation = SKAction.repeatActionForever(SKAction.sequence([createWallAnimation,waitAnimation]))
        
        runAction(repeatForeverAnimation)
        
    }
    
    
    func setupBird() {
        let birdTextureA = SKTexture(imageNamed:"bird_a")
        birdTextureA.filteringMode = SKTextureFilteringMode.Linear
        let birdTextureB = SKTexture(imageNamed:"bird_b")
        birdTextureB.filteringMode = SKTextureFilteringMode.Linear
        
        let texturesAnimation = SKAction.animateWithTextures([birdTextureA,birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatActionForever(texturesAnimation)
        
        bird = SKSpriteNode(texture:birdTextureA)
        bird.position = CGPoint(x: 30, y: self.frame.size.height * 0.7)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/2.0)
        
        bird.physicsBody?.allowsRotation = false
        
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory
        
        bird.runAction(flap)
        
        addChild(bird)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if scrollNode.speed > 0{
            
            // 鳥の速度をゼロにする
            bird.physicsBody?.velocity = CGVector.zero
            
            // 鳥に縦方向の力を与える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        } else if bird.speed == 0{
            restart()
        }
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if scrollNode.speed <= 0 {
            return
        }
        
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory{
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"
            
            var bestScore = userDefaults.integerForKey("Best")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"
                userDefaults.setInteger(bestScore,forKey:"Best")
                userDefaults.synchronize()
            }
            
            
        } else{
            print("GameOver")
            scrollNode.speed = 0
            
            bird.physicsBody?.collisionBitMask = groundCategory
            
            let roll = SKAction.rotateByAngle(CGFloat(M_PI) * CGFloat(bird.position.y) * 0.01, duration: 1)
            bird.runAction(roll,completion: {
                self.bird.speed = 0
            })
            
        }
    }
    
    func restart(){
        score = 0
        scoreLabelNode.text = String("Score:\(score)")
        
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0.0
        
        wallNode.removeAllChildren()
        
        bird.speed = 1
        scrollNode.speed = 1
        
    }
    
    func setupScrollLabel(){
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.blackColor()
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 30)
        scoreLabelNode.zPosition = 100 // 一番手前に表示する
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.blackColor()
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        bestScoreLabelNode.zPosition = 100 // 一番手前に表示する
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        
        let bestScore = userDefaults.integerForKey("BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
    }
    
    
}






