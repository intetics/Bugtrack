//
//  AppDelegate.h
//  Bugtrack
//
//  Created by Ilia Akgaev on 9/25/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JASidePanelController;
@class LoginViewController;
@class Project;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) JASidePanelController *viewController;
@property (strong, nonatomic) LoginViewController *loginViewController;

- (void) loginFinished;
- (void) openProject:(Project *)project;
- (void) showLogin;
@end
