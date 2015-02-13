//
//  SimpleHNSubmissions.h
//  Simple Hacker News
//
//  Created by Ashish Gandhi on 9/4/12.
//  Copyright (c) 2012-2013 Ashish Gandhi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimpleHNSubmissions : NSObject

+ (NSArray *)submissionsForCategory:(NSString *)category;

@end
