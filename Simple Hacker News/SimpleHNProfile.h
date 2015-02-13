//
//  SimpleHNProfile.h
//  Simple Hacker News
//
//  Created by Ashish Gandhi on 9/8/12.
//  Copyright (c) 2012-2013 Ashish Gandhi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimpleHNProfile : NSObject

+ (NSDictionary *)profileForUsername:(NSString *)username;

@end
