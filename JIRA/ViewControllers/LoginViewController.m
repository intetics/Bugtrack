//
//  LoginViewController.m
//  JIRA
//
//  Created by Ilia Akgaev on 9/25/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize userName;
@synthesize userPassword;
@synthesize loginButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.loginButton.enabled = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.userName becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidUnload {
    [self setUserName:nil];
    [self setUserPassword:nil];
    [self setLoginButton:nil];
    
    [super viewDidUnload];
}

- (IBAction)performLogin:(id)sender {
    
    NSString *username = self.userName.text;
    NSString *userpassword = self.userPassword.text;
    NSLog(@"Username: %@, password: %@", username, userpassword);
    
}
@end
