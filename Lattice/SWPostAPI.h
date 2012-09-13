//
//  SWPostAPI.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/11/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWPostAPI : NSObject

+ (void)getFeedWithMin:(NSString *)minID max:(NSString *)maxID completed:(void (^)(NSError *error, NSMutableArray *posts, NSDictionary *metadata))block;
+ (void)getThreadWithID:(NSString *)threadID min:(NSString *)minID max:(NSString *)maxID completed:(void (^)(NSError *error, NSMutableArray *posts, NSDictionary *metadata))block;
+ (void)getUserPostsWithID:(NSString *)userID min:(NSString *)minID max:(NSString *)maxID completed:(void (^)(NSError *error, NSMutableArray *posts, NSDictionary *metadata))block;
+ (void)getUserStarredWithID:(NSString *)userID min:(NSString *)minID max:(NSString *)maxID completed:(void (^)(NSError *error, NSMutableArray *posts, NSDictionary *metadata))block;
+ (NSMutableArray *)mutableArrayWithoutDeletedItems:(NSArray *)posts;

+ (void)loadPostsWithPath:(NSString *)path
                      min:(NSString *)minID
                      max:(NSString *)maxID
                 reversed:(BOOL)reversed
                completed:(void (^)(NSError *error, NSMutableArray *posts, NSDictionary *metadata))block;

@end
