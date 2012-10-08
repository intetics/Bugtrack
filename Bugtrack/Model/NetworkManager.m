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
#import "Project.h"

@interface NetworkManager ()
@property (strong, nonatomic) AFHTTPClient * httpClient;
@property (strong, nonatomic) NSString *baseURL;
@property (strong, nonatomic) NSHTTPCookie *session;
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
    return [self httpClientWithAuthorizationType:BT_AUTHORIZATION_BASIC];
}

- (AFHTTPClient*) httpClientWithAuthorizationType:(BTAuthorizationType)authorizationType{
    if (!_httpClient) {
        DataManager *dataManager = [DataManager sharedManager];
        self.session = [dataManager getSessionInfo];
        _httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[dataManager getBaseURL]]];
        _httpClient.parameterEncoding = AFJSONParameterEncoding;
        
        if (authorizationType == BT_AUTHORIZATION_BASIC) {
            [_httpClient setAuthorizationHeaderWithUsername:[dataManager getUserName] password:[dataManager getPassword]];
        } else {
            DataManager *dataManager = [DataManager sharedManager];
            NSHTTPCookie *session = [dataManager getSessionInfo];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:session];
        }
    }
    return _httpClient;
}

#pragma mark - Login

- (BOOL) isCoockieValidSuccess:(void(^)(id response))success failure:(void(^)(NSError *error))failure {
    __block BOOL valid = NO;
        [self.httpClient getPath:@"auth/latest/session" parameters:nil
                     success:^(AFHTTPRequestOperation *operation, id response){
                         if (success) {
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

- (void) getAllIssuesForCurrentUserWithSuccess:(void (^)(id response))success
                                    andFailure:(void (^)(NSError* error))failure {
    
    DataManager* dataManager = [DataManager sharedManager];
    
    NSString *path = @"api/latest/search";
    NSString* assignee = [NSString stringWithFormat:@"assignee=\"%@\" and status in (\"open\",\"in progress\", \"reopened\")", [dataManager getUserName]];
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    [json setObject:assignee forKey:@"jql"];
    
    __block NSDictionary *response;
    [self.httpClient postPath:path
                  parameters:json
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
                  parameters:nil
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
    [self.httpClient getPath:@"api/latest/project"
                  parameters:nil
                     success:^(AFHTTPRequestOperation *operation, id response){
                         NSLog(@"\n %s \n Success!", __PRETTY_FUNCTION__);
                         JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
                         NSMutableArray* data = [self mapProjects:[decoder objectWithData:response]];
                         if (success) {
                             success(data);
                         }
                     }
                     failure:^(AFHTTPRequestOperation *operation, NSError *error){
                         NSLog(@"%s %d \n%s \n%s \n Fail: %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__, error);
                         if (failure) {
                             failure(error);
                         }
                     }];
}

- (void) getIssuesForUser:(NSString*)user inProjectWithKey:(NSString*)projectKey{
    NSMutableDictionary* options = [NSMutableDictionary dictionary];
    user = user ? user : [[DataManager sharedManager] getUserName];
    NSString* jql = [NSString stringWithFormat:@"assignee=\"%@\" and project=\"%@\" and status in (\"open\",\"in progress\", \"reopened\")", user, projectKey];
    [options setObject:jql forKey:@"jql"];
    NSString* path = @"api/latest/search";
    [self.httpClient postPath:path
                   parameters:options
                      success:^(AFHTTPRequestOperation *operation, id response){
                          JSONDecoder* decoder = [JSONDecoder decoder];
                          NSDictionary* issues = [decoder objectWithData:response];
                          NSLog(@"%@", issues);
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError* error){
                          NSLog(@"Error: %@", error);
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

#pragma mark - Mapping

- (NSMutableArray*) mapProjects:(NSArray*)projects {
    NSMutableArray* mappedData = [NSMutableArray array];
    for (NSDictionary* raw in projects) {
        Project* temp = [[Project alloc] init];
        temp.key = [raw objectForKey:@"key"];
        temp.name = [raw objectForKey:@"name"];
        temp.link = [raw objectForKey:@"self"];
        [mappedData addObject:temp];
    }
    return mappedData;
}

@end
