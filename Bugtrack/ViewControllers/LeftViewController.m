//
//  LeftViewController.m
//  Bugtrack
//
//  Created by Ilia Akgaev on 10/2/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import "LeftViewController.h"
#import "AppDelegate.h"
#import "JASidePanelController.h"
#import "UITableView+NXEmptyView.h"
#import "Project.h"
#import "DataManager.h"


@interface LeftViewController ()
@property (weak, nonatomic) NSArray *projects;
@end

@implementation LeftViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveNotification:) name:@"BT_PROJECTS_HERE" object:nil];
    }
    return self;
}

#pragma mark - UIViewController

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
    return [self.projects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    Project* project = [self.projects objectAtIndex:indexPath.row];
    cell.textLabel.text = project.title;
    // Configure the cell...
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.viewController showCenterPanel:YES];
}

#pragma mark - Notification handling
- (void) recieveNotification:(NSNotification *)notification {
    self.projects = [[DataManager sharedManager] allProjects];
    [self.tableView reloadData];
}
@end
