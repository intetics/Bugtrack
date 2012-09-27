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

@interface MainViewController ()
@property (strong, nonatomic) NSArray *issues;
@end

@implementation MainViewController

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
    // Do any additional setup after loading the view from its nib.
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    LoginViewController* loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    loginViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    loginViewController.delegate = self;
    [self.navigationController presentModalViewController:loginViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) modalViewControllerWillDismiss {
    NSLog(@"%s %d \n%s \n%s \n Dismissed", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__);
    NetworkManager *networkManager = [NetworkManager sharedClient];
    [networkManager getAllIssuesForCurrentUserWithCompletitionBlocksForSuccess:^(id response){
        self.issues = response;
        [self.tableView reloadData];
    }
                                                                    andFailure:^(NSError *error){
                                                                        NSLog(@"%s %d \n%s \n%s \n Error: %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__, error);
                                                                    }];
    
}

#pragma mark - Table View

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.issues count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    NSString *issueURL = [[self.issues objectAtIndex:indexPath.row] objectForKey:@"self"];
    NetworkManager *sharedNetworkManger = [NetworkManager sharedClient];
    __block NSDictionary *issueInfo;
    [sharedNetworkManger getDetailedIssueInfo:issueURL
                                      success:^(id response){
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              issueInfo = response;
                                              cell.textLabel.text = [[[issueInfo objectForKey:@"fields"] objectForKey:@"summary"] objectForKey:@"value"];
                                          });
                                      }
                                   andFailure:^(NSError* error){
                                   }];
    
    NSString *subTitle = [[self.issues objectAtIndex:indexPath.row] objectForKey:@"key"];
    cell.detailTextLabel.text = subTitle;
    return cell;
}


@end
