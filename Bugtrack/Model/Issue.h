//
//  Issue.h
//  Bugtrack
//
//  Created by Ilia Akgaev on 10/8/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Issue : NSObject

@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* issueType;
@property (strong, nonatomic) NSString* status;
@property (strong, nonatomic) NSString* priority;
@property (strong, nonatomic) NSString* assignee;
@property (strong, nonatomic) NSString* reporter;
@property (strong, nonatomic) NSString* created;

@end
