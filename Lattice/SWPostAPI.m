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
#import "SWFeed.h"

@implementation SWPostAPI

+ (void)getFeedWithType:(SWFeedType)type keyID:(NSString *)keyID Min:(NSString *)minID max:(NSString *)maxID reversed:(BOOL)reversed completed:(void (^)(NSError *error, NSMutableArray *posts, NSDictionary *metadata))block
{
    NSDictionary *matchingDict = @{@(SWFeedTypeMyFeed)       : @"/stream/0/posts/stream",
                                   @(SWFeedTypeConversation) : [NSString stringWithFormat:@"/stream/0/posts/%@/replies",  keyID],
                                   @(SWFeedTypeUserPosts)    : [NSString stringWithFormat:@"/stream/0/users/%@/posts",    keyID],
                                   @(SWFeedTypeUserStars)    : [NSString stringWithFormat:@"/stream/0/users/%@/stars",    keyID],
                                   @(SWFeedTypeHashtag)      : [NSString stringWithFormat:@"stream/0/posts/tag/%@",       keyID],
                                   @(SWFeedTypeUserMentions) : [NSString stringWithFormat:@"stream/0/users/%@/mentions",  keyID],
                                   @(SWFeedTypeGlobal)       : @"/stream/0/posts/stream/global"
    };
    
    [self loadPostsWithPath:[matchingDict objectForKey:@(type)] min:minID max:maxID reversed:reversed completed:block];
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
    [parameters setObject:@0 forKey:@"include_directed_posts"];
    
    [httpClient getPath:path parameters:parameters success:^(AFHTTPRequestOperation *request, id rawResponseData) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rawResponseData options:kNilOptions error:nil];
        
        NSMutableArray *data;
        if (reversed) data = [[[[response objectForKey:@"data"] reverseObjectEnumerator] allObjects] mutableCopy];
        else data = [[response objectForKey:@"data"] mutableCopy];
        
        block(nil, data, [response objectForKey:@"meta"]);
    } failure:^(AFHTTPRequestOperation *request, NSError *error) {
        DLog(@"Failure: %@", request.responseString);
        block(nil,nil,nil);
    }];
    
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
        DLog(@"Failure: %@", request.responseString);
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
        DLog(@"Failure: %@", request.responseString);
        block(nil,nil,nil);
    }];
}

+ (void)repostPostID:(NSString *)postID completed:(void (^)(NSError *error, NSDictionary *post, NSDictionary *metadata))block
{
    DLog(@"REPOST!");

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://alpha-api.app.net"]];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [SWAuthAPI addAuthTokenToParameters:parameters];
    
    NSString *path = [NSString stringWithFormat:@"/stream/0/posts/%@/repost", postID];
    [httpClient postPath:path parameters:parameters success:^(AFHTTPRequestOperation *request, id rawResponseData) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rawResponseData options:kNilOptions error:nil];
        DLog(@"RESPO: %@", response);
        block(nil, [response objectForKey:@"data"], [response objectForKey:@"meta"]);
    } failure:^(AFHTTPRequestOperation *request, NSError *error) {
        DLog(@"Failure: %@", request.responseString);
        block(nil,nil,nil);
    }];
}

+ (void)unrepostPostID:(NSString *)postID completed:(void (^)(NSError *error, NSDictionary *post, NSDictionary *metadata))block
{
    DLog(@"UNREPOST!");
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://alpha-api.app.net"]];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [SWAuthAPI addAuthTokenToParameters:parameters];
    
    NSString *path = [NSString stringWithFormat:@"/stream/0/posts/%@/repost", postID];
    [httpClient deletePath:path parameters:parameters success:^(AFHTTPRequestOperation *request, id rawResponseData) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rawResponseData options:kNilOptions error:nil];
        DLog(@"RESPO: %@", response);
        block(nil, [response objectForKey:@"data"], [response objectForKey:@"meta"]);
    } failure:^(AFHTTPRequestOperation *request, NSError *error) {
        DLog(@"Failure: %@", request.responseString);
        block(nil,nil,nil);
    }];
}

+ (void)createPostWithText:(NSString *)text replyTo:(NSString *)userID completed:(void (^)(NSError *error, NSDictionary *post, NSDictionary *metadata))block
{
    DLog(@"Create Post!");
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://alpha-api.app.net"]];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [SWAuthAPI addAuthTokenToParameters:parameters];
    [parameters setObject:text forKey:@"text"];
    if (userID) [parameters setObject:userID forKey:@"reply_to"];
    
    NSString *path = [NSString stringWithFormat:@"/stream/0/posts"];
    [httpClient postPath:path parameters:parameters success:^(AFHTTPRequestOperation *request, id rawResponseData) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rawResponseData options:kNilOptions error:nil];
        DLog(@"RESPO: %@", response);
        block(nil, [response objectForKey:@"data"], [response objectForKey:@"meta"]);
    } failure:^(AFHTTPRequestOperation *request, NSError *error) {
        DLog(@"Failure: %@", request.responseString);
        block(nil,nil,nil);
    }];
}

@end
