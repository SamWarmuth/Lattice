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
