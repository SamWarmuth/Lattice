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

+ (NSManagedObject *)objectForID:(NSString *)id
{
    SWAppDelegate *appDelegate = (SWAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    
    NSError *error;
    NSFetchRequest *existsFetch = [[NSFetchRequest alloc] init];
    [existsFetch setEntity:[NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:managedObjectContext]];
    [existsFetch setFetchLimit:1];
    [existsFetch setPredicate:[NSPredicate predicateWithFormat:@"id == %@", id]];
    return [[managedObjectContext executeFetchRequest:existsFetch error:&error] lastObject];
}

@end
