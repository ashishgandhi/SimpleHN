//
//  SimpleHNCommentsViewController.h
//  Simple Hacker News
//
//  Created by Ashish Gandhi on 9/18/12.
//  Copyright (c) 2012-2013 Ashish Gandhi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleHNCommentsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSString *commentsURLString;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UINavigationItem *commetsNavigationItem;

@end
