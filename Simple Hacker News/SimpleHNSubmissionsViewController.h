//
//  SimpleHNFrontPageControllerViewController.h
//  Simple Hacker News
//
//  Created by Ashish Gandhi on 9/3/12.
//  Copyright (c) 2012-2013 Ashish Gandhi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface SimpleHNSubmissionsViewController : UITableViewController

@property (strong, nonatomic) NSArray *submissions;
@property (strong, nonatomic) NSString *submissionCategory;

@end
