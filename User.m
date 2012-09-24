//
//  User.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/24/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "User.h"
#import "Post.h"
#import "Image.h"
#import "RichText.h"
#import "SWAppDelegate.h"


@implementation User

@dynamic created_at;
@dynamic following_count;
@dynamic followers_count;
@dynamic follows_you;
@dynamic id;
@dynamic locale;
@dynamic name;
@dynamic posts_count;
@dynamic stars_count;
@dynamic timezone;
@dynamic type;
@dynamic username;
@dynamic you_follow;
@dynamic you_muted;
@dynamic avatar_image;
@dynamic cover_image;
@dynamic posts;
@dynamic userDescription;

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

+ (User *)createOrUpdateUserFromDictionary:(NSDictionary *)dictionary
{
    SWAppDelegate *appDelegate = (SWAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    User *user = (User *)[self objectForID:[dictionary objectForKey:@"id"]];
    if (!user) user = (User *)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:appDelegate.managedObjectContext];
    
    
    user.name = [dictionary objectForKey:@"name"];
    user.username = [dictionary objectForKey:@"username"];
    user.avatar_image = [Image createOrUpdateImageFromDictionary:[dictionary objectForKey:@"avatar_image"]];
    user.you_follow = [dictionary objectForKey:@"you_follow"];

    
    return user;
}


@end
