//
//  DataManager.h
//  Bugtrack
//
//  Created by Ilia Akgaev on 10/1/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject
@property (strong, nonatomic) NSArray* allProjects;
@property (strong, nonatomic) NSArray* projects;

+ (id) sharedManager;
- (void) getData;
- (void) dropData;
@end
