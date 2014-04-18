//
//  HighscoresTableViewController.m
//  FlyFly
//
//  Created by Tim on 26/02/2014.
//  Copyright (c) 2014 edu.fontys.sm. All rights reserved.
//

#import "HighscoresTableViewController.h"
#import "ScoreObject.h"
#import "AFNetworking.h"
#import "SimpleTableCell.h"

@interface HighscoresTableViewController ()

@end

@implementation HighscoresTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
    self.scores = [NSMutableArray array];
    [self loadJSONData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.scores.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SimpleTableCell";
    SimpleTableCell *cell = (SimpleTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"SimpleTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Configure the cell...
    NSInteger currentRow = indexPath.row;
    ScoreObject* score = [self.scores objectAtIndex:currentRow];
    
    if (currentRow == 0) {
        cell.backgroundColor = [UIColor colorWithRed:201.0/255.0 green:137.0/255.0 blue:16.0/255.0 alpha:0.8]; //gold color for the 1st position
    } else if (currentRow == 1) {
        cell.backgroundColor = [UIColor colorWithRed:168.0/255.0 green:168.0/255.0 blue:168.0/255.0 alpha:0.8]; //silver color for the 2nd position
    } else if (currentRow == 2) {
        cell.backgroundColor = [UIColor colorWithRed:150.0/255.0 green:90.0/255.0 blue:56.0/255.0 alpha:0.8]; //bronze color for the 3rd position
    }
    
    cell.nameLabel.text = score.name; //Allocate the name value in the score object to the nameLabel
    cell.scoreLabel.text = score.score; //Allocate the score value in the score object to the scoreLabel
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 144; //The cell height is 144 pixels
}

/**
 Parse the JSONData and put in the scores array
 */
- (void) parseJSONData:(id)JSON {
    for (NSDictionary* dict in JSON) {
        ScoreObject* score = [[ScoreObject alloc] init];
        score.name = [dict objectForKey:@"name"];
        score.score = [dict objectForKey:@"score"];
        [self.scores addObject:score];
    }
    [self.tableView reloadData];
}

/**
 Load the JSONData from the flyflyscores.json file
 */
- (void) loadJSONData {
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/x-javascript"];
    [manager GET:@"http://athena.fhict.nl/users/i281909/flyflyscores.json" parameters:nil success:^(AFHTTPRequestOperation* operation, id responseObject) {
        [self parseJSONData:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
