//
//  SimpleHNSubmissionViewController.m
//  Simple Hacker News
//
//  Created by Ashish Gandhi on 9/7/12.
//  Copyright (c) 2012-2013 Ashish Gandhi. All rights reserved.
//

#import "SimpleHNSubmissionViewController.h"
#import "SimpleHNCommentsViewController.h"

@interface SimpleHNSubmissionViewController ()

@property (nonatomic) BOOL readabilityMode;

@end

@implementation SimpleHNSubmissionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)toggleReadabilityMode:(id)sender {
    if (self.readabilityMode) {
        [self loadSubmission];
    } else {
        [self loadReadabilitySubmission];
    }
    self.readabilityMode = !self.readabilityMode;
}

- (void)loadSubmission
{
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:[NSURL URLWithString:(self.submission)[@"URLString"]]];
    [self.submissionWebView loadRequest:requestURL];
}

- (void)loadReadabilitySubmission
{
    NSString *readabilityURLString = [NSString stringWithFormat:@"http://www.readability.com/m?url=%@", (self.submission)[@"URLString"]];
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:[NSURL URLWithString:readabilityURLString]];
    [self.submissionWebView loadRequest:requestURL];
}

- (IBAction)openInSafari:(id)sender {
    [[UIApplication sharedApplication] openURL:self.submissionWebView.request.URL];
}

- (IBAction)refresh:(id)sender {
    [self.submissionWebView reload];
}

- (IBAction)share:(id)sender {
    NSArray *activityItems = @[(self.submission)[@"title"], [NSURL URLWithString:(self.submission)[@"URLString"]]];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = (self.submission)[@"title"];
    self.readabilityMode = NO;
    self.submissionWebView.delegate = self;
    [self loadSubmission];
}

- (void)viewDidUnload
{
    [self setSubmissionWebView:nil];
    [self setToolbar:nil];
    [self setSpinner:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.spinner startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.spinner stopAnimating];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"View Comments"]) {
        [segue.destinationViewController setCommentsURLString:(self.submission)[@"commentsURLString"]];
    }
}

@end
