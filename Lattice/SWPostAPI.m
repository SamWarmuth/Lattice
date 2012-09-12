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
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://alpha-api.app.net"]];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [SWAuthAPI addAuthTokenToParameters:parameters];
    
    if (minID) [parameters setObject:minID forKey:@"min_id"];
    if (maxID) [parameters setObject:maxID forKey:@"max_id"];
    
    [httpClient getPath:@"/stream/0/posts/stream" parameters:parameters success:^(AFHTTPRequestOperation *request, id rawResponseData) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rawResponseData options:kNilOptions error:nil];
        NSLog(@"%@", [response objectForKey:@"meta"]);

        block(nil, [response objectForKey:@"data"], [response objectForKey:@"meta"]);
    } failure:^(AFHTTPRequestOperation *request, NSError *error) {
        NSLog(@"Failure: %@", request.responseString);
        block(nil,nil,nil);
    }];
}

+ (void)getThreadWithID:(NSString *)threadID min:(NSString *)minID max:(NSString *)maxID completed:(void (^)(NSError *error, NSMutableArray *posts, NSDictionary *metadata))block
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://alpha-api.app.net"]];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [SWAuthAPI addAuthTokenToParameters:parameters];
    
    if (minID) [parameters setObject:minID forKey:@"min_id"];
    if (maxID) [parameters setObject:maxID forKey:@"max_id"];
    
    NSString *path = [NSString stringWithFormat:@"/stream/0/posts/%@/replies", threadID];
    [httpClient getPath:path parameters:parameters success:^(AFHTTPRequestOperation *request, id rawResponseData) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rawResponseData options:kNilOptions error:nil];
        NSLog(@"%@", [response objectForKey:@"meta"]);
        
        NSMutableArray *reversed = [[[[response objectForKey:@"data"] reverseObjectEnumerator] allObjects] mutableCopy];

        
        block(nil, reversed, [response objectForKey:@"meta"]);
    } failure:^(AFHTTPRequestOperation *request, NSError *error) {
        NSLog(@"Failure: %@", request.responseString);
        block(nil,nil,nil);
    }];
}

@end
