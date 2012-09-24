//
//  Annotation.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/24/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "Annotation.h"
#import "Post.h"
#import "Image.h"
#import "SWAppDelegate.h"

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
    
    if ([valueDict objectForKey:@"author_name"]) annotation.author_name = [valueDict objectForKey:@"author_name"];
    if ([valueDict objectForKey:@"author_url"]) annotation.author_url = [valueDict objectForKey:@"author_url"];
    if ([valueDict objectForKey:@"embeddable_url"]) annotation.embeddable_url = [valueDict objectForKey:@"embeddable_url"];
    if ([valueDict objectForKey:@"height"]) annotation.height = [valueDict objectForKey:@"height"];
    if ([valueDict objectForKey:@"horizontalAccuracy"]) annotation.horizontalAccuracy = [valueDict objectForKey:@"horizontalAccuracy"];
    if ([valueDict objectForKey:@"html"]) annotation.html = [valueDict objectForKey:@"html"];
    if ([valueDict objectForKey:@"latitude"]) annotation.latitude = [valueDict objectForKey:@"latitude"];
    if ([valueDict objectForKey:@"longitude"]) annotation.longitude = [valueDict objectForKey:@"longitude"];
    if ([valueDict objectForKey:@"provider_name"]) annotation.provider_name = [valueDict objectForKey:@"provider_name"];
    if ([valueDict objectForKey:@"provider_url"]) annotation.provider_url = [valueDict objectForKey:@"provider_url"];
    if ([valueDict objectForKey:@"type"]) annotation.subType = [valueDict objectForKey:@"type"];
    if ([valueDict objectForKey:@"title"]) annotation.title = [valueDict objectForKey:@"title"];
    if ([valueDict objectForKey:@"url"]) annotation.url = [valueDict objectForKey:@"url"];
    if ([valueDict objectForKey:@"width"]) annotation.width = [valueDict objectForKey:@"width"];
    
    
    return annotation;
}

@end
