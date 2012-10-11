//
//  LeftViewController.m
//  Bugtrack
//
//  Created by Ilia Akgaev on 10/2/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import "LeftViewController.h"
#import "AppDelegate.h"
#import "UITableView+NXEmptyView.h"
#import "Project.h"
#import "DataManager.h"
#import "NetworkManager.h"
#import "SSKeychain.h"

#define MENU_SECTION 0
#define PROJECTS_SECTION 1

enum MenuSection {
    CellAllProjects,
    CellLogout,
    CellCount
};

@interface LeftViewController ()
@property (weak, nonatomic) NSArray *projects;
@end

@implementation LeftViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveNotification:) name:@"BT_ISSUES_HERE" object:nil];
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)  tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == PROJECTS_SECTION) {
        return @"Projects";
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == PROJECTS_SECTION) {
        return [self.projects count];
    }
    return CellCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == MENU_SECTION) {
        return [self prepareMenuCell:indexPath];
    }
    return [self prepareProjectsCell:indexPath];
   }

- (UITableViewCell *) prepareMenuCell:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row == CellAllProjects) {
        cell.textLabel.text = @"All projects";
    } else {
        cell.textLabel.text = @"Logout";
    }
    return cell;

}

- (UITableViewCell *) prepareProjectsCell:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
    if (indexPath.section == MENU_SECTION) {
        [self didSelectMenuRowAtIndexPath:indexPath];
    } else {
        [self didSelectProjectsRowAtIndexPath:indexPath];
    }
}

- (void) didSelectMenuRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == CellLogout) {
        NSDictionary *keychain = [NetworkManager getAccount];
        NetworkManager *manager = [NetworkManager sharedClient];
        [manager logoutWithCompletitionsBlocksForSuccess:^(id response){
            NSError* error;
            [SSKeychain deletePasswordForService:[keychain objectForKey:@"service"] account:[keychain objectForKey:@"username"] error:&error];
            AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
            [[DataManager sharedManager] dropData];
            [delegate showLogin];
        }
                                                 failure:^(NSError *error){
                                                 }];
    }
}

- (void) didSelectProjectsRowAtIndexPath:(NSIndexPath *)indexPath{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    Project* project = [self.projects objectAtIndex:indexPath.row];
    [appDelegate openProjectWithKey:project.key];
}

#pragma mark - Notification handling
- (void) recieveNotification:(NSNotification *)notification {
    self.projects = [[DataManager sharedManager] projects];
    [self.tableView reloadData];
}
@end
