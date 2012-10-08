//
//  Issue.m
//  Bugtrack
//
//  Created by Ilia Akgaev on 10/8/12.
//  Copyright (c) 2012 Intetics Co. All rights reserved.
//

#import "Issue.h"

@implementation Issue

- (NSString*) description {
    return [NSString stringWithFormat:@"Title:%@ \n Issue Type:%@ \n Status:%@, \n Priority:%@ \n Assignee:%@ \n Reporter:%@ \n Created:%@",
            self.title, self.issueType, self.status, self.priority, self.assignee, self.reporter, self.created];
}
@end