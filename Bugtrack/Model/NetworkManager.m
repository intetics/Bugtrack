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
#import "DataManager.h"

@interface NetworkManager ()
@property (strong, nonatomic) AFHTTPClient * httpClient;
@property (strong, nonatomic) NSString *baseURL;
@property (strong, nonatomic) NSDictionary *session;
@end

@implementation NetworkManager
@synthesize httpClient = _httpClient;
@synthesize baseURL = _baseURL;

#pragma mark - Init

+ (id)sharedClient {
    static dispatch_once_t onceToken = 0;
    __strong static id __sharedClient = nil;
    dispatch_once(&onceToken, ^{
        __sharedClient = [[self alloc] init];
    });
    return __sharedClient;
}

- (void) setBaseURL:(NSString *)baseURL{
    _baseURL = baseURL;
}

- (AFHTTPClient *) httpClient {
    if (!_httpClient) {
        DataManager *dataManager = [DataManager sharedManager];
        self.session = [dataManager getSessionInfo];
        _httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[dataManager getBaseURL]]];
        _httpClient.parameterEncoding = AFJSONParameterEncoding;
    }
    return _httpClient;
}

#pragma mark - Login

- (BOOL) isCoockieValidSuccess:(void(^)(id response))success failure:(void(^)(NSError *error))failure {
    __block BOOL valid = NO;
    DataManager *dataManager = [DataManager sharedManager];
    NSDictionary *session = [dataManager getSessionInfo];
    [self.httpClient getPath:@"auth/latest/session" parameters:session
                     success:^(AFHTTPRequestOperation *operation, id response){
                         if (success) {
                             self.session = session;
                             success(response);
                         }
                     }
                     failure:^(AFHTTPRequestOperation *operation, NSError *error){
                         if (failure) {
                             _httpClient = nil;
                             failure(failure);
                         }
                     }];
    return valid;
}
- (void) loginWithUsername:(NSString*)username andPassword:(NSString*) password success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure{
    
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:username, @"username", password, @"password", nil];
    [self.httpClient postPath:@"auth/latest/session" parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id response){
                          JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
                          NSDictionary *json = [decoder objectWithData:response];
                          NSLog(@"Response: %@", json);
                          self.session = [json objectForKey:@"session"];
                          DataManager *dataManger = [DataManager sharedManager];
                          [dataManger setSessionInfo:self.session];
                          [dataManger save];
                          if (success) {
                              success(json);
                          }
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error){
                          NSLog(@"%s %d %s %s \n\n Operation: %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__, operation);
                          if (failure) {
                              failure(error);
                          }
                      }];
}

#pragma mark - Get data
//TODO: Make it more generic. Right now it uses assumption that we can pass auth. header in request.
//FIXME: use standard URL encoder, but not do it by yourself
- (void) getAllIssuesForCurrentUserWithSuccess:(void (^)(id response))success
                                    andFailure:(void (^)(NSError* error))failure {
    
    DataManager* dataManager = [DataManager sharedManager];
    
    NSString *path = @"api/latest/search?jql=assignee%3D";
    NSMutableString *fullpath = [path mutableCopy];
    [fullpath appendString:@"\%22"];
    [fullpath appendString:[dataManager getUserName]];
    [fullpath appendString:@"%22"];
    [fullpath appendString:@"\%20and\%20status\%20in\%20(\%22open\%22,\%22in%20progress\%22,\%22reopened\%22)"];
    
    __block NSDictionary *response;
    [self.httpClient getPath:fullpath
                  parameters:self.session
                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                         
                         JSONDecoder* decoder = [[JSONDecoder alloc]
                                                 initWithParseOptions:JKParseOptionNone];
                         response = [decoder objectWithData:responseObject];
                         NSLog(@"%s %d \n%s \n%s \n We get: %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__, response);
                         if (success) {
                             success([response objectForKey:@"issues"]);
                         }
                     }failure:^(AFHTTPRequestOperation *operation, NSError *error){
                         NSLog(@"%s %d \n%s \n%s \n Error: %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__, error);
                         if (failure) {
                             failure(error);
                         }
                     }];
}

- (void) getDetailedIssueInfo:(NSString *)issueURL success:(void (^)(id response))success andFailure:(void (^)(NSError* error))failure{
    __block NSDictionary *detailedInfo;
    
    [self.httpClient getPath:[self cleanStringURL:issueURL]
                  parameters:self.session
                     success:^(AFHTTPRequestOperation *operation, id response) {
                         JSONDecoder* decoder = [[JSONDecoder alloc]
                                                 initWithParseOptions:JKParseOptionNone];
                         detailedInfo = [decoder objectWithData:response];
                         NSLog(@"%s %d \n%s \n%s \n Detailed info: %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__, detailedInfo);
                         if (success) {
                             success(detailedInfo);
                         }
                     }
                     failure:^(AFHTTPRequestOperation *operation, NSError *error){
                         NSLog(@"%s %d \n%s \n%s \n Oh god: %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__, error);
                         if (failure) {
                             failure(error);
                         }
                     }];
}

- (void) getProjectsWithCompletitionBlocksForSuccess:(void (^)(id response))success
                                          andFailure:(void (^)(NSError* error))failure
{
    __block NSArray* projects;
    [self.httpClient getPath:@"project"
                  parameters:self.session
                     success:^(AFHTTPRequestOperation *operation, id response){
                         NSLog(@"\n %s \n Success!", __PRETTY_FUNCTION__);
                         JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
                         projects = [decoder objectWithData:response];
                         if (success) {
                             success(projects);
                         }
                     }
                     failure:^(AFHTTPRequestOperation *operation, NSError *error){
                         NSLog(@"%s %d \n%s \n%s \n Fail: %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__, error);
                         if (failure) {
                             failure(error);
                         }
                     }];
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
