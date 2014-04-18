//
//  MyScene.m
//  test
//
//  Created by Tim on 26/02/2014.
//  Copyright (c) 2014 edu.fontys.sm. All rights reserved.
//

#import "MyScene.h"

static const uint32_t playerCategory = 0x1 << 0;
static const uint32_t orbCategory = 0x1 << 1;

static float BG_VELOCITY = 100.0;
static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}

@implementation MyScene

/**
 The action that defines a move up motion
 */
SKAction *actionMoveUp;

/**
 The action that defines a move down motion
 */
SKAction *actionMoveDown;

/**
 Holds the time when a last update has happened
 */
NSTimeInterval _lastUpdateTime;

/**
 Holds the time of one tick (1/FPS)
 */
NSTimeInterval _dt;

/**
 Holds the time when the last orb was added
 */
NSTimeInterval _lastOrbAdded;

/**
 Determines the orb respawn time
 */
static float timeRequired = 1.0;

/**
 The player object (the bird)
 */
SKSpriteNode* player;

/**
 Animation frames of the bird sprite
 */
NSArray* playerAnimationFrames;

/**
 Animation frames of the orb sprite
 */
NSArray* orbOrangeAnimationFrames;

/**
 A label that holds the static string value "Score:"
 */
SKLabelNode* scoreLabel;

/**
 A label that holds the current score of the player
 */
SKLabelNode* scoreLabel_;

/**
 A label that holds the static string value "Hardcore!"
 */
SKLabelNode* comboLabel;

/**
 A label that holds the string "Combo Counter: " followed by the current score
 */
SKLabelNode* comboCounter;

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.gameIsActive = NO; //The game is not active yet until the player has told otherwise
        timeRequired = 1.0; //Reset the timeRequired back to 1 second
        
        self.combo = [[Combo alloc] init];
        [self.combo addObserver:self forKeyPath:@"combo" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil]; //Observe value changes of the combo object
        
        
        self.backgroundColor = [SKColor whiteColor];
        
        // Setup all the labels!
        
        scoreLabel_ = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
        scoreLabel_.text = @"Score:";
        scoreLabel_.fontSize = 74;
        scoreLabel_.fontColor = [SKColor whiteColor];
        scoreLabel_.position = CGPointMake(CGRectGetMaxX(self.frame) - 300, 20);
        scoreLabel_.name = @"label";
        
        scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
        scoreLabel.text = @"0";
        scoreLabel.fontSize = 74;
        scoreLabel.fontColor = [SKColor whiteColor];
        scoreLabel.position = CGPointMake(CGRectGetMaxX(self.frame) - 100, 20);
        scoreLabel.name = @"label";
        
        comboLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
        comboLabel.text = @"Hardcore!";
        comboLabel.fontSize = 100;
        comboLabel.fontColor = [SKColor redColor];
        comboLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [comboLabel setAlpha:0.0];
        
        comboCounter = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
        comboCounter.text = @"Combo Counter: 0x";
        comboCounter.fontSize = 45;
        comboCounter.fontColor = [SKColor purpleColor];
        comboCounter.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - 50);
        
        [self initalizingScrollingBackground];
        
        playerAnimationFrames = [self getAnimationFrames:@"flyfly"];
        
        [self addPlayer];
        
        orbOrangeAnimationFrames = [self getAnimationFrames:@"orbOrange"];
        
        [self addChild:scoreLabel_];
        [self addChild:scoreLabel];
        [self addChild:comboLabel];
        [self addChild:comboCounter];
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self; //Add the contactdelegate to self to enable collision detection on this scene
    }
    return self;
}

/**
 Initialize and start the game!
 */
