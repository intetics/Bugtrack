//
//  DataManager.m
//  Bugtrack
//
//  Created by Ilia Akgaev on 10/1/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import "DataManager.h"

@interface DataManager()
@property (strong, nonatomic) LoginData *loginData;
@end


@implementation DataManager
@synthesize loginData = _loginData;

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
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if ([userDefaults boolForKey:@"Saved"]) {
            NSData *encodedData = [userDefaults objectForKey:@"data"];
            self.loginData = [NSKeyedUnarchiver unarchiveObjectWithData:encodedData];
        } else {
            _loginData = [[LoginData alloc] init];
        }
    }
    return self;
}

- (NSDictionary*) getSessionInfo {
    return self.loginData.session;
}

- (NSString*) getUserName {
    return self.loginData.username;
}

- (NSString*) getBaseURL {
    return self.loginData.baseurl;
}

- (void) setSessionInfo:(NSDictionary *)sessionInfo {
    self.loginData.session = sessionInfo;
}

- (void) setUserName:(NSString*)username {
    self.loginData.username = username;
}

- (void) setBaseURL:(NSString *)baseURL {
    self.loginData.baseurl = baseURL;
}

- (void) save {
    NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:self.loginData];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:encodedData forKey:@"data"];
    [userDefaults setBool:YES forKey:@"Saved"];
    [userDefaults synchronize];

}

- (void)dealloc {
   }
@end
