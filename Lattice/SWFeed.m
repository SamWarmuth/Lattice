//
//  SWFeed.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/19/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWFeed.h"
#import "SWPostAPI.h"
#import "SWFeedAPI.h"
#import "Post.h"

@implementation SWFeed

+ (SWFeed *)feedWithType:(SWFeedType)type keyID:(NSString *)keyID
{
    SWFeed *feed = [SWFeed new];
    feed.minID = @"-1";
    feed.maxID = @"1000000000000000000";
    feed.type = type;
    feed.keyID = keyID;
    return feed;
}

- (NSPredicate *)predicate
{
    switch (self.type) {
        case SWFeedTypeConversation:
            return [NSPredicate predicateWithFormat:@"thread_id == %@", self.keyID];
        case SWFeedTypeUserStars:
            return [NSPredicate predicateWithFormat:@"you_starred == TRUE", self.keyID];
        case SWFeedTypeMyFeed:
            return [NSPredicate predicateWithFormat:@"user.you_follow == TRUE"];
        case SWFeedTypeUserPosts:
            return [NSPredicate predicateWithFormat:@"user.id == %@", self.keyID];
        case SWFeedTypeGlobal:
            return [NSPredicate predicateWithFormat:@"id != nil"];
        default:
            return [NSPredicate predicateWithFormat:@"id != nil"];
    }    
}

- (void)loadItemsWithBlock:(void (^)(NSError *error, NSMutableArray *posts))block
{
    [SWFeedAPI getFeedWithType:self.type keyID:self.keyID Min:nil max:nil reversed:FALSE completed:^(NSError *error, NSMutableArray *posts, NSDictionary *metadata) {
        self.minID = [metadata objectForKey:@"min_id"];
        self.maxID = [metadata objectForKey:@"max_id"];
        self.moreItemsAvailable = [[metadata objectForKey:@"more"] boolValue];
        [Post createOrUpdatePostsFromArray:posts];
        
        block(nil, nil);
    }];
}

- (void)loadOlderItemsWithBlock:(void (^)(NSError *error, NSMutableArray *posts))block
{
    if (!self.moreItemsAvailable) {
        block(nil, [NSMutableArray new]);
        return;
    }
    
    [SWFeedAPI getFeedWithType:self.type keyID:self.keyID Min:nil max:self.minID reversed:FALSE completed:^(NSError *error, NSMutableArray *posts, NSDictionary *metadata) {
        if ([metadata objectForKey:@"min_id"]){
            self.minID = [metadata objectForKey:@"min_id"];
            self.moreItemsAvailable = [[metadata objectForKey:@"more"] boolValue];
        }

        block(nil, posts);
    }];
}

- (void)loadNewerItemsWithBlock:(void (^)(NSError *error, NSMutableArray *posts))block
{
    [SWFeedAPI getFeedWithType:self.type keyID:self.keyID Min:self.maxID max:nil reversed:FALSE completed:^(NSError *error, NSMutableArray *posts, NSDictionary *metadata) {
        if ([metadata objectForKey:@"max_id"]){
            self.maxID = [metadata objectForKey:@"max_id"];
        }
        block(nil, posts);
    }];
}

@end
