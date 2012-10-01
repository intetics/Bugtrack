//
//  LoginData.h
//  Bugtrack
//
//  Created by Ilia Akgaev on 10/1/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import "LoginData.h"

@implementation LoginData

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.session = [aDecoder decodeObjectForKey:@"session"];
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.baseurl = [aDecoder decodeObjectForKey:@"baseurl"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.session forKey:@"session"];
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.baseurl forKey:@"baseurl"];
    
}
@end
