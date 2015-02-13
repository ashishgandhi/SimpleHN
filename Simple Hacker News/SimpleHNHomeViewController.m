//
//  SimpleHNHomeTableViewController.m
//  Simple Hacker News
//
//  Created by Ashish Gandhi on 9/3/12.
//  Copyright (c) 2012-2013 Ashish Gandhi. All rights reserved.
//

#import "SimpleHNHomeViewController.h"
#import "SimpleHNSubmissionsViewController.h"

@interface SimpleHNHomeViewController ()

@property (strong, nonatomic) NSArray *sections;
@property (nonatomic) UITableViewStyle style;

@end

@implementation SimpleHNHomeViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.style = style;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize sections and rows in sections    
    NSArray *submissionsRows = @[@"Front Page", @"New", @"Ask", @"Best"];
    NSDictionary *submissionsSection = @{@"name": @"Submissions", @"rows": submissionsRows};
    
    NSArray *managementRows = @[@"Profile", @"About"];
    NSDictionary *managementSection = @{@"name": @"Management", @"rows": managementRows};
    
    self.sections = @[submissionsSection, managementSection];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [(self.sections)[section][@"rows"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (self.sections)[section][@"name"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Home Navigation Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:self.style reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSArray *rows = (self.sections)[indexPath.section][@"rows"];
    
    cell.textLabel.text = rows[indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Cell dependant segues
    NSString *sectionName = (self.sections)[indexPath.section][@"name"];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
    
    if ([sectionName isEqualToString:@"Submissions"]) [self performSegueWithIdentifier:@"View Submissions" sender:cell];
    else if ([cell.textLabel.text isEqualToString:@"Profile"]) [self performSegueWithIdentifier:@"View Profile" sender:cell];
    else if ([cell.textLabel.text isEqualToString:@"About"]) [self performSegueWithIdentifier:@"View About" sender:cell];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"View Submissions"]) {
        NSString *category = [[sender textLabel] text];
        [segue.destinationViewController setSubmissionCategory:category];
    }
}

@end