-(void) start
{
    //Setup the accelerometer!
    
    self.manager = [[CMMotionManager alloc]init];
    self.manager.accelerometerUpdateInterval = .01;
    
    if ([self.manager isAccelerometerAvailable]) {
        NSOperationQueue* queue = [[NSOperationQueue alloc]init];
        [self.manager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                double x = accelerometerData.acceleration.x;
                double y = accelerometerData.acceleration.y;
                double z = accelerometerData.acceleration.z;
                
                [self movePlayer:x accelerationY:y accelerationZ:z];
            });
        }];
    }

    //Setup the audio players!
    
    NSError* cuteError;
    NSError* hardcoreError;
    NSError* noteError;
    NSURL* cuteUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/flyflycute.mp3", [[NSBundle mainBundle] resourcePath]]];
    NSURL* hardcoreUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/flyflyhardcore.mp3", [[NSBundle mainBundle] resourcePath]]];
    NSURL* noteUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/note.mp3", [[NSBundle mainBundle] resourcePath]]];
    self.cuteAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:cuteUrl error:&cuteError];
    self.cuteAudioPlayer.volume = 1.0;
    [self.cuteAudioPlayer prepareToPlay];
    
    self.hardcoreAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:hardcoreUrl error:&hardcoreError];
    self.hardcoreAudioPlayer.volume = 0.0;
    [self.hardcoreAudioPlayer prepareToPlay];
    
    self.notePickupAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:noteUrl error:&noteError];
    self.notePickupAudioPlayer.volume = 0.4;
    [self.notePickupAudioPlayer prepareToPlay];
    
    if (self.cuteAudioPlayer == nil) {
        NSLog(@"%@",[cuteError description]);
    } else {
        [self.cuteAudioPlayer play];
    }
    
    if (self.notePickupAudioPlayer == nil) {
        NSLog(@"%@",[noteError description]);
    }
    
    if (self.hardcoreAudioPlayer == nil) {
        NSLog(@"%@",[hardcoreError description]);
    } else {
        [self.hardcoreAudioPlayer play];
    }
    
    self.cuteAudioPlayer.delegate = self; //Add a delegate of cuteAudioPlayer to self so the scene can detect when the audio has stopped playing
    
    self.gameIsActive = YES; //The game has started, so the game is active!
    
    [self animatePlayer];
    
    scoreLabel.text = @"0";
}

-(void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (player == self.cuteAudioPlayer) {
        [self gameOver]; //Stop the game!
    }
}

/**
 Play the NotePickup sound
 @warning This method is no longer supported!
 */
-(void) playNotePickupSound {
    [self.notePickupAudioPlayer play];
}

/**
 Adds a bouncy animation to a label and plays it once
 */
-(void) bouncyText:(SKLabelNode*)label {
    [label runAction:[SKAction scaleTo:0.9 duration:0.2] completion:^{
        [label runAction:[SKAction scaleTo:1.1 duration:0.2] completion:^{
            [label runAction:[SKAction scaleTo:1.0 duration:0.2]];
        }];
    }];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // Do things when the combo counter has changed its value
    if ([keyPath isEqualToString:@"combo"]) {
        NSNumber* comboNumber = [change objectForKey:NSKeyValueChangeNewKey];
        NSNumber* comboNumberOld = [change objectForKey:NSKeyValueChangeOldKey];
        int newCombo = [comboNumber intValue];
        int oldCombo = [comboNumberOld intValue];
        comboCounter.text = [NSString stringWithFormat:@"Combo Counter: %dx", newCombo];
        if (newCombo != oldCombo) {
            //The combo has changed its value
            
            [self bouncyText:comboCounter];
        }
        if (newCombo == 0 && oldCombo >= 5) {
            //Transfer from hardcore mode to cute mode
            
            [self changeBackgroundImage:@"background.png"];
            BG_VELOCITY = 100.0;
            timeRequired = 1.0;
            self.hardcoreAudioPlayer.volume = 0.0;
            self.cuteAudioPlayer.volume = 1.0;
        } else if (newCombo == 5 && oldCombo == 4) {
            //Transfer from cute mode to hardcore mode
            
            [self changeBackgroundImage:@"backgroundHardcore.png"];
            BG_VELOCITY = 180.0;
            [comboLabel runAction:[SKAction fadeAlphaTo:1.0 duration:2.0] completion:^{
                [comboLabel runAction:[SKAction fadeAlphaTo:0.0 duration:2.0]];
            }];
            self.hardcoreAudioPlayer.volume = 1.0;
            self.cuteAudioPlayer.volume = 0.0;
        } if (newCombo % 5 == 0 && newCombo > 0) {
            //Increase the speed each time the combo counter is increased by 5
            
            timeRequired *= 0.9;
        }
    }
}

/**
 Change the background image
 @param image The new background image
 */
