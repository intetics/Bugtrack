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
- (NSDictionary *)getSessionInfo;
- (NSString*) getUserName;
- (NSString*) getBaseURL;
- (void) setSessionInfo:(NSDictionary*)sessionInfo;
- (void) setUserName:(NSString*)username;
- (void) setBaseURL:(NSString*)baseURL;
- (void) save;
@end