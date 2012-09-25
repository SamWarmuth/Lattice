//
//  TextEntity.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/24/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RichText;

@interface TextEntity : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * len;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * pos;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) RichText * text;


+ (NSMutableSet *)createOrUpdateEntitesFromDictionary:(NSDictionary *)entityDict;
+ (TextEntity *)createOrUpdateEntityFromDictionary:(NSDictionary *)dictionary withType:(NSString *)type;

@end
