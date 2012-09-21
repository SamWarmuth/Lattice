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

+ (void)starPostID:(NSString *)postID completed:(void (^)(NSError *error, NSDictionary *post, NSDictionary *metadata))block;
+ (void)unstarPostID:(NSString *)postID completed:(void (^)(NSError *error, NSDictionary *post, NSDictionary *metadata))block;
+ (void)repostPostID:(NSString *)postID completed:(void (^)(NSError *error, NSDictionary *post, NSDictionary *metadata))block;
+ (void)unrepostPostID:(NSString *)postID completed:(void (^)(NSError *error, NSDictionary *post, NSDictionary *metadata))block;

+ (void)createPostWithText:(NSString *)text replyTo:(NSString *)userID completed:(void (^)(NSError *error, NSDictionary *post, NSDictionary *metadata))block;

@end
