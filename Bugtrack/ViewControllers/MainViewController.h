//
//  MainViewController.h
//  Bugtrack
//
//  Created by Ilia Akgaev on 9/25/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Project;

@interface MainViewController : UITableViewController
@property (weak, nonatomic) Project* currentProject;
- (void) recieveNotification:(NSNotification*) notification;
@end
