//
//  DetailViewController.m
//  Bugtrack
//
//  Created by Ilia Akgaev on 10/8/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import "DetailViewController.h"
#import "Issue.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

#pragma mark - UIView
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Summary:";
            cell.detailTextLabel.text = self.issue.title;
            break;
        case 1:
            cell.textLabel.text = @"Type:";
            cell.detailTextLabel.text = self.issue.issueType;
            break;
        case 2:
            cell.textLabel.text = @"Priority:";
            cell.detailTextLabel.text = self.issue.priority;
            break;
        case 3:
            cell.textLabel.text = @"Status:";
            cell.detailTextLabel.text = self.issue.status;
            break;
        case 4:
            cell.textLabel.text = @"Assignee:";
            cell.detailTextLabel.text = self.issue.assignee;
            break;
            
        default:
            break;
    }
    return cell;
}

@end
