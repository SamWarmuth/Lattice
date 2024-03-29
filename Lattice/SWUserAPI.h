//
//  SWUserAPI.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/11/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface SWUserAPI : NSObject

+ (void)loadMyFollowersAndSave;
+ (void)loadMyFollowingAndSave;
+ (void)loadMyProfileAndSave;
+ (NSString *)myID;
+ (NSString *)myUsername;

+ (void)followUserID:(NSString *)userID completed:(void (^)(NSError *error, NSDictionary *user, NSDictionary *metadata))block;
+ (void)unfollowUserID:(NSString *)userID completed:(void (^)(NSError *error, NSDictionary *user, NSDictionary *metadata))block;

+ (void)getUserWithID:(NSString *)userID completed:(void (^)(NSError *error, NSDictionary *user, NSDictionary *metadata))block;

@end
