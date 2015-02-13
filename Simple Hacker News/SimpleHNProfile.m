//
//  SimpleHNProfile.m
//  Simple Hacker News
//
//  Created by Ashish Gandhi on 9/8/12.
//  Copyright (c) 2012-2013 Ashish Gandhi. All rights reserved.
//

#import "SimpleHNProfile.h"
#import "TFHpple.h"

@implementation SimpleHNProfile

+ (NSDictionary *)profileForUsername:(NSString *)username
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://news.ycombinator.com/user?id=%@", username]];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
    NSArray *elements = [doc searchWithXPathQuery:@"//form//td"];
    NSString *created, *karma, *average, *about;
    
    if ([elements count] >= 10) {
        created = [[elements[3] firstChild] content];
        karma = [[elements[5] firstChild] content];
        average = [[elements[7] firstChild] content];
        about = [[elements[9] firstChild] content];
    }
    
    NSMutableDictionary *profile = [[NSMutableDictionary alloc] init];
    profile[@"username"] = username;
    if (created != nil) profile[@"created"] = created;
    if (karma != nil) profile[@"karma"] = karma;
    if (average != nil) profile[@"average"] = average;
    if (about != nil) profile[@"about"] = about;
    return [profile copy];
}

@end
