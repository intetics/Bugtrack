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
#import "Project.h"
#import "Issue.h"
#import "SSKeychain.h"

@interface NetworkManager ()
@property (strong, nonatomic) AFHTTPClient * httpClient;
@property (strong, nonatomic) NSString* baseURL;
@property (strong, nonatomic) NSString* username;
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
        _httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:self.baseURL]];
        _httpClient.parameterEncoding = AFJSONParameterEncoding;
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
    __weak NetworkManager* manager = self;
    [self.httpClient postPath:@"auth/latest/session" parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id response){
                          JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
                          NSDictionary *json = [decoder objectWithData:response];
                          NSLog(@"Response: %@", json);
                          [manager.httpClient setAuthorizationHeaderWithUsername:username password:password];
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

- (void) logoutWithCompletitionsBlocksForSuccess:(void(^)(id response))success failure:(void(^)(NSError *error))failure{
    [self.httpClient deletePath:@"auth/latest/session"
                     parameters:nil
                        success:^(AFHTTPRequestOperation *operation, id response){
                            if (success) {
                                success(response);
                            }
                        }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error){
                            NSLog(@"Failed to logout");
                            if (failure) {
                                failure(error);
                            }
                        }];
}

#pragma mark - Get data

- (void) getAllIssuesForCurrentUserWithSuccess:(void (^)(id response))success
                                    andFailure:(void (^)(NSError* error))failure {
    NSString *path = @"api/latest/search";
    NSString* assignee = [NSString stringWithFormat:@"assignee=\"%@\" and status in (\"open\",\"in progress\", \"reopened\")", [[NetworkManager getAccount] objectForKey:@"username"]];
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

- (void) getDetailedIssueInfo:(Issue *)issue success:(void (^)(id response))success andFailure:(void (^)(NSError* error))failure{
    __block NSDictionary *detailedInfo;
    
    [self.httpClient getPath:[self cleanStringURL:issue.link]
                  parameters:nil
                     success:^(AFHTTPRequestOperation *operation, id response) {
                         JSONDecoder* decoder = [[JSONDecoder alloc]
                                                 initWithParseOptions:JKParseOptionNone];
                         detailedInfo = [decoder objectWithData:response];
                         [self mapDetailedInfo:detailedInfo toIssue:issue];
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

- (void) getIssuesForUser:(NSString*)user inProjectWithKey:(NSString*)projectKey withSucces:(void(^)(id response))success{
    NSMutableDictionary* options = [NSMutableDictionary dictionary];
    user = user ? user : [[NetworkManager getAccount] objectForKey:@"username"];
    NSString* jql = [NSString stringWithFormat:@"assignee=\"%@\" and project=\"%@\" and status in (\"open\",\"in progress\", \"reopened\")", user, projectKey];
    [options setObject:jql forKey:@"jql"];
    NSString* path = @"api/latest/search";
    [self.httpClient postPath:path
                   parameters:options
                      success:^(AFHTTPRequestOperation *operation, id response){
                          JSONDecoder* decoder = [JSONDecoder decoder];
                          NSMutableArray* data = [self mapIssues:[decoder objectWithData:response]];
                          if (success) {
                              success(data);
                          }
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError* error){
                          NSLog(@"Error: %@", error);
                      }];
}

#pragma mark - Miscellaneous

//Removes BASE_URL part from url.
- (NSString *) cleanStringURL:(NSString *)stringURL {
    int length = [self.baseURL length];
    NSString *rightURL = [stringURL substringFromIndex:length];
    return rightURL;
}

#pragma mark - Mapping

- (NSMutableArray*) mapProjects:(NSArray*)projects {
    NSMutableArray* mappedData = [NSMutableArray array];
    for (NSDictionary* raw in projects) {
        Project* temp = [[Project alloc] init];
        temp.key = [raw objectForKey:@"key"];
        temp.title = [raw objectForKey:@"name"];
        temp.link = [raw objectForKey:@"self"];
        [mappedData addObject:temp];
    }
    return mappedData;
}

- (NSMutableArray*) mapIssues:(NSDictionary*)response {
    
    NSMutableArray* mappedData = [NSMutableArray array];
    NSArray* issues = [response objectForKey:@"issues"];
    for (NSDictionary* raw in issues) {
        Issue* temp = [[Issue alloc] init];
        temp.key = [raw objectForKey:@"key"];
        temp.link = [raw objectForKey:@"self"];
        [mappedData addObject:temp];
    }
    return mappedData;
}

- (Issue* )mapDetailedInfo:(id)response toIssue:(Issue*)issue{
    
    issue.assignee = [response valueForKeyPath:@"fields.assignee.value.displayName"];
    issue.created = [response valueForKeyPath:@"fields.created.value"];
    issue.issueType = [response valueForKeyPath:@"fields.issuetype.value.name"];
    issue.priority = [response valueForKeyPath:@"fields.priority.value.name"];
    issue.reporter = [response valueForKeyPath:@"fields.reporter.value.displayName"];
    issue.status = [response valueForKeyPath:@"fields.status.value.name"];
    issue.title = [response valueForKeyPath:@"fields.summary.value"];
    return nil;
}

- (void) reset{
    self.httpClient = nil;
    self.baseURL = nil;
    self.username = nil;
}

#pragma mark - Class methods
+ (NSDictionary*) getAccount {
    NSError* keychainError;
    NSArray* accounts = [SSKeychain allAccounts];
    if (!accounts) {
        NSLog(@"No accounts");
        return nil;
    }
    NSLog(@"Accounts: %@", accounts);
    NSDictionary* jira = [accounts objectAtIndex:0];
    NSString* username = [jira objectForKey:@"acct"];
    if (!username) {
        NSLog(@"No username");
        return nil;
    }
    NSString* service = [jira objectForKey:@"svce"];
    if (!service) {
        NSLog(@"No service");
        return nil;
    }
    NSString* password = [SSKeychain passwordForService:service account:username error:&keychainError];
    if (!password) {
        NSLog(@"Error: %@", keychainError);
        return nil;
    }
    NSDictionary* account = [NSDictionary dictionaryWithObjectsAndKeys:
                          username, @"username",
                          password, @"password",
                          service, @"service",
                          nil];
    return account;

}
@end
