//
//  NetworkManager.h
//  Bugtrack
//
//  Created by Ilia Akgaev on 9/26/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject
+ (id)sharedClient;
- (void) setBaseURL:(NSString*)baseURL;
- (void) loginWithUsername:(NSString*)username andPassword:(NSString*) password success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure;
- (void) getAllIssuesForCurrentUserWithSuccess:(void (^)(id response))success andFailure:(void (^)(NSError* error))failure;
- (void) getDetailedIssueInfo:(NSString *)issueURL success:(void (^)(id response))success andFailure:(void (^)(NSError* error))failure;
- (void) getProjectsWithCompletitionBlocksForSuccess:(void (^)(id response))success andFailure:(void (^)(NSError* error))failure;

- (NSString *) cleanStringURL:(NSString *)stringURL;
@end
