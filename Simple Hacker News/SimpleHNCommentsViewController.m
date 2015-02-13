//
//  SimpleHNCommentsViewController.m
//  Simple Hacker News
//
//  Created by Ashish Gandhi on 9/18/12.
//  Copyright (c) 2012-2013 Ashish Gandhi. All rights reserved.
//

#import "SimpleHNCommentsViewController.h"
#import "SimpleHNComments.h"

#define CELL_INDENTATION_WIDTH 15.0f

@interface SimpleHNCommentsViewController ()

@property (strong, nonatomic) NSArray *comments;
@property (nonatomic) UITableViewStyle style;
@property (nonatomic) NSInteger indentationSizeFromAPI;

@end

@implementation SimpleHNCommentsViewController

- (void)setComments:(NSArray *)comments
{
    if (_comments != comments) {
        _comments = comments;
        [self.tableView reloadData];
    }
}

- (IBAction)refresh:(id)sender {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner setColor:[UIColor orangeColor]];
    [spinner startAnimating];
    UIBarButtonItem *refreshButton = self.commetsNavigationItem.rightBarButtonItem;
    self.commetsNavigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("Submissions Downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *comments = [SimpleHNComments commentsOnPage:self.commentsURLString];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([sender isKindOfClass:[UIRefreshControl class]]) {
                [sender endRefreshing];
            }
            self.commetsNavigationItem.rightBarButtonItem = refreshButton;
            self.comments = comments;
        });
    });
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Customize
    self.indentationSizeFromAPI = -1;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl setTintColor:[UIColor orangeColor]];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    [self refresh:self.commetsNavigationItem.rightBarButtonItem];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setCommetsNavigationItem:nil];
    [super viewDidUnload];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HN Comment";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSDictionary *comment = (self.comments)[indexPath.row];
    cell.textLabel.text = comment[@"user"];
    cell.detailTextLabel.text = comment[@"body"];
    
    cell.indentationLevel = [comment[@"indentation"] intValue];
    cell.indentationWidth = CELL_INDENTATION_WIDTH;
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *comment = (self.comments)[indexPath.row];
    NSString *text = [NSString stringWithFormat:@"%@\n%@", comment[@"user"], comment[@"body"]];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat indentationAndMargins = 15.0f + 15.0f + CELL_INDENTATION_WIDTH * [comment[@"indentation"] intValue];
    CGSize constraint = CGSizeMake(screenBounds.size.width - indentationAndMargins, MAXFLOAT);
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:[UIFont systemFontSize]], NSFontAttributeName, nil];
    CGRect frame = [text boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:nil];
    
    return frame.size.height + 20.0f;
}

@end
