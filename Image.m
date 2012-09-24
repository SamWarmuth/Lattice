//
//  Image.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/24/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "Image.h"
#import "Annotation.h"
#import "User.h"
#import "SWAppDelegate.h"


@implementation Image

@dynamic height;
@dynamic url;
@dynamic width;
@dynamic annotation;
@dynamic user;


+ (Image *)createOrUpdateImageFromDictionary:(NSDictionary *)dictionary
{
    SWAppDelegate *appDelegate = (SWAppDelegate *)[[UIApplication sharedApplication] delegate];
    Image *image = (Image *)[NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:appDelegate.managedObjectContext];
    image.url = [dictionary objectForKey:@"url"];
    return image;
}

@end
