//
//  Lattice.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/24/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Annotation, RichText, User;

@interface Post : NSManagedObject

@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * num_replies;
@property (nonatomic, retain) NSNumber * int_id;
@property (nonatomic, retain) NSString * thread_id;
@property (nonatomic, retain) NSNumber * you_reposted;
@property (nonatomic, retain) NSNumber * you_starred;
@property (nonatomic, retain) NSOrderedSet *annotations;
@property (nonatomic, retain) NSSet *replies;
@property (nonatomic, retain) Post *reply_to;
@property (nonatomic, retain) Post *repost_of;
@property (nonatomic, retain) NSSet *reposts;
@property (nonatomic, retain) RichText *text;
@property (nonatomic, retain) User *user;

+ (NSManagedObject *)objectForID:(NSString *)id;
+ (NSMutableArray *)createOrUpdatePostsFromArray:(NSMutableArray *)array;
+ (Post *)createOrUpdatePostFromDictionary:(NSDictionary *)dictionary;

@end

@interface Post (CoreDataGeneratedAccessors)

- (void)addRepliesObject:(Post *)value;
- (void)removeRepliesObject:(Post *)value;
- (void)addReplies:(NSSet *)values;
- (void)removeReplies:(NSSet *)values;

- (void)addRepostsObject:(Post *)value;
- (void)removeRepostsObject:(Post *)value;
- (void)addReposts:(NSSet *)values;
- (void)removeReposts:(NSSet *)values;

- (void)addAnnotationsObject:(Annotation *)value;
- (void)removeAnnotationsObject:(Annotation *)value;
- (void)addAnnotations:(NSSet *)values;
- (void)removeAnnotations:(NSSet *)values;

@end
