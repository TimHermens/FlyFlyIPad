//
//  GameViewController.h
//  FlyFly
//
//  Created by Tim on 26/02/2014.
//  Copyright (c) 2014 edu.fontys.sm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@interface GameViewController : UIViewController

@property (weak, nonatomic) NSString* score;

@property (weak) SKView* skView;

-(void)showButton;

@end
