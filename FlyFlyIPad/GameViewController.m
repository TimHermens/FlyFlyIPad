//
//  GameViewController.m
//  FlyFly
//
//  Created by Tim on 26/02/2014.
//  Copyright (c) 2014 edu.fontys.sm. All rights reserved.
//

#import "GameViewController.h"
#import "MyScene.h"
#import "ScoreViewController.h"

@interface GameViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnGameOver;
@property (weak, nonatomic) IBOutlet UIButton *btnStart;

@end

@implementation GameViewController

/**
 Fired when btnStart is clicked on.
 */
- (IBAction)btnStartClicked:(id)sender {
    [self.btnStart setHidden:YES];
    MyScene* scene = (MyScene*) self.skView.scene;
    [scene start];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LaunchImage.png"]]; //Default-Portrait.png
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    //The view controller's view is a SKView
    self.skView = (SKView *)self.view;

    //Create a new MyScene scene on which the game will be displayed
    MyScene * scene = [MyScene sceneWithSize:self.skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    scene.parentController = self;
        
    // Present the scene.
    [self.skView presentScene:scene];

}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

/**
 Show the game over button when the player is game over.
 */
-(void)showButton
{
    [self.btnGameOver setHidden:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"navigateToScore"]) {
        ScoreViewController* cont = [segue destinationViewController];
        cont.score = self.score; //Pass over the value of score property of this view controller to the ScoreViewController
        
        [self.skView.scene removeAllActions]; //Reset the scene of all actions
        [self.skView.scene removeAllChildren]; //Reset the scene of all children
    }
}

@end
