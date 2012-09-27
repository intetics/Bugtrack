//
//  NetworkManager.m
//  Bugtrack
//
//  Created by Ilia Akgaev on 9/26/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import "NetworkManager.h"
#import "AFNetworking.h"
#import "config.h"
#import "JSONKit.h"

@interface NetworkManager ()
@property (strong, nonatomic) AFHTTPClient * httpClient;
@property (strong, nonatomic) NSString *baseURL;
@end

@implementation NetworkManager
@synthesize httpClient = _httpClient;

#pragma mark - Init

+ (id)sharedClient {
    static dispatch_once_t onceToken = 0;
    __strong static id __sharedClient = nil;
    dispatch_once(&onceToken, ^{
        __sharedClient = [[self alloc] init];
    });
    return __sharedClient;
}

- (AFHTTPClient *) httpClient {
    if (!_httpClient) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        self.baseURL = [userDefaults objectForKey:@"BASE_URL"];
        _httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:self.baseURL]];
    }
    return _httpClient;
}

#pragma mark - Network


- (void) loginWithUsername:(NSString*)username andPassword:(NSString*) password success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure{
    
    [self.httpClient setAuthorizationHeaderWithUsername:username password:password];
    [self.httpClient getPath:@"serverInfo"
                  parameters:[NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"]
                     success:^(AFHTTPRequestOperation *operation, id response){
                         if (success) {
                             success(response);
                         }
                     }
                     failure:^(AFHTTPRequestOperation *operation, NSError *error){
                         if (failure) {
                             failure(error);
                         }
                     }];
}

//TODO: Make it more generic. Right now it uses assumption that we can pass auth. header in request.
//FIXME:
- (void) getAllIssuesForCurrentUserWithCompletitionBlocksForSuccess:(void (^)(id response))success
                                                         andFailure:(void (^)(NSError* error))failure {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefaults objectForKey:@"username"];
    
    NSString *path = @"search?jql=assignee%3D";
    NSMutableString *fullpath = [path mutableCopy];
    [fullpath appendString:@"\%22"];
    [fullpath appendString:userName];
    [fullpath appendString:@"%22"];
    [fullpath appendString:@"\%20and\%20status\%20in\%20(\%22open\%22,\%22in%20progress\%22,\%22reopened\%22)"];
    
    __block NSDictionary *response;
    [self.httpClient getPath:fullpath
                  parameters:[NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"]
                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                         
                         JSONDecoder* decoder = [[JSONDecoder alloc]
                                                 initWithParseOptions:JKParseOptionNone];
                         response = [decoder objectWithData:responseObject];
                         NSLog(@"We get:%@", response);
                         if (success) {
                             success([response objectForKey:@"issues"]);
                         }
                     }failure:^(AFHTTPRequestOperation *operation, NSError *error){
                         NSLog(@"Error: %@", error);
                         if (failure) {
                             failure(error);
                         }
                     }];
}

- (NSDictionary *) getDetailedIssueInfo:(NSString *)issueURL {
    __block NSDictionary *detailedInfo;
    
    [self.httpClient getPath:[self cleanStringURL:issueURL]
                  parameters:[NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"]
                     success:^(AFHTTPRequestOperation *operation, id response) {
                         JSONDecoder* decoder = [[JSONDecoder alloc]
                                                 initWithParseOptions:JKParseOptionNone];
                         detailedInfo = [decoder objectWithData:response];
                         NSLog(@"Detailed info:%@", detailedInfo);
                     }
                     failure:^(AFHTTPRequestOperation *operation, NSError *error){
                         NSLog(@"Oh god:%@", error);
                     }];
    
    return detailedInfo;
}

#pragma mark - Miscellaneous

//Removes BASE_URL part from url. length++ because we don't need "/" either 
- (NSString *) cleanStringURL:(NSString *)stringURL {
    int length = [self.baseURL length];
//    length++;
    NSString *rightURL = [stringURL substringFromIndex:length];
    return rightURL;
}

@end
