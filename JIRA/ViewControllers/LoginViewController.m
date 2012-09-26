//
//  LoginViewController.m
//  JIRA
//
//  Created by Ilia Akgaev on 9/25/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import "LoginViewController.h"
#import "AFNetworking.h"
#import "../Model/config.h"

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

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

//FIXME: Login via NetworkManager, not in this method. Also store credentials in some kind of user manager (or etc.) but not in NSUserDefaults
//
- (IBAction)performLogin:(id)sender {
    
    NSString *username = self.userName.text;
    NSString *password = self.userPassword.text;
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    [httpClient setAuthorizationHeaderWithUsername:username password:password];
    [httpClient setParameterEncoding:AFJSONParameterEncoding];
    [httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];

    [httpClient getPath:REQUEST_URL parameters:[NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type:"]
                success:^(AFHTTPRequestOperation *operation, id JSON) {
                    NSLog(@"Success! \n %@", [[NSString alloc] initWithData:JSON encoding:NSUTF8StringEncoding]);
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:username forKey:@"username"];
                    [userDefaults setObject:password forKey:@"passworf"];
                    [self dismissModalViewControllerAnimated:YES];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error){
                    NSLog(@"Failed: %@", error);
                }];
}
@end
