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

@end
