//
//  SimpleHNFrontPageControllerViewController.m
//  Simple Hacker News
//
//  Created by Ashish Gandhi on 9/3/12.
//  Copyright (c) 2012-2013 Ashish Gandhi. All rights reserved.
//

#import "SimpleHNSubmissionsViewController.h"
#import "SimpleHNSubmissions.h"
#import "TFHpple.h"
#import "SimpleHNSubmissionViewController.h"
#import "Submission.h"

@interface SimpleHNSubmissionsViewController ()

@property (nonatomic) UITableViewStyle style;
@property (strong, nonatomic) UIManagedDocument *readSubmissions;

@end

@implementation SimpleHNSubmissionsViewController

- (void)setSubmissions:(NSArray *)submissions
{
    if ([submissions count] != 0 && _submissions != submissions) {
        _submissions = submissions;
        [self.tableView reloadData];
    }
}

- (IBAction)refresh:(id)sender {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner setColor:[UIColor orangeColor]];
    [spinner startAnimating];
    UIBarButtonItem *refreshButton = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("Submissions Downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *submissions = [SimpleHNSubmissions submissionsForCategory:self.submissionCategory];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem = refreshButton;
            if ([sender isKindOfClass:[UIRefreshControl class]]) {
                [sender endRefreshing];
            }
            self.submissions = submissions;
        });
        // Cache submissions
        if ([submissions count] == 0) return;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:submissions forKey:self.submissionCategory];
        [defaults synchronize];
    });
}

- (BOOL)hasReadSubmission:(NSDictionary *)submission
{
    if (self.readSubmissions.documentState != UIDocumentStateNormal) return YES;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Submission"];
    request.predicate = [NSPredicate predicateWithFormat:@"submissionURL = %@", submission[@"URLString"]];
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"readDate" ascending:YES];
//    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];

    NSError *error;
    NSUInteger count = [self.readSubmissions.managedObjectContext countForFetchRequest:request error:&error];
    if (error != nil) NSLog(@"Error fetching count of read records: %@", [error description]);
    return count > 0;
}

- (void)readSubmission:(NSDictionary *)submission inCell:(UITableViewCell *)cell
{
    cell.imageView.image = [UIImage imageNamed:@"UIReadIndicator"];
    cell.imageView.highlightedImage = nil;
    
    // Add submissions to read
    if (self.readSubmissions.documentState != UIDocumentStateNormal || [self hasReadSubmission:submission]) return;
    
    NSManagedObjectContext *context = self.readSubmissions.managedObjectContext;
    Submission *readSubmission = [NSEntityDescription insertNewObjectForEntityForName:@"Submission" inManagedObjectContext:context];
    readSubmission.submissionURL = submission[@"URLString"];
    readSubmission.readDate = [NSDate date];
    NSError *error;
    [context save:&error];
    if (error != nil) NSLog(@"Error adding to submissions: %@", [error description]);
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.style = style;
    }
    return self;
}

- (void)pruneOldReadSubmissions
{
    NSDate *today = [NSDate date];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastPruneDate = [defaults objectForKey:@"lastPruneDate"];
    NSTimeInterval timeSinceLastPrune = [today timeIntervalSinceDate:lastPruneDate];
    if (timeSinceLastPrune < 24*60*60) return;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:-14];
    NSDate *fourteenDaysAgo = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Submission"];
    request.predicate = [NSPredicate predicateWithFormat:@"readDate <= %@", fourteenDaysAgo];
    
    NSError *error;
    NSArray *results = [self.readSubmissions.managedObjectContext executeFetchRequest:request error:&error];
    
    if (error != nil) NSLog(@"Error fetching submissions from last month to prune: %@", [error description]);
    
    NSLog(@"Deleting %d read submissions", [results count]);
    for (Submission *submission in results) {
        [self.readSubmissions.managedObjectContext deleteObject:submission];
    }
    
    [self.readSubmissions.managedObjectContext save:&error];
    if (error != nil) NSLog(@"Error saving pruned context: %@", [error description]);
    else [defaults setObject:today forKey:@"lastPruneDate"];
}

- (void)setupReadSubmissions
{
    if (self.readSubmissions == nil) {
        NSURL *baseURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *readSubmissionsURL = [baseURL URLByAppendingPathComponent:@"Read Submissions"];
        self.readSubmissions = [[UIManagedDocument alloc] initWithFileURL:readSubmissionsURL];
    }
    else if (self.readSubmissions.documentState == UIDocumentStateNormal) return;

    if ([[NSFileManager defaultManager] fileExistsAtPath:[self.readSubmissions.fileURL path]]) {
        [self.readSubmissions openWithCompletionHandler:^(BOOL success) {
            if (success) {
                [self.tableView reloadData];
                [self pruneOldReadSubmissions];
            }
            else NSLog(@"Unable to open existing Core Data file");
        }];
    } else {
        [self.readSubmissions saveToURL:self.readSubmissions.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) [self.tableView reloadData];
            else NSLog(@"Unable to save for creating Core Data file");
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.submissions = [[NSUserDefaults standardUserDefaults] objectForKey:self.submissionCategory];
    [self setupReadSubmissions];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Customize
    self.title = self.submissionCategory;
    self.tableView.rowHeight = 75;
    [self refresh:self.navigationItem.rightBarButtonItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupReadSubmissions) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [self.readSubmissions closeWithCompletionHandler:^(BOOL success) {
        self.readSubmissions = nil;
    }];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    return [self.submissions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"HN Submission";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:self.style reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *submission = (self.submissions)[indexPath.row];
    cell.textLabel.text = submission[@"title"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ pts • %@ comments • %@ • %@", [submission[@"points"] stringValue], [submission[@"commentsCount"] stringValue], submission[@"user"], submission[@"since"]];
    
    // set the cell read indicator
    if ([self hasReadSubmission:submission]) {
        cell.imageView.image = [UIImage imageNamed:@"UIReadIndicator"];
        cell.imageView.highlightedImage = nil;
    } else {
        cell.imageView.image = [UIImage imageNamed:@"UIUnreadIndicator"];
        cell.imageView.highlightedImage = [UIImage imageNamed:@"UIUnreadIndicatorPressed"];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
    [self readSubmission:(self.submissions)[indexPath.row] inCell:cell];
    [self performSegueWithIdentifier:@"View Submission" sender:(self.submissions)[indexPath.row]];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"View Submission"]) {
        [segue.destinationViewController setSubmission:sender];
    }
}

@end
