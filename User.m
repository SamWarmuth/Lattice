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

+ (User *)createOrUpdateUserFromDictionary:(NSDictionary *)dictionary
{
    NSLog(@"Creating new User");
    SWAppDelegate *appDelegate = (SWAppDelegate *)[[UIApplication sharedApplication] delegate];
    User *user = (User *)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:appDelegate.managedObjectContext];
    user.name = @"rands";
    user.avatar_image = [Image createOrUpdateImageFromDictionary:dictionary];
    
    return user;
}


@end
