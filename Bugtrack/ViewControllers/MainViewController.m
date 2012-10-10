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
    // Do any additional setup after loading the view from its nib.
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    return [self.projects count];
}

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
   return [[[self.projects objectAtIndex:section] issues] count];
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [[self.projects objectAtIndex:section] title];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    Project* project = [self.projects objectAtIndex:indexPath.section];
    Issue* issue = [project.issues objectAtIndex:indexPath.row];
    NetworkManager *sharedNetworkManger = [NetworkManager sharedClient];
    __block NSDictionary *issueInfo;
    cell.textLabel.text = @"Loading                                                                   ";
    [sharedNetworkManger getDetailedIssueInfo:issue
                                      success:^(id response){
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              issueInfo = response;
                                              cell.textLabel.text = issue.title;
                                          });
                                      }
                                   andFailure:^(NSError* error){
                                   }];
    
    cell.detailTextLabel.text = issue.key;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    Project* project = [self.projects objectAtIndex:indexPath.section];
    Issue* issue = [project.issues objectAtIndex:indexPath.row];
    detailViewController.issue = issue;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - NSNotification

- (void) recieveNotification:(NSNotification*) notification{
    self.projects = [[DataManager sharedManager] projects];
    [self.tableView reloadData];
}

@end
