//
//  Project.h
//  Bugtrack
//
//  Created by Ilia Akgaev on 10/8/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Project : NSObject
@property (strong, nonatomic) NSString* key;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* link;
@property (strong, nonatomic) NSArray* issues;
@end
