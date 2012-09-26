//
//  NetworkManager.m
//  JIRA
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
        _httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    }
    return _httpClient;
}

#pragma mark - Network

//TODO: Implement this method.
- (void) loginWithUsername:(NSString*)username andPassword:(NSString*) password success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure{
}

//TODO: Make it more generic. Right now it uses assumption that we can pass auth. header in request.
//FIXME:
- (NSArray *) getAllIssuesForCurrentUser {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefaults objectForKey:@"username"];
    NSString *password = [userDefaults objectForKey:@"password"];
    
    [self.httpClient setAuthorizationHeaderWithUsername:userName password:password];
    
    NSString *path = @"search?jql=assignee%3D";
    NSMutableString *fullpath = [path mutableCopy];
    [fullpath appendString:@"\%22"];
    [fullpath appendString:userName];
    [fullpath appendString:@"\%22"];
    
    __block NSArray *response;
    [self.httpClient getPath:fullpath parameters:[NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"]
                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                         
                         JSONDecoder* decoder = [[JSONDecoder alloc]
                                                 initWithParseOptions:JKParseOptionNone];
                         response = [decoder objectWithData:responseObject];
                         NSLog(@"We get:%@", response);
                     }failure:^(AFHTTPRequestOperation *operation, NSError *error){
                         NSLog(@"Error: %@", error);
                         response = nil;
                     }];
    return response;
}

@end
