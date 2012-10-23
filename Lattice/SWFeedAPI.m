//
//  SWFeedAPI.m
//  Lattice
//
//  Created by Kent McCullough on 9/20/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWFeedAPI.h"
#import "AFNetworking.h"
#import "SWAuthAPI.h"
#import "SWFeed.h"

@implementation SWFeedAPI


+ (void)getFeedWithType:(SWFeedType)type keyID:(NSString *)keyID Min:(NSString *)minID max:(NSString *)maxID reversed:(BOOL)reversed completed:(void (^)(NSError *error, NSMutableArray *posts, NSDictionary *metadata))block
{
    NSDictionary *matchingDict = @{@(SWFeedTypeMyFeed)        : @"/stream/0/posts/stream",
                                   @(SWFeedTypeHashtag)       : [NSString stringWithFormat:@"stream/0/posts/tag/%@",        keyID],
                                   @(SWFeedTypeUserPosts)     : [NSString stringWithFormat:@"/stream/0/users/%@/posts",     keyID],
                                   @(SWFeedTypeUserStars)     : [NSString stringWithFormat:@"/stream/0/users/%@/stars",     keyID],
                                   @(SWFeedTypeUserFollowers) : [NSString stringWithFormat:@"/stream/0/users/%@/followers", keyID],
                                   @(SWFeedTypeUserFollowing) : [NSString stringWithFormat:@"/stream/0/users/%@/following", keyID],
                                   @(SWFeedTypeUserMentions)  : [NSString stringWithFormat:@"stream/0/users/%@/mentions",   keyID],
                                   @(SWFeedTypeConversation)  : [NSString stringWithFormat:@"/stream/0/posts/%@/replies",   keyID],
                                   @(SWFeedTypeGlobal)        : @"/stream/0/posts/stream/global"
    };
    
    [self loadItemsWithPath:[matchingDict objectForKey:@(type)] min:minID max:maxID reversed:reversed completed:block];
}

+ (void)loadItemsWithPath:(NSString *)path
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
    
    [parameters setObject:@20 forKey:@"count"]; //200 for loadUsersWithPath
    [parameters setObject:@0 forKey:@"include_deleted"];
    [parameters setObject:@1 forKey:@"include_annotations"];
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

@end
