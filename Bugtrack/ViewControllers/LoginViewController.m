//
//  LoginViewController.m
//  Bugtrack
//
//  Created by Ilia Akgaev on 9/25/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import "LoginViewController.h"
#import "AFNetworking.h"
#import "../Model/config.h"
#import "NetworkManager.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize userName;
@synthesize userPassword;
@synthesize baseURL;
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

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

//FIXME: Login via NetworkManager, not in this method. Also store credentials in some kind of user manager (or etc.) but not in NSUserDefaults
//
- (IBAction)performLogin:(id)sender {
    
    NSString *username = self.userName.text;
    NSString *password = self.userPassword.text;
    NSMutableString *baseurl = [@"https://" mutableCopy];
    [baseurl appendString:[self.baseURL.text mutableCopy]];    
    [baseurl appendString:@"/rest/"];    
    
    NetworkManager *networkManager = [NetworkManager sharedClient];
    [networkManager setBaseURL:baseurl];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:username forKey:@"username"];
    [userDefaults synchronize];

    
    [networkManager loginWithUsername:username
                          andPassword:password
                              success:^(id response){
                                  [self.delegate modalViewControllerWillDismiss];
                                  [self dismissModalViewControllerAnimated:YES];
                              }
                              failure:^(NSError* error){
                                  NSLog(@"%s %d \n%s \n%s \n Failed: %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__, error);
                                  
                              }];
}
@end
