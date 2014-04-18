//
//  ScoreViewController.m
//  FlyFly
//
//  Created by Tim on 26/02/2014.
//  Copyright (c) 2014 edu.fontys.sm. All rights reserved.
//

#import "ScoreViewController.h"

@interface ScoreViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labelScore;

@end

@implementation ScoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.labelScore.text = self.score;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (IBAction)btnSubmitClicked:(id)sender {
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil]; //Go back to the root view
}
@end
