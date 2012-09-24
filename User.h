//
//  User.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/24/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post, RichText, Image;

@interface User : NSManagedObject

@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * followers_count;
@property (nonatomic, retain) NSNumber * following_count;
@property (nonatomic, retain) NSNumber * follows_you;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * locale;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * posts_count;
@property (nonatomic, retain) NSNumber * stars_count;
@property (nonatomic, retain) NSString * timezone;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * you_follow;
@property (nonatomic, retain) NSNumber * you_muted;
@property (nonatomic, retain) Image *avatar_image;
@property (nonatomic, retain) Image *cover_image;
@property (nonatomic, retain) NSSet *posts;
@property (nonatomic, retain) RichText *userDescription;

+ (NSManagedObject *)objectForID:(NSString *)id;
+ (User *)createOrUpdateUserFromDictionary:(NSDictionary *)dictionary;


@end

@interface User (CoreDataGeneratedAccessors)

- (void)addPostsObject:(Post *)value;
- (void)removePostsObject:(Post *)value;
- (void)addPosts:(NSSet *)values;
- (void)removePosts:(NSSet *)values;

@end
