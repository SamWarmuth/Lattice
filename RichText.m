//
//  RichText.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/24/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "RichText.h"
#import "Post.h"
#import "User.h"
#import "TextEntity.h"
#import "SWAppDelegate.h"


@implementation RichText

@dynamic text;
@dynamic entities;
@dynamic post;
@dynamic user;


+ (RichText *)createOrUpdateRichTextFromDictionary:(NSDictionary *)dictionary
{
    SWAppDelegate *appDelegate = (SWAppDelegate *)[[UIApplication sharedApplication] delegate];
        
    RichText *text = (RichText *)[NSEntityDescription insertNewObjectForEntityForName:@"RichText" inManagedObjectContext:appDelegate.managedObjectContext];
    
    text.text = [dictionary objectForKey:@"text"];
    text.entities = [TextEntity createOrUpdateEntitesFromDictionary:[dictionary objectForKey:@"entities"]];
    
    return text;
}

@end
