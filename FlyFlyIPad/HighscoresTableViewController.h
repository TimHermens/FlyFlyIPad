//
//  HighscoresTableViewController.h
//  FlyFly
//
//  Created by Tim on 26/02/2014.
//  Copyright (c) 2014 edu.fontys.sm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HighscoresTableViewController : UITableViewController

/**
 The list of highscores
 */
@property NSMutableArray* scores;

- (void) parseJSONData:(id) JSON;
- (void) loadJSONData;

@end
