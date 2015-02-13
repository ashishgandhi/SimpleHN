//
//  SimpleHNSubmissions.m
//  Simple Hacker News
//
//  Created by Ashish Gandhi on 9/4/12.
//  Copyright (c) 2012-2013 Ashish Gandhi. All rights reserved.
//

#import "SimpleHNSubmissions.h"
#import "TFHpple.h"


@implementation SimpleHNSubmissions

+ (NSArray *)submissionsForCategory:(NSString *)category
{
    NSString *URLString = @"http://news.ycombinator.com/";
    if ([category isEqualToString:@"New"]) {
        URLString = @"http://news.ycombinator.com/newest";
    } else if ([category isEqualToString:@"Ask"]) {
        URLString = @"http://news.ycombinator.com/ask";
    } else if ([category isEqualToString:@"Best"]) {
        URLString = @"http://news.ycombinator.com/best";
    }
    NSURL *URL = [NSURL URLWithString:URLString];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
    NSArray *elements = [doc searchWithXPathQuery:@"//td[@class='title']/a"];
    
    NSMutableArray *submissions = [[NSMutableArray alloc] initWithCapacity:[elements count]];
    for (TFHppleElement *element in elements) {
        NSString *title = [element.firstChild content];
        if ([title isEqualToString:@"scribd"]) continue; // better handle this by realizing same parent?
        NSString *href = [element objectForKey:@"href"];
        NSString *submissionURLString = [[NSURL URLWithString:href relativeToURL:URL] absoluteString];
        NSMutableDictionary *submission = [[NSMutableDictionary alloc] initWithObjectsAndKeys:title, @"title", submissionURLString, @"URLString", nil];
        [submissions addObject:submission];
    }
    [submissions removeLastObject];
    
    NSArray *subtexts = [doc searchWithXPathQuery:@"//td[@class='subtext']"];
    NSInteger subtextsCount = [subtexts count];
    for (int i = 0; i < subtextsCount; i++) {
        NSMutableDictionary *submission = submissions[i];
        TFHppleElement *subtext = subtexts[i];
        BOOL userPost = [subtext.children count] > 1 ? YES : NO;
        
        NSInteger points = 0;
        NSString *user = [[NSString alloc] initWithFormat:@"%@", @"YC Company"];
        NSString *timeElapsed = [self timeElapsedFromSubtext:subtext ofType:userPost];
        NSInteger commentsCount = 0;
        NSString *commentsURLString = submission[@"URLString"];
        
        if (userPost) {
            points = [[[(subtext.children)[0] firstChild] content] integerValue];
            user = [[[(subtext.children)[2] firstChild] content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *commentsHref = [(subtext.children)[[subtext.children count]-1] objectForKey:@"href"];
            commentsURLString = [[NSURL URLWithString:commentsHref relativeToURL:URL] absoluteString];
            commentsCount = [[[[subtext.children lastObject] firstChild] content] integerValue];
        }
        
        submission[@"points"] = @(points);
        submission[@"user"] = user;
        submission[@"since"] = timeElapsed;
        submission[@"commentsURLString"] = commentsURLString;
        submission[@"commentsCount"] = @(commentsCount);
    }
    
    return [submissions copy];
}

+ (NSString *)timeElapsedFromSubtext:(TFHppleElement *)subtext ofType:(BOOL)userSubtext
{
    
    NSInteger subtextIndex = 0;
    if (userSubtext) subtextIndex = 3;
    
    NSArray *timeElapsedComponents = [[[(subtext.children)[subtextIndex] content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@" "];
#warning band-aid to stop crashing
    if(timeElapsedComponents.count < 2) return @"";
    NSString *timeElapsed = [[[NSString alloc] initWithFormat:@"%@ %@", timeElapsedComponents[0], timeElapsedComponents[1]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return timeElapsed;
}

@end
