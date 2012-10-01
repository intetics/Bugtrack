//
//  Logindata.h
//  Bugtrack
//
//  Created by Ilia Akgaev on 10/1/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginData : NSObject <NSCoding>

@property (strong, nonatomic) NSDictionary* session;
@property (strong, nonatomic) NSString* username;
@property (strong, nonatomic) NSString* baseurl;
@property (strong, nonatomic) NSString* password;

@end