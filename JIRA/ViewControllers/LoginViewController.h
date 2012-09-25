//
//  LoginViewController.h
//  JIRA
//
//  Created by Ilia Akgaev on 9/25/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userPassword;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)performLogin:(id)sender;
@end
