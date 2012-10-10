//
//  LoginViewController.m
//  Bugtrack
//
//  Created by Ilia Akgaev on 9/25/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import "LoginViewController.h"
#import "NetworkManager.h"
#import "AppDelegate.h"
#import "SSKeychain.h"

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark - UIView
- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.loginButton.enabled = NO;
    [self hideLoginForm:YES];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSDictionary* account = [NetworkManager getAccount];
    if (!account) {
        [self hideLoginForm:NO];
        return;
    }
    NetworkManager* networkManager = [NetworkManager sharedClient];
    [networkManager setBaseURL:[account objectForKey:@"service"]];
    
    [networkManager loginWithUsername:[account objectForKey:@"username"]
                          andPassword:[account objectForKey:@"password"]
                              success:^(id response){
                                  [self successfullLogin];
                              }
                              failure:^(NSError* error){
                                  NSLog(@"Error: %@", error);
                                  [self hideLoginForm:NO];
                              }];

    
}

- (void) viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

#pragma mark - IBActions
- (IBAction)performLogin:(id)sender {
    NSString *username = self.userName.text;
    NSString *password = self.userPassword.text;
    NSMutableString *baseurl = [@"https://" mutableCopy];
    [baseurl appendString:[self.baseURL.text mutableCopy]];
    [baseurl appendString:@"/rest/"];
    
    NetworkManager* networkManager = [NetworkManager sharedClient];
    [networkManager setBaseURL:baseurl];
    
    [networkManager loginWithUsername:username andPassword:password
                              success:^(id response){
                                  [SSKeychain setPassword:password forService:baseurl account:username];
                                  [self successfullLogin];
                              }
                              failure:^(NSError* error){
                                  NSLog(@"Error: %@", error);
                              }];
    
}

#pragma mark - Helpers
- (void) hideLoginForm:(BOOL)hide {
    self.userName.hidden = hide;
    self.userPassword.hidden = hide;
    self.baseURL.hidden = hide;
    self.loginButton.hidden = hide;
    self.activityView.hidden = !hide;
    if (hide) {
        [self.activityView startAnimating];
    } else {
        [self.activityView stopAnimating];
    }
}

- (void) successfullLogin {
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate loginFinished];
}


@end
