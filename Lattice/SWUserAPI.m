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

@implementation SWUserAPI

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
        NSLog(@"Failure: %@", request.responseString);
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
        NSLog(@"RESPO: %@", response);
        block(nil, [response objectForKey:@"data"], [response objectForKey:@"meta"]);
    } failure:^(AFHTTPRequestOperation *request, NSError *error) {
        NSLog(@"Failure: %@", request.responseString);
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
        //NSLog(@"%@ - %@", [response objectForKey:@"data"], [response objectForKey:@"meta"]);
        
        block(nil, [response objectForKey:@"data"], [response objectForKey:@"meta"]);
    } failure:^(AFHTTPRequestOperation *request, NSError *error) {
        NSLog(@"Failure: %@", request.responseString);
        block(nil,nil,nil);
    }];
}

+ (void)getFollowersForUserID:(NSString *)userID min:(NSString *)minID max:(NSString *)maxID completed:(void (^)(NSError *error, NSMutableArray *posts, NSDictionary *metadata))block
{
    NSString *path = [NSString stringWithFormat:@"/stream/0/users/%@/followers", userID];
    [self loadUsersWithPath:path min:minID max:maxID completed:block];
}

+ (void)getFollowingForUserID:(NSString *)userID min:(NSString *)minID max:(NSString *)maxID completed:(void (^)(NSError *error, NSMutableArray *posts, NSDictionary *metadata))block
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
    
    [parameters setObject:@40 forKey:@"count"];
    [parameters setObject:@0 forKey:@"include_deleted"];
    
    [httpClient getPath:path parameters:parameters success:^(AFHTTPRequestOperation *request, id rawResponseData) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rawResponseData options:kNilOptions error:nil];
        NSMutableArray *data = [[response objectForKey:@"data"] mutableCopy];        
        block(nil, data, [response objectForKey:@"meta"]);
    } failure:^(AFHTTPRequestOperation *request, NSError *error) {
        NSLog(@"Failure: %@", request.responseString);
        block(nil,nil,nil);
    }];
}

@end
