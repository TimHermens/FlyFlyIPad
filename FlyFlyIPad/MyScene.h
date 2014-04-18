//
//  MyScene.h
//  test
//

//  Copyright (c) 2014 edu.fontys.sm. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Combo.h"
#import <CoreMotion/CoreMotion.h>

@interface MyScene : SKScene <SKPhysicsContactDelegate, AVAudioPlayerDelegate>

/**
 The view controller that is the parent of this scene
 */
@property (weak, nonatomic) GameViewController* parentController;

/**
 Determines if the game is active or not. If the game is active, animations and movement of all the nodes will be enabled.
 */
@property (nonatomic) BOOL gameIsActive;

/**
 The audio player that plays the cute version of the background music
 */
@property (nonatomic) AVAudioPlayer* cuteAudioPlayer;

/**
 The audio player that plays the hardcore version of the background music
 */
@property (nonatomic) AVAudioPlayer* hardcoreAudioPlayer;

/**
 The audio player that plays the pickup sounds when a orb node is picked up
 @warning This audio player currently isn't used
 */
@property (nonatomic) AVAudioPlayer* notePickupAudioPlayer;

/**
 The object that holds the combo counter value
 */
@property (nonatomic) Combo* combo;

/**
 The motion manager that handles the accelerometer
 */
@property (strong) CMMotionManager* manager;

- (void) movePlayer:(double)x accelerationY:(double)y accelerationZ:(double)z;
- (void) start;
- (void) removeOrbs;

@end
