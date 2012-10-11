//
//  NetworkManager.h
//  Bugtrack
//
//  Created by Ilia Akgaev on 9/26/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Issue;

@interface NetworkManager : NSObject

+ (id)sharedClient;
+ (NSDictionary*) getAccount;
- (void) setBaseURL:(NSString*)baseURL;
- (void) loginWithUsername:(NSString*)username andPassword:(NSString*) password success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure;
- (void) logoutWithCompletitionsBlocksForSuccess:(void(^)(id response))success failure:(void(^)(NSError *error))failure;
- (void) getAllIssuesForCurrentUserWithSuccess:(void (^)(id response))success andFailure:(void (^)(NSError* error))failure;
- (void) getDetailedIssueInfo:(Issue *)issue success:(void (^)(id response))success andFailure:(void (^)(NSError* error))failure;
- (void) getProjectsWithCompletitionBlocksForSuccess:(void (^)(id response))success andFailure:(void (^)(NSError* error))failure;
- (BOOL) isCoockieValidSuccess:(void(^)(id response))success failure:(void(^)(NSError *error))failure ;
- (void) getIssuesForUser:(NSString*)user inProjectWithKey:(NSString*)projectKey withSucces:(void(^)(id response))success;
- (NSString *) cleanStringURL:(NSString *)stringURL;
- (void) reset;
@end
