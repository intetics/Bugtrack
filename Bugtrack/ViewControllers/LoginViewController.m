//
//  LoginViewController.m
//  Bugtrack
//
//  Created by Ilia Akgaev on 9/25/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import "LoginViewController.h"
#import "NetworkManager.h"
#import "DataManager.h"
#import "AppDelegate.h"

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
    self.loginButton.enabled = NO;
    [self hideLoginForm:YES];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
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

//TODO: after testing move it right into compl. block
- (void) successfullLogin {
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate loginFinished];
}


@end
