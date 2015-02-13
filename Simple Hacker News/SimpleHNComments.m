//
//  SimpleHNComments.m
//  Simple Hacker News
//
//  Created by Ashish Gandhi on 9/17/12.
//  Copyright (c) 2012-2013 Ashish Gandhi. All rights reserved.
//

#import "SimpleHNComments.h"
#import "TFHpple.h"

@implementation SimpleHNComments

+ (NSArray *)commentsOnPage:(NSString *)commentsPage
{
    NSURL *URL = [NSURL URLWithString:commentsPage];
    NSData  *data = [NSData dataWithContentsOfURL:URL];
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
    
    NSArray *commentElements = [doc searchWithXPathQuery:@"//span[@class='comment']"];
    NSArray *userElements = [doc searchWithXPathQuery:@"//span[@class='comhead']"];
    NSArray *indentationElements = [doc searchWithXPathQuery:@"//img[@height='1']"];
    
    NSInteger commentsCount = [commentElements count];
    NSInteger userElementsOffset = [userElements count] - commentsCount;
    
    NSInteger indentationElementsOffset = 1;
    
    NSMutableArray *comments = [[NSMutableArray alloc] initWithCapacity:commentsCount];
    NSInteger indentationSize = -1;
    
    for (int i=0; i < commentsCount; i++) {
        TFHppleElement *commentElement = commentElements[i];
        NSString *commentBody = [self stringFromElement:commentElement];
        
        NSInteger indentation = [[indentationElements[i+indentationElementsOffset] objectForKey:@"width"] integerValue];
        if (indentation != 0 && indentationSize == -1) indentationSize = indentation;
        indentation /= indentationSize;
        
        // new user has green font tag around it
        TFHppleElement *userElement = [[userElements[i+userElementsOffset] firstChild] firstChild];
        NSString *commentUser;
        if ([[userElement tagName] isEqualToString:@"font"]) commentUser = [[userElement firstChild] content];
        else commentUser = [userElement content];
        // deleted comment has no user
        if (commentUser == nil) {
            commentUser = @"";
            indentationElementsOffset++;
        }
        
        NSDictionary *comment = @{@"body": commentBody, @"user": commentUser, @"indentation": @(indentation)};
        [comments addObject:comment];
    }
    
    return [comments copy];
}

+ (NSString *)stringFromElement:(TFHppleElement *)element
{
    NSString *elementString;
    if ([element content] == nil) elementString = @"";
    else elementString = [element content];
    for (TFHppleElement *child in element.children) {
        NSString *childString = [self stringFromElement:child];
        if ([[child tagName] isEqualToString:@"p"]) elementString = [NSString stringWithFormat:@"%@\n\n%@", elementString, childString];
        else elementString = [elementString stringByAppendingString:childString];
    }
    return elementString;
}

@end