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
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *followerUsernames = [NSMutableArray new];
        for (NSDictionary *user in posts){
            [followerUsernames addObject:[NSString stringWithFormat:@"@%@", [user objectForKey:@"username"]]];
        }
        [defaults setObject:followerUsernames forKey:@"SWMyFollowingUsernames"];
    }];
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
