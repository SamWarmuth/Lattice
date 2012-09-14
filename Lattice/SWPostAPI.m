//
//  SWPostAPI.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/11/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWPostAPI.h"
#import "AFNetworking.h"
#import "SWAuthAPI.h"

@implementation SWPostAPI

+ (void)getFeedWithMin:(NSString *)minID max:(NSString *)maxID completed:(void (^)(NSError *error, NSMutableArray *posts, NSDictionary *metadata))block
{
    NSString *path = @"/stream/0/posts/stream";
    [self loadPostsWithPath:path min:minID max:maxID reversed:FALSE completed:block];
}

+ (void)getThreadWithID:(NSString *)threadID
                    min:(NSString *)minID
                    max:(NSString *)maxID
              completed:(void (^)(NSError *error, NSMutableArray *posts, NSDictionary *metadata))block
{
    NSString *path = [NSString stringWithFormat:@"/stream/0/posts/%@/replies", threadID];
    [self loadPostsWithPath:path min:minID max:maxID reversed:TRUE completed:block];
}

+ (void)getUserPostsWithID:(NSString *)userID
                       min:(NSString *)minID
                       max:(NSString *)maxID
                 completed:(void (^)(NSError *error, NSMutableArray *posts, NSDictionary *metadata))block
{
    NSString *path = [NSString stringWithFormat:@"/stream/0/users/%@/posts", userID];
    [self loadPostsWithPath:path min:minID max:maxID reversed:FALSE completed:block];
}

+ (void)getUserStarredWithID:(NSString *)userID
                         min:(NSString *)minID
                         max:(NSString *)maxID
                   completed:(void (^)(NSError *error, NSMutableArray *posts, NSDictionary *metadata))block
{
    NSString *path = [NSString stringWithFormat:@"/stream/0/users/%@/stars", userID];
    [self loadPostsWithPath:path min:minID max:maxID reversed:FALSE completed:block];
}

+ (void)getPostsWithHashtag:(NSString *)hashtag
                        min:(NSString *)minID
                        max:(NSString *)maxID
                  completed:(void (^)(NSError *error, NSMutableArray *posts, NSDictionary *metadata))block
{
    NSString *path = [NSString stringWithFormat:@"stream/0/posts/tag/%@", [hashtag substringFromIndex:1]];
    [self loadPostsWithPath:path min:minID max:maxID reversed:FALSE completed:block];
}


+ (void)loadPostsWithPath:(NSString *)path
                      min:(NSString *)minID
                      max:(NSString *)maxID
                 reversed:(BOOL)reversed
                completed:(void (^)(NSError *error, NSMutableArray *posts, NSDictionary *metadata))block
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://alpha-api.app.net"]];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [SWAuthAPI addAuthTokenToParameters:parameters];
    
    if (minID) [parameters setObject:minID forKey:@"since_id"];
    if (maxID) [parameters setObject:maxID forKey:@"before_id"];
    
    [parameters setObject:@40 forKey:@"count"];
    [parameters setObject:@0 forKey:@"include_deleted"];
    [parameters setObject:@1 forKey:@"include_directed_posts"];
    
    [httpClient getPath:path parameters:parameters success:^(AFHTTPRequestOperation *request, id rawResponseData) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rawResponseData options:kNilOptions error:nil];
        
        NSMutableArray *data;
        if (reversed) data = [[[[response objectForKey:@"data"] reverseObjectEnumerator] allObjects] mutableCopy];
        else data = [[response objectForKey:@"data"] mutableCopy];
        
        block(nil, data, [response objectForKey:@"meta"]);
    } failure:^(AFHTTPRequestOperation *request, NSError *error) {
        NSLog(@"Failure: %@", request.responseString);
        block(nil,nil,nil);
    }];
}

+ (NSMutableArray *)mutableArrayWithoutDeletedItems:(NSArray *)posts
{
    NSMutableArray *filtered = [NSMutableArray new];
    for (NSDictionary *post in posts){
        if (![post objectForKey:@"is_deleted"] || [[post objectForKey:@"is_deleted"] intValue] != 1) [filtered addObject:post];
    }
    return filtered;
}

+ (void)starPostID:(NSString *)postID completed:(void (^)(NSError *error, NSDictionary *post, NSDictionary *metadata))block
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://alpha-api.app.net"]];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [SWAuthAPI addAuthTokenToParameters:parameters];
    
    NSString *path = [NSString stringWithFormat:@"/stream/0/posts/%@/star", postID];
    [httpClient postPath:path parameters:parameters success:^(AFHTTPRequestOperation *request, id rawResponseData) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rawResponseData options:kNilOptions error:nil];
        
        block(nil, [response objectForKey:@"data"], [response objectForKey:@"meta"]);
    } failure:^(AFHTTPRequestOperation *request, NSError *error) {
        NSLog(@"Failure: %@", request.responseString);
        block(nil,nil,nil);
    }];
}

+ (void)unstarPostID:(NSString *)postID completed:(void (^)(NSError *error, NSDictionary *post, NSDictionary *metadata))block
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://alpha-api.app.net"]];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [SWAuthAPI addAuthTokenToParameters:parameters];
    
    NSString *path = [NSString stringWithFormat:@"/stream/0/posts/%@/star", postID];
    [httpClient deletePath:path parameters:parameters success:^(AFHTTPRequestOperation *request, id rawResponseData) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rawResponseData options:kNilOptions error:nil];
        
        block(nil, [response objectForKey:@"data"], [response objectForKey:@"meta"]);
    } failure:^(AFHTTPRequestOperation *request, NSError *error) {
        NSLog(@"Failure: %@", request.responseString);
        block(nil,nil,nil);
    }];
}

+ (void)repostPostID:(NSString *)postID completed:(void (^)(NSError *error, NSDictionary *post, NSDictionary *metadata))block
{
    NSLog(@"REPOST!");

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://alpha-api.app.net"]];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [SWAuthAPI addAuthTokenToParameters:parameters];
    
    NSString *path = [NSString stringWithFormat:@"/stream/0/posts/%@/repost", postID];
    [httpClient postPath:path parameters:parameters success:^(AFHTTPRequestOperation *request, id rawResponseData) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rawResponseData options:kNilOptions error:nil];
        NSLog(@"RESPO: %@", response);
        block(nil, [response objectForKey:@"data"], [response objectForKey:@"meta"]);
    } failure:^(AFHTTPRequestOperation *request, NSError *error) {
        NSLog(@"Failure: %@", request.responseString);
        block(nil,nil,nil);
    }];
}

+ (void)unrepostPostID:(NSString *)postID completed:(void (^)(NSError *error, NSDictionary *post, NSDictionary *metadata))block
{
    NSLog(@"UNREPOST!");
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://alpha-api.app.net"]];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [SWAuthAPI addAuthTokenToParameters:parameters];
    
    NSString *path = [NSString stringWithFormat:@"/stream/0/posts/%@/repost", postID];
    [httpClient deletePath:path parameters:parameters success:^(AFHTTPRequestOperation *request, id rawResponseData) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rawResponseData options:kNilOptions error:nil];
        NSLog(@"RESPO: %@", response);
        block(nil, [response objectForKey:@"data"], [response objectForKey:@"meta"]);
    } failure:^(AFHTTPRequestOperation *request, NSError *error) {
        NSLog(@"Failure: %@", request.responseString);
        block(nil,nil,nil);
    }];
}

@end
