//
//  SWUserAPI.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/11/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWUserAPI : NSObject

+ (void)loadMyFollowersAndSave;
+ (void)loadMyFollowingAndSave;

+ (void)followUserID:(NSString *)userID completed:(void (^)(NSError *error, NSDictionary *user, NSDictionary *metadata))block;
+ (void)unfollowUserID:(NSString *)userID completed:(void (^)(NSError *error, NSDictionary *user, NSDictionary *metadata))block;

+ (void)getUserWithID:(NSString *)userID completed:(void (^)(NSError *error, NSDictionary *user, NSDictionary *metadata))block;
+ (void)getFollowersForUserID:(NSString *)userID min:(NSString *)minID max:(NSString *)maxID completed:(void (^)(NSError *error, NSMutableArray *users, NSDictionary *metadata))block;
+ (void)getFollowingForUserID:(NSString *)userID min:(NSString *)minID max:(NSString *)maxID completed:(void (^)(NSError *error, NSMutableArray *users, NSDictionary *metadata))block;
+ (void)loadUsersWithPath:(NSString *)path
                      min:(NSString *)minID
                      max:(NSString *)maxID
                completed:(void (^)(NSError *error, NSMutableArray *posts, NSDictionary *metadata))block;

+ (void)getUsersWithType:(SWUserType)type keyID:(NSString *)keyID Min:(NSString *)minID max:(NSString *)maxID reversed:(BOOL)reversed completed:(void (^)(NSError *error, NSMutableArray *posts, NSDictionary *metadata))block;

@end
