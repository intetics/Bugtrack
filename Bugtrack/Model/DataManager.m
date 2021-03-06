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
@property (strong, nonatomic) LoginData *loginData;
@property (strong, nonatomic) NSArray* projects;
@property (weak, nonatomic) NetworkManager* networkManager;

@end


@implementation DataManager
{
    NSUserDefaults *userDefaults;
}
@synthesize loginData = _loginData;

#pragma mark - Init
+ (id)sharedManager {
    static dispatch_once_t onceToken = 0;
    __strong static id __sharedClient = nil;
    dispatch_once(&onceToken, ^{
        __sharedClient = [[self alloc] init];
    });
    return __sharedClient;
}

- (id) init {
    if (self = [super init]) {
        userDefaults = [NSUserDefaults standardUserDefaults];
        if ([self isDataAvailable]) {
            NSData *encodedData = [userDefaults objectForKey:@"data"];
            self.loginData = [NSKeyedUnarchiver unarchiveObjectWithData:encodedData];
        } else {
            _loginData = [[LoginData alloc] init];
        }
    }
    return self;
}

#pragma mark - Getters
- (BOOL) isDataAvailable {
    return [userDefaults boolForKey:@"Saved"];
}

- (NSHTTPCookie*) getSessionInfo {
    return self.loginData.session;
}

- (NSString*) getUserName {
    return self.loginData.username;
}

- (NSString*) getBaseURL {
    return self.loginData.baseurl;
}

- (NSString*) getPassword {
    return self.loginData.password;
}

#pragma mark - Setters
- (void) setSessionInfo:(NSHTTPCookie *)sessionInfo {
    self.loginData.session = sessionInfo;
}

- (void) setUserName:(NSString*)username {
    self.loginData.username = username;
}

- (void) setBaseURL:(NSString *)baseURL {
    self.loginData.baseurl = baseURL;
}

- (void) setPassword:(NSString *)password {
    self.loginData.password = password;
}

#pragma mark - Percistence (kind of)
- (void) save {
    NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:self.loginData];
    [userDefaults setObject:encodedData forKey:@"data"];
    [userDefaults setBool:YES forKey:@"Saved"];
    [userDefaults synchronize];

}

#pragma mark - Data loading

- (void) getData {
    [self getProjects];
}
- (void) getProjects {
    self.networkManager = [NetworkManager sharedClient];
    [self.networkManager getProjectsWithCompletitionBlocksForSuccess:^(id projects){
        self.projects = projects;
        [self getIssues];
    }
                                              andFailure:^(NSError* error){
                                              }];
}
- (void) getIssues {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BT_PROJECTS_HERE" object:nil];
    int count = [self.projects count];
    __block int blockCount = 1;
    for (Project* project in self.projects) {
        [self.networkManager getIssuesForUser:nil inProjectWithKey:project.key withSucces:^(id response) {
            project.issues = response;
            if (blockCount < count)
                blockCount++;
            else
                [[NSNotificationCenter defaultCenter] postNotificationName:@"BT_ISSUES_HERE" object:nil];
        }];
    }
}
@end
