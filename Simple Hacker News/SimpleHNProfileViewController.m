//
//  SimpleHNProfileViewController.m
//  Simple Hacker News
//
//  Created by Ashish Gandhi on 9/8/12.
//  Copyright (c) 2012-2013 Ashish Gandhi. All rights reserved.
//

#import "SimpleHNProfileViewController.h"
#import "SimpleHNProfile.h"

@interface SimpleHNProfileViewController ()

@property (strong, nonatomic) NSArray *rows;
@property (nonatomic) UITableViewStyle style;
@property (strong, nonatomic) NSDictionary *userProfile;
@property (strong, nonatomic) UIAlertView *usernameAlert;

@end

@implementation SimpleHNProfileViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.style = style;
    }
    return self;
}

- (void)setUserProfile:(NSDictionary *)userProfile
{
    if (_userProfile != userProfile) {
        _userProfile = userProfile;
        [self.tableView reloadData];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Save"]) {
        UITextField *username = [alertView textFieldAtIndex:buttonIndex];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:username.text forKey:@"defaultUsername"];
        [defaults synchronize];
        [self updateProfileWithUsername:username.text];
    }
}

- (void)askUsername
{
    self.usernameAlert = [[UIAlertView alloc] initWithTitle:@"Username" message:@"Enter your HN username" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Save", nil];
    self.usernameAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[self.usernameAlert textFieldAtIndex:self.usernameAlert.firstOtherButtonIndex] setPlaceholder:@"HN username"];
    [[self.usernameAlert textFieldAtIndex:self.usernameAlert.firstOtherButtonIndex] setDelegate:self];
    [self.usernameAlert show];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [self.usernameAlert dismissWithClickedButtonIndex:self.usernameAlert.firstOtherButtonIndex animated:YES];
    return YES;
}

- (IBAction)editProfile:(id)sender
{
    [self askUsername];
}

- (void)updateProfileWithUsername:(NSString *)username
{
    UIBarButtonItem *editButton = self.navigationItem.rightBarButtonItem;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("Profile Downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSDictionary *userProfile = [SimpleHNProfile profileForUsername:username];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem = editButton;
            self.userProfile = userProfile;
        });
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:userProfile forKey:@"userProfile"];
        [defaults synchronize];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Custom initialization
    self.rows = @[@"username", @"karma", @"average", @"created"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"defaultUsername"] == nil) {
        [self askUsername];
    } else {
        self.userProfile = [defaults objectForKey:@"userProfile"];
        [self updateProfileWithUsername:[defaults objectForKey:@"defaultUsername"]];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
    return [self.rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HN Profile Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:self.style reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.detailTextLabel.text = (self.rows)[indexPath.row];
    cell.textLabel.text = (self.userProfile)[cell.detailTextLabel.text];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
