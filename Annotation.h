//
//  Annotation.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/24/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post, Image;

@interface Annotation : NSManagedObject

@property (nonatomic, retain) NSString * annotationDescription;
@property (nonatomic, retain) NSString * author_name;
@property (nonatomic, retain) NSString * author_url;
@property (nonatomic, retain) NSString * embeddable_url;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSDecimalNumber * horizontalAccuracy;
@property (nonatomic, retain) NSString * html;
@property (nonatomic, retain) NSDecimalNumber * latitude;
@property (nonatomic, retain) NSDecimalNumber * longitude;
@property (nonatomic, retain) NSString * provider_name;
@property (nonatomic, retain) NSString * provider_url;
@property (nonatomic, retain) NSString * subType;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) Image *image;
@property (nonatomic, retain) Post *post;
@property (nonatomic, retain) Image *thumbnail;

@end
