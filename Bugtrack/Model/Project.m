//
//  Project.m
//  Bugtrack
//
//  Created by Ilia Akgaev on 10/8/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import "Project.h"

@implementation Project

#pragma mark - NSObject method reloading
- (NSString*) description {
    NSString *description = [NSString stringWithFormat:@"Project: \nName: %@ \n Key:%@ \n Link:%@ \n Issues count: %u" , self.name, self.key, self.link, [self.issues count]];
    return description;
}

@end