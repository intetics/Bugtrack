//
//  DetailViewController.h
//  Bugtrack
//
//  Created by Ilia Akgaev on 10/8/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Issue;

@interface DetailViewController : UITableViewController
@property (weak, nonatomic) Issue* issue;
@end
