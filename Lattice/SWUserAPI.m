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

@implementation SWUserAPI

+ (void)getUsersWithType:(SWUserType)type keyID:(NSString *)keyID Min:(NSString *)minID max:(NSString *)maxID reversed:(BOOL)reversed completed:(void (^)(NSError *error, NSMutableArray *posts, NSDictionary *metadata))block
{
    NSDictionary *matchingDict = @{@(SWFeedTypeMyFeed)       : @"/stream/0/posts/stream",
    @(SWFeedTypeConversation) : [NSString stringWithFormat:@"/stream/0/posts/%@/replies",  keyID],
    @(SWFeedTypeUserPosts)    : [NSString stringWithFormat:@"/stream/0/users/%@/posts",    keyID],
    @(SWFeedTypeUserStars)    : [NSString stringWithFormat:@"/stream/0/users/%@/stars",    keyID],
    @(SWFeedTypeHashtag)      : [NSString stringWithFormat:@"stream/0/posts/tag/%@",       keyID],
    @(SWFeedTypeUserMentions) : [NSString stringWithFormat:@"stream/0/users/%@/mentions",  keyID],
    @(SWFeedTypeGlobal)       : @"/stream/0/posts/stream/global"
    };
    
    
    
    
    //[self loadPostsWithPath:[matchingDict objectForKey:@(type)] min:minID max:maxID reversed:reversed completed:block];
}


+ (void)loadMyFollowersAndSave
{
    [[self class] getFollowersForUserID:@"me" min:nil max:nil completed:^(NSError *error, NSMutableArray *users, NSDictionary *metadata) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *followerUsernames = [NSMutableArray new];
        for (NSDictionary *user in users){
            [followerUsernames addObject:[NSString stringWithFormat:@"@%@", [user objectForKey:@"username"]]];
        }
        [defaults setObject:followerUsernames forKey:@"SWMyFollowerUsernames"];
    }];
}

+ (void)loadMyFollowingAndSave
{
    [[self class] getFollowingForUserID:@"me" min:nil max:nil completed:^(NSError *error, NSMutableArray *users, NSDictionary *metadata) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *followerUsernames = [NSMutableArray new];
        for (NSDictionary *user in users){
            [followerUsernames addObject:[NSString stringWithFormat:@"@%@", [user objectForKey:@"username"]]];
        }
        [defaults setObject:followerUsernames forKey:@"SWMyFollowingUsernames"];
    }];
}

// Generic Methods

+ (void)followUserID:(NSString *)userID completed:(void (^)(NSError *error, NSDictionary *user, NSDictionary *metadata))block
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://alpha-api.app.net"]];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [SWAuthAPI addAuthTokenToParameters:parameters];
    
    NSString *path = [NSString stringWithFormat:@"/stream/0/users/%@/follow", userID];
    [httpClient postPath:path parameters:parameters success:^(AFHTTPRequestOperation *request, id rawResponseData) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rawResponseData options:kNilOptions error:nil];
        
        block(nil, [response objectForKey:@"data"], [response objectForKey:@"meta"]);
    } failure:^(AFHTTPRequestOperation *request, NSError *error) {
        DLog(@"Failure: %@", request.responseString);
        block(nil,nil,nil);
    }];
}
+ (void)unfollowUserID:(NSString *)userID completed:(void (^)(NSError *error, NSDictionary *user, NSDictionary *metadata))block
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://alpha-api.app.net"]];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [SWAuthAPI addAuthTokenToParameters:parameters];
    
    
    NSString *path = [NSString stringWithFormat:@"/stream/0/users/%@/follow", userID];
    [httpClient deletePath:path parameters:parameters success:^(AFHTTPRequestOperation *request, id rawResponseData) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rawResponseData options:kNilOptions error:nil];
        DLog(@"RESPO: %@", response);
        block(nil, [response objectForKey:@"data"], [response objectForKey:@"meta"]);
    } failure:^(AFHTTPRequestOperation *request, NSError *error) {
        DLog(@"Failure: %@", request.responseString);
        block(nil,nil,nil);
    }];
}

+ (void)getUserWithID:(NSString *)userID completed:(void (^)(NSError *error, NSDictionary *user, NSDictionary *metadata))block
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://alpha-api.app.net"]];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [SWAuthAPI addAuthTokenToParameters:parameters];

    
    NSString *path = [NSString stringWithFormat:@"/stream/0/users/%@", userID];
    [httpClient getPath:path parameters:parameters success:^(AFHTTPRequestOperation *request, id rawResponseData) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rawResponseData options:kNilOptions error:nil];
        //DLog(@"%@ - %@", [response objectForKey:@"data"], [response objectForKey:@"meta"]);
        
        block(nil, [response objectForKey:@"data"], [response objectForKey:@"meta"]);
    } failure:^(AFHTTPRequestOperation *request, NSError *error) {
        DLog(@"Failure: %@", request.responseString);
        block(nil,nil,nil);
    }];
}

+ (void)getFollowersForUserID:(NSString *)userID min:(NSString *)minID max:(NSString *)maxID completed:(void (^)(NSError *error, NSMutableArray *users, NSDictionary *metadata))block
{
    NSString *path = [NSString stringWithFormat:@"/stream/0/users/%@/followers", userID];
    [self loadUsersWithPath:path min:minID max:maxID completed:block];
}

+ (void)getFollowingForUserID:(NSString *)userID min:(NSString *)minID max:(NSString *)maxID completed:(void (^)(NSError *error, NSMutableArray *users, NSDictionary *metadata))block
{
    NSString *path = [NSString stringWithFormat:@"/stream/0/users/%@/following", userID];
    [self loadUsersWithPath:path min:minID max:maxID completed:block];
}

+ (void)loadUsersWithPath:(NSString *)path min:(NSString *)minID max:(NSString *)maxID completed:(void (^)(NSError *error, NSMutableArray *posts, NSDictionary *metadata))block
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://alpha-api.app.net"]];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [SWAuthAPI addAuthTokenToParameters:parameters];
    
    if (minID) [parameters setObject:minID forKey:@"since_id"];
    if (maxID) [parameters setObject:maxID forKey:@"before_id"];
    
    [parameters setObject:@200 forKey:@"count"];
    [parameters setObject:@0 forKey:@"include_deleted"];
    
    [httpClient getPath:path parameters:parameters success:^(AFHTTPRequestOperation *request, id rawResponseData) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rawResponseData options:kNilOptions error:nil];
        NSMutableArray *data = [[response objectForKey:@"data"] mutableCopy];        
        block(nil, data, [response objectForKey:@"meta"]);
    } failure:^(AFHTTPRequestOperation *request, NSError *error) {
        DLog(@"Failure: %@", request.responseString);
        block(nil,nil,nil);
    }];
}

@end
