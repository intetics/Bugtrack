//
//  DataManager.m
//  Bugtrack
//
//  Created by Ilia Akgaev on 10/1/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import "DataManager.h"
#import "NetworkManager.h"
#import "Project.h"

@interface DataManager()
@property (weak, nonatomic) NetworkManager* networkManager;

@end


@implementation DataManager

#pragma mark - Init
+ (id)sharedManager {
    static dispatch_once_t onceToken = 0;
    __strong static id __sharedClient = nil;
    dispatch_once(&onceToken, ^{
        __sharedClient = [[self alloc] init];
    });
    return __sharedClient;
}

#pragma mark - Data loading

- (void) getData {
    [self getProjects];
}
- (void) getProjects {
    self.networkManager = [NetworkManager sharedClient];
    [self.networkManager getProjectsWithCompletitionBlocksForSuccess:^(id projects){
        self.allProjects = projects;
        [self getIssues];
    }
                                              andFailure:^(NSError* error){
                                              }];
}
- (void) getIssues {

    [[NSNotificationCenter defaultCenter] postNotificationName:@"BT_PROJECTS_HERE" object:nil];
    int count = [self.allProjects count];
    __block int blockCount = 1;
    for (Project* project in self.allProjects) {
        [self.networkManager getIssuesForUser:nil inProjectWithKey:project.key withSucces:^(id response) {
            project.issues = response;
            if (blockCount < count)
                blockCount++;
            else {
                [self trimProjects];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"BT_ISSUES_HERE" object:nil];
            }
        }];
    }
}

- (void) trimProjects {
    NSMutableArray* temp = [NSMutableArray array];
    for (Project* project in self.allProjects) {
        if ([project.issues count] > 0) {
            [temp addObject:project];
        }
    }
    self.projects = temp;
}

- (void) dropData {
    self.projects = nil;
    self.allProjects = nil;
    self.networkManager = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BT_PROJECTS_HERE" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BT_ISSUES_HERE" object:nil];
}
@end
