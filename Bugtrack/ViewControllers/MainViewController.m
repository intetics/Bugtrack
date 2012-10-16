//
//  MainViewController.m
//  Bugtrack
//
//  Created by Ilia Akgaev on 9/25/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import "UITableView+NXEmptyView.h"
#import "MainViewController.h"
#import "LoginViewController.h"
#import "NetworkManager.h"
#import "DataManager.h"
#import "MBProgressHUD.h"
#import "Project.h"
#import "Issue.h"
#import "DetailViewController.h"
#import "MBProgressHUD.h"

@interface MainViewController ()
@property (weak, nonatomic) NSArray *projects;
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
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
    [[DataManager sharedManager] getData];
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    NSString *prodName = [info objectForKey:@"CFBundleDisplayName"];
    self.title = prodName;
    if (!self.projects) {
        [[DataManager sharedManager] getData];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading";
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma nark - Memory
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.currentProject) {
        return 1;
    }
    return [self.projects count];
}

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.currentProject) {
        return [[self.currentProject issues] count];
    }
    return [[[self.projects objectAtIndex:section] issues] count];
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (self.currentProject) {
        return self.currentProject.title;
    }
    return [[self.projects objectAtIndex:section] title];
}

//TODO: rewrite
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    Issue *issue;
    if (self.currentProject) {
        issue = [self.currentProject.issues objectAtIndex:indexPath.row];
    } else {
        Project* project = [self.projects objectAtIndex:indexPath.section];
        issue = [project.issues objectAtIndex:indexPath.row];
        
    }
    NetworkManager *sharedNetworkManger = [NetworkManager sharedClient];
    cell.detailTextLabel.text = issue.key;
    if (issue.title) {
        cell.textLabel.text = issue.title;
        return cell;
    }
    
    issue.title = @"Loading...                                                ";
    cell.textLabel.text = issue.title;
    [sharedNetworkManger getDetailedIssueInfo:issue
                                      success:^(id response){
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              cell.textLabel.text = issue.title;
                                          });
                                      }
                                   andFailure:^(NSError* error){
                                   }];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    Issue *issue;
    if (self.currentProject) {
        issue = [self.currentProject.issues objectAtIndex:indexPath.row];
    } else {
        Project* project = [self.projects objectAtIndex:indexPath.section];
        issue = [project.issues objectAtIndex:indexPath.row];
    }
    detailViewController.issue = issue;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - NSNotification

- (void) recieveNotification:(NSNotification*) notification{
    self.projects = [[DataManager sharedManager] projects];
    [self.tableView reloadData];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

@end
