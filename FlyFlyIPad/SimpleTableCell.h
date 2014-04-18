//
//  SimpleTableCell.h
//  FlyFly
//
//  Created by Tim on 06/04/2014.
//  Copyright (c) 2014 edu.fontys.sm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleTableCell : UITableViewCell

/**
 The label that holds the name of a player
 */
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

/**
 The label that holds the score of a player
 */
@property (nonatomic, weak) IBOutlet UILabel *scoreLabel;

@end
