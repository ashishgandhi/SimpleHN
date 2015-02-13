//
//  SimpleHNSubmissionViewController.h
//  Simple Hacker News
//
//  Created by Ashish Gandhi on 9/7/12.
//  Copyright (c) 2012-2013 Ashish Gandhi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleHNSubmissionViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *submissionWebView;
@property (strong, nonatomic) NSDictionary *submission;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end
