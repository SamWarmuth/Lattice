//
//  RichText.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/24/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post, User;

@interface RichText : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSSet *entities;
@property (nonatomic, retain) Post *post;
@property (nonatomic, retain) User *user;
@end

@interface RichText (CoreDataGeneratedAccessors)

- (void)addEntitiesObject:(NSManagedObject *)value;
- (void)removeEntitiesObject:(NSManagedObject *)value;
- (void)addEntities:(NSSet *)values;
- (void)removeEntities:(NSSet *)values;

+ (RichText *)createOrUpdateRichTextFromDictionary:(NSDictionary *)dictionary;


@end
