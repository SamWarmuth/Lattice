//
//  TextEntity.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/24/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "TextEntity.h"
#import "RichText.h"
#import "SWAppDelegate.h"


@implementation TextEntity

@dynamic id;
@dynamic len;
@dynamic name;
@dynamic pos;
@dynamic type;
@dynamic url;
@dynamic text;


+ (NSMutableSet *)createOrUpdateEntitesFromDictionary:(NSDictionary *)entityDict
{
    NSMutableSet *entities = [NSMutableSet new];
    
    NSArray *hashtags = [entityDict valueForKey:@"hashtags"];
    NSArray *links =    [entityDict valueForKey:@"links"];
    NSArray *mentions = [entityDict valueForKey:@"mentions"];
        
    for (NSDictionary *link in hashtags){
        [entities addObject:[self createOrUpdateEntityFromDictionary:link withType:@"hashtags"]];
    }
    for (NSDictionary *link in links) {
        [entities addObject:[self createOrUpdateEntityFromDictionary:link withType:@"links"]];
    }
    for (NSDictionary *link in mentions) {
        [entities addObject:[self createOrUpdateEntityFromDictionary:link withType:@"mentions"]];

    }
    
    return entities;
}


+ (TextEntity *)createOrUpdateEntityFromDictionary:(NSDictionary *)dictionary withType:(NSString *)type
{
    SWAppDelegate *appDelegate = (SWAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    TextEntity *entity = (TextEntity *)[NSEntityDescription insertNewObjectForEntityForName:@"TextEntity" inManagedObjectContext:managedObjectContext];
    entity.type = type;
    
    if ([dictionary objectForKey:@"id"]) entity.id = [dictionary objectForKey:@"id"];
    if ([dictionary objectForKey:@"len"]) entity.len = [dictionary objectForKey:@"len"];
    if ([dictionary objectForKey:@"pos"]) entity.pos = [dictionary objectForKey:@"pos"];
    if ([dictionary objectForKey:@"name"]) entity.name = [dictionary objectForKey:@"name"];
    if ([dictionary objectForKey:@"url"]) entity.url = [dictionary objectForKey:@"url"];

    return entity;
}

@end