-(void)changeBackgroundImage:(NSString*)image {
    [self enumerateChildNodesWithName:@"background" usingBlock: ^(SKNode *node, BOOL *stop)
    {
        SKSpriteNode * bg = (SKSpriteNode *) node;
        [bg setTexture:[SKTexture textureWithImage:[UIImage imageNamed:image]]];
    }];
}

/**
 Get the animation frames from the atlas
 @param atlasName The atlas name
 @return An array of SKTextures
 */
-(NSMutableArray*)getAnimationFrames:(NSString*)atlasName {
    NSMutableArray* animationFrames = [NSMutableArray array];
    
    SKTextureAtlas* atlas = [SKTextureAtlas atlasNamed:atlasName];
    NSUInteger numImages = atlas.textureNames.count;
    
    for (int i=1; i <= numImages; i++) {
        NSString* textureName = [NSString alloc];
        textureName = atlasName;
        if (i < 10 && numImages >= 10) {
            textureName = [textureName stringByAppendingFormat:@"0%d", i];
        } else {
            textureName = [textureName stringByAppendingFormat:@"%d", i];
        }
        SKTexture* temp = [atlas textureNamed:textureName];
        [animationFrames addObject:temp];
    }
    return animationFrames;
}

/**
 Move the player by touching the screen. Only for debugging purposes.
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    UITouch* touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self.scene];
    if (touchLocation.y > player.position.y) {
        if (player.position.y < self.frame.size.height - 60) {
            actionMoveUp = [SKAction moveByX:0 y:touchLocation.y - player.position.y duration:0.2];
            
            [player runAction:actionMoveUp];
        }
    } else {
        if (player.position.y > 60) {
            actionMoveDown = [SKAction moveByX:0 y:touchLocation.y - player.position.y duration:0.2];
            [player runAction:actionMoveDown];
        }
    }
}

/**
 Moves the player judged on the accelerometer readings
 @param x The X-acceleration of the accelerometer
 @param y The Y-acceleration of the accelerometer
 @param z The Z-acceleration of the accelerometer
 */
-(void)movePlayer:(double)x accelerationY:(double)y accelerationZ:(double)z {
    if (fabs(y) > 0.2) {
        [player.physicsBody applyForce:CGVectorMake(0, y * 40.0)];
    }
}

/**
 Create two background images alongside eachother
 */
-(void)initalizingScrollingBackground
{
    for (double i = 0.0; i < 2.0; i++) {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"background.png"];
        bg.position = CGPointMake(i * bg.size.width, 0);
        bg.anchorPoint = CGPointZero;
        bg.name = @"background";
        [self addChild:bg];
    }
    
}

/**
 End the game!
 */
- (void)gameOver
{
    self.parentController.score = scoreLabel.text; //Pass the score value over to the parent
    self.gameIsActive = NO; //The game is no longer active
    [self.cuteAudioPlayer stop]; //Stop playing the audio
    [self.hardcoreAudioPlayer stop]; //Stop playing the audio
    [self.manager stopAccelerometerUpdates]; //Stop reading the accelerometer
    [self.parentController showButton]; //Show the game over button
    [self removeOrbs]; //Remove all the orbs off the screen
}

/**
 Initialize the player object and draw it on the screen
 */
- (void)addPlayer
{
    SKTexture* temp = playerAnimationFrames[0];
    player = [SKSpriteNode spriteNodeWithTexture:temp];
    player.position = CGPointMake(80, CGRectGetMidY(self.frame));
    player.name = @"player";
    
    //Adding physics for collision
    player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:player.size];
    player.physicsBody.categoryBitMask = playerCategory;
    player.physicsBody.dynamic = YES;
    player.physicsBody.contactTestBitMask = orbCategory;
    player.physicsBody.collisionBitMask = 0;
    player.physicsBody.usesPreciseCollisionDetection = YES;
    player.physicsBody.mass = 0.03;
    
    [self addChild:player];
}

/**
 Initialize the orb object and draw it on the screen
 @param note The musical note value (no longer supported!)
 */
