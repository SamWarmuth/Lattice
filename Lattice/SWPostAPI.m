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
#import "SWItemAPI.h"

@implementation SWPostAPI

+ (void)starPostID:(NSString *)postID completed:(void (^)(NSError *error, Post *post, NSDictionary *metadata))block
{
    NSString *path = [NSString stringWithFormat:@"/stream/0/posts/%@/star", postID];
    [SWItemAPI sendMethod:SWHTTPMethodPost toPath:path withParams:nil completed:^(NSError *error, NSDictionary *item, NSDictionary *metadata) {
        Post *post = [Post createOrUpdatePostFromDictionary:item];
        block(nil, post, metadata);
    }];
}

+ (void)unstarPostID:(NSString *)postID completed:(void (^)(NSError *error, Post *post, NSDictionary *metadata))block
{
    NSString *path = [NSString stringWithFormat:@"/stream/0/posts/%@/star", postID];
    [SWItemAPI sendMethod:SWHTTPMethodDelete toPath:path withParams:nil completed:^(NSError *error, NSDictionary *item, NSDictionary *metadata) {
        Post *post = [Post createOrUpdatePostFromDictionary:item];
        block(nil, post, metadata);
    }];
}

+ (void)repostPostID:(NSString *)postID completed:(void (^)(NSError *error, Post *post, NSDictionary *metadata))block
{
    NSString *path = [NSString stringWithFormat:@"/stream/0/posts/%@/repost", postID];
    [SWItemAPI sendMethod:SWHTTPMethodPost toPath:path withParams:nil completed:^(NSError *error, NSDictionary *item, NSDictionary *metadata) {
        Post *post = [Post createOrUpdatePostFromDictionary:item];
        block(nil, post, metadata);
    }];
}

+ (void)unrepostPostID:(NSString *)postID completed:(void (^)(NSError *error, Post *post, NSDictionary *metadata))block
{
    NSString *path = [NSString stringWithFormat:@"/stream/0/posts/%@/repost", postID];
    [SWItemAPI sendMethod:SWHTTPMethodDelete toPath:path withParams:nil completed:^(NSError *error, NSDictionary *item, NSDictionary *metadata) {
        Post *post = [Post createOrUpdatePostFromDictionary:item];
        block(nil, post, metadata);
    }];
}

+ (void)createPostWithText:(NSString *)text replyTo:(NSString *)userID completed:(void (^)(NSError *error, Post *post, NSDictionary *metadata))block
{
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setObject:text forKey:@"text"];
    if (userID) [parameters setObject:userID forKey:@"reply_to"];
    NSString *path = [NSString stringWithFormat:@"/stream/0/posts"];
    [SWItemAPI sendMethod:SWHTTPMethodPost toPath:path withParams:parameters completed:^(NSError *error, NSDictionary *item, NSDictionary *metadata) {
        Post *post = [Post createOrUpdatePostFromDictionary:item];
        block(nil, post, metadata);
    }];
}

@end
