//
//  SWPostAPI.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/11/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWFeed.h"

@interface SWPostAPI : NSObject


+ (void)getFeedWithType:(SWFeedType)type keyID:(NSString *)keyID Min:(NSString *)minID max:(NSString *)maxID reversed:(BOOL)reversed completed:(void (^)(NSError *error, NSMutableArray *posts, NSDictionary *metadata))block;

+ (void)loadPostsWithPath:(NSString *)path
                      min:(NSString *)minID
                      max:(NSString *)maxID
                 reversed:(BOOL)reversed
                completed:(void (^)(NSError *error, NSMutableArray *posts, NSDictionary *metadata))block;

+ (void)starPostID:(NSString *)postID completed:(void (^)(NSError *error, NSDictionary *post, NSDictionary *metadata))block;
+ (void)unstarPostID:(NSString *)postID completed:(void (^)(NSError *error, NSDictionary *post, NSDictionary *metadata))block;
+ (void)repostPostID:(NSString *)postID completed:(void (^)(NSError *error, NSDictionary *post, NSDictionary *metadata))block;
+ (void)unrepostPostID:(NSString *)postID completed:(void (^)(NSError *error, NSDictionary *post, NSDictionary *metadata))block;

+ (void)createPostWithText:(NSString *)text replyTo:(NSString *)userID completed:(void (^)(NSError *error, NSDictionary *post, NSDictionary *metadata))block;

@end