- (void)addOrb:(NSString*)note
{
    SKTexture* temp = orbOrangeAnimationFrames[0];
    SKSpriteNode* node =[SKSpriteNode spriteNodeWithTexture:temp];
    node.position = CGPointMake(self.frame.size.width + 20, (arc4random() % (int)(self.frame.size.height - 240)) + 120 );
    node.name = @"orb";
    
    node.userData = [NSMutableDictionary dictionary];
    [node.userData setObject:note forKey:@"note"];
    
    //Adding physics for collision
    node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:node.size];
    node.physicsBody.categoryBitMask = orbCategory;
    node.physicsBody.dynamic = YES;
    node.physicsBody.contactTestBitMask = playerCategory;
    node.physicsBody.collisionBitMask = 0;
    node.physicsBody.usesPreciseCollisionDetection = YES;

    [self addChild:node];
    [self animateOrb:node];
}

/**
 Animate the orb
 @param orb The orb to animate
 */
- (void)animateOrb:(SKSpriteNode*)orb
{
    [orb runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:orbOrangeAnimationFrames timePerFrame:0.2f resize:YES restore:YES]] withKey:@"orbingInPlace"];
    
    return;
}

/**
 Animate the player
 */
- (void)animatePlayer
{
    [player runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:playerAnimationFrames timePerFrame:0.1f resize:YES restore:YES]] withKey:@"flyingInPlace"];
    
    return;
}

/**
 Move the background nodes
 */
- (void)moveBg
{
    [self enumerateChildNodesWithName:@"background" usingBlock: ^(SKNode *node, BOOL *stop)
     {
         SKSpriteNode * bg = (SKSpriteNode *) node;
         CGPoint bgVelocity = CGPointMake(-BG_VELOCITY, 0);
         CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity,_dt);
         bg.position = CGPointAdd(bg.position, amtToMove);
         
         //Checks if bg node is completely scrolled of the screen, if yes then put it at the end of the other node
         if (bg.position.x <= -bg.size.width)
         {
             bg.position = CGPointMake(bg.position.x + bg.size.width * 2,
                                       bg.position.y);
         }
     }];
}

/**
 Move the orb nodes
 */
- (void)moveOrb {
    [self enumerateChildNodesWithName:@"orb" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode* orb = (SKSpriteNode*) node;
        
        CGPoint orbVelocity = CGPointMake(-BG_VELOCITY, 0);
        CGPoint amtToMove = CGPointMultiplyScalar(orbVelocity,_dt);
        orb.position = CGPointAdd(orb.position, amtToMove);
        
        //Checks if orb node is completely scrolled of the screen, if yes then reduce the score by 1
        if (orb.position.x <= -orb.size.width)
        {
            [orb removeFromParent];
            self.combo.combo = 0;
            int score = scoreLabel.text.intValue;
            scoreLabel.text = [NSString stringWithFormat:@"%d", score - 1];
            [self bouncyText:scoreLabel];
            [self bouncyText:scoreLabel_];
        }
    }];
}

/**
 Remove all the orbs in the scene
 */
- (void)removeOrbs {
    [self enumerateChildNodesWithName:@"orb" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode* orb = (SKSpriteNode*) node;
        [orb removeFromParent];
    }];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (self.gameIsActive) {
        if (_lastUpdateTime)
        {
            _dt = currentTime - _lastUpdateTime;
        }
        else
        {
            _dt = 0;
        }
        _lastUpdateTime = currentTime;
    
        if (currentTime > 0.5 && currentTime < 1) {
            [self removeOrbs]; //Attempt to solve the weird bug that one orb is placed on the screen when you replay the game. To no avail.
        }
        
        if (currentTime - _lastOrbAdded > timeRequired) {
            _lastOrbAdded = currentTime + timeRequired;

            [self addOrb:@"C"]; //Add a orb to the scene
        }
        [self moveBg];
        [self moveOrb];
        
        if (player.position.y - player.size.height > self.frame.size.height
            || player.position.y + player.size.height < 0) {
            [self gameOver]; //The player has moved off the screen, so game over!
        }
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & playerCategory) != 0 &&
        (secondBody.categoryBitMask & orbCategory) != 0)
    {
        //A player has collided with an orb!
        
        [[secondBody node] removeFromParent];
        self.combo.combo++;
        int score = scoreLabel.text.intValue;
        scoreLabel.text = [NSString stringWithFormat:@"%d", score + 5];
        [self bouncyText:scoreLabel];
        [self bouncyText:scoreLabel_];
        //[self playNotePickupSound];
    }
}

- (void) dealloc
{
    [self.combo removeObserver:self forKeyPath:@"combo"];
}
@end
