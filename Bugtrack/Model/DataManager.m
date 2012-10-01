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
{
    NSUserDefaults *userDefaults;
}
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

- (BOOL) isDataAvailable {
    return [userDefaults boolForKey:@"Saved"];
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

- (NSString*) getPassword {
    return self.loginData.password;
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

- (void) setPassword:(NSString *)password {
    self.loginData.password = password;
}
- (void) save {
    NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:self.loginData];
    [userDefaults setObject:encodedData forKey:@"data"];
    [userDefaults setBool:YES forKey:@"Saved"];
    [userDefaults synchronize];

}

- (void)dealloc {
   }
@end
