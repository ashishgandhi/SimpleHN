//
//  Submission.h
//  Simple Hacker News
//
//  Created by Ashish Gandhi on 9/20/12.
//  Copyright (c) 2012-2013 Ashish Gandhi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Submission : NSManagedObject

@property (nonatomic, retain) NSDate * readDate;
@property (nonatomic, retain) NSString * submissionURL;

@end
