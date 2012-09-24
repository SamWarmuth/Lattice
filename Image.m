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
    NSLog(@"Creating new Image");
    SWAppDelegate *appDelegate = (SWAppDelegate *)[[UIApplication sharedApplication] delegate];
    Image *image = (Image *)[NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:appDelegate.managedObjectContext];
    image.url = @"http://static.adzerk.net/Advertisers/d9a919813dac42adbd0e3106bc19bc04.png";
    return image;
}

@end
