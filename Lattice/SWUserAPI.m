//
//  SWUserAPI.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/11/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWUserAPI.h"
#import "SWAuthAPI.h"
#import "AFNetworking.h"
#import "SWFeed.h"
#import "SWFeedAPI.h"
#import "SWItemAPI.h"

@implementation SWUserAPI

+ (void)loadMyFollowersAndSave
{
    [SWFeedAPI getFeedWithType:SWFeedTypeUserFollowers keyID:@"me" Min:nil max:nil reversed:FALSE completed:^(NSError *error, NSMutableArray *posts, NSDictionary *metadata) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *followerUsernames = [NSMutableArray new];
        for (NSDictionary *user in posts){
            [followerUsernames addObject:[NSString stringWithFormat:@"@%@", [user objectForKey:@"username"]]];
        }
        [defaults setObject:followerUsernames forKey:@"SWMyFollowerUsernames"];
    }];
    return;
}

+ (void)loadMyFollowingAndSave
{
    [SWFeedAPI getFeedWithType:SWFeedTypeUserFollowers keyID:@"me" Min:nil max:nil reversed:FALSE completed:^(NSError *error, NSMutableArray *posts, NSDictionary *metadata) {
        NSMutableArray *followerUsernames = [NSMutableArray new];
        for (NSDictionary *user in posts){
            [followerUsernames addObject:[NSString stringWithFormat:@"@%@", [user objectForKey:@"username"]]];
        }
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:followerUsernames forKey:@"SWMyFollowingUsernames"];
    }];
}

+ (void)loadMyProfileAndSave
{
    [self getUserWithID:@"me" completed:^(NSError *error, NSDictionary *user, NSDictionary *metadata) {
        NSLog(@"user: %@", user);
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSString stringWithFormat:@"%@", [user objectForKey:@"id"]] forKey:@"SWMyID"];
        [defaults setObject:[NSString stringWithFormat:@"%@", [user objectForKey:@"username"]] forKey:@"SWMyUsername"];

    }];
}

+ (NSString *)myID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *myID = [defaults stringForKey:@"SWMyID"];
    if (!myID) return @"me";
    return myID;
}

+ (NSString *)myUsername
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *myID = [defaults stringForKey:@"SWMyUsername"];
    if (!myID) return @"me";
    return myID;
}

+ (void)followUserID:(NSString *)userID completed:(void (^)(NSError *error, NSDictionary *user, NSDictionary *metadata))block
{
    NSString *path = [NSString stringWithFormat:@"/stream/0/users/%@/follow", userID];
    [SWItemAPI sendMethod:SWHTTPMethodPost toPath:path withParams:nil completed:block];
}

+ (void)unfollowUserID:(NSString *)userID completed:(void (^)(NSError *error, NSDictionary *user, NSDictionary *metadata))block
{
    NSString *path = [NSString stringWithFormat:@"/stream/0/users/%@/follow", userID];
    [SWItemAPI sendMethod:SWHTTPMethodDelete toPath:path withParams:nil completed:block];
}

+ (void)getUserWithID:(NSString *)userID completed:(void (^)(NSError *error, NSDictionary *user, NSDictionary *metadata))block
{
    NSString *path = [NSString stringWithFormat:@"/stream/0/users/%@", userID];
    [SWItemAPI sendMethod:SWHTTPMethodGet toPath:path withParams:nil completed:block];
}

@end
