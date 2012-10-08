//
//  DataManager.h
//  Bugtrack
//
//  Created by Ilia Akgaev on 10/1/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginData.h"

@interface DataManager : NSObject

+ (id) sharedManager;
- (BOOL) isDataAvailable;
- (NSHTTPCookie *)getSessionInfo;
- (NSString*) getUserName;
- (NSString*) getBaseURL;
- (NSString*) getPassword;
- (void) setSessionInfo:(NSHTTPCookie*)sessionInfo;
- (void) setUserName:(NSString*)username;
- (void) setBaseURL:(NSString*)baseURL;
- (void) setPassword:(NSString*)password;
- (void) save;
- (void) getData;
@end
