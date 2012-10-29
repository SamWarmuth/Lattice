//
//  Annotation.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/24/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "Annotation.h"
#import "NSDictionary+TypeChecked.h"
#import "SWAppDelegate.h"
#import "Image.h"
#import "Post.h"

@implementation Annotation

@dynamic annotationDescription;
@dynamic author_name;
@dynamic author_url;
@dynamic embeddable_url;
@dynamic height;
@dynamic horizontalAccuracy;
@dynamic html;
@dynamic latitude;
@dynamic longitude;
@dynamic provider_name;
@dynamic provider_url;
@dynamic subType;
@dynamic title;
@dynamic type;
@dynamic url;
@dynamic width;
@dynamic image;
@dynamic post;
@dynamic thumbnail;


+ (NSOrderedSet *)createOrUpdateAnnotationsFromArray:(NSArray *)annotationsArray
{
    NSMutableOrderedSet *annotations = [NSMutableOrderedSet new];

    for (NSDictionary *annotationDictionary in annotationsArray){
        [annotations addObject:[self createOrUpdateAnnotationFromDictionary:annotationDictionary]];
    }
    return annotations;
    
}

+ (Annotation *)createOrUpdateAnnotationFromDictionary:(NSDictionary *)dictionary
{
    SWAppDelegate *appDelegate = (SWAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    
    Annotation *annotation = (Annotation *)[NSEntityDescription insertNewObjectForEntityForName:@"Annotation" inManagedObjectContext:managedObjectContext];
        
    annotation.type = [dictionary objectForKey:@"type"];
    
    NSDictionary *valueDict = [dictionary objectForKey:@"value"];
    
    if ([valueDict objectForKey:@"author_name"]) annotation.author_name = [valueDict stringForKey:@"author_name"];
    if ([valueDict objectForKey:@"author_url"]) annotation.author_url = [valueDict stringForKey:@"author_url"];
    if ([valueDict objectForKey:@"embeddable_url"]) annotation.embeddable_url = [valueDict stringForKey:@"embeddable_url"];
    if ([valueDict objectForKey:@"horizontalAccuracy"]) annotation.horizontalAccuracy = [valueDict objectForKey:@"horizontalAccuracy"];
    if ([valueDict objectForKey:@"html"]) annotation.html = [valueDict stringForKey:@"html"];
    if ([valueDict objectForKey:@"latitude"]) annotation.latitude = [valueDict objectForKey:@"latitude"];
    if ([valueDict objectForKey:@"longitude"]) annotation.longitude = [valueDict objectForKey:@"longitude"];
    if ([valueDict objectForKey:@"provider_name"]) annotation.provider_name = [valueDict stringForKey:@"provider_name"];
    if ([valueDict objectForKey:@"provider_url"]) annotation.provider_url = [valueDict stringForKey:@"provider_url"];
    if ([valueDict objectForKey:@"type"]) annotation.subType = [valueDict stringForKey:@"type"];
    if ([valueDict objectForKey:@"title"]) annotation.title = [valueDict stringForKey:@"title"];
    if ([valueDict objectForKey:@"url"]) annotation.url = [valueDict stringForKey:@"url"];
    if ([valueDict objectForKey:@"height"]) annotation.height =  [valueDict numberForKey:@"height"];
    if ([valueDict objectForKey:@"width"]) annotation.width = [valueDict numberForKey:@"width"];
        
    return annotation;
}


@end
