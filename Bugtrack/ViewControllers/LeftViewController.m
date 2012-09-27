//
//  LeftViewController.m
//  Bugtrack
//
//  Created by Ilia Akgaev on 9/25/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import "LeftViewController.h"
#import "NetworkManager.h"
@interface LeftViewController ()
@property (strong, nonatomic) NSArray *issues;
@end

@implementation LeftViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NetworkManager *networkManager = [NetworkManager sharedClient];
    [networkManager getAllIssuesForCurrentUserWithCompletitionBlocksForSuccess:^(id response){
        self.issues = response;
        [self.tableView reloadData];
    }
                                                                    andFailure:^(NSError *error){
                                                                        NSLog(@"Error");
                                                                    }];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.issues count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    NSString *title = [[self.issues objectAtIndex:indexPath.row] objectForKey:@"key"];
    cell.textLabel.text = title;
    return cell;
}

@end
