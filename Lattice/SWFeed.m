//
//  SWFeed.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/19/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWFeed.h"
#import "SWPostAPI.h"

@implementation SWFeed

+ (SWFeed *)feedWithType:(SWFeedType)type keyID:(NSString *)keyID
{
    SWFeed *feed = [SWFeed new];
    feed.type = type;
    feed.keyID = keyID;
    return feed;
}

- (void)loadItemsWithBlock:(void (^)(NSError *error, NSMutableArray *posts))block
{
    [SWPostAPI getFeedWithType:self.type keyID:self.keyID Min:nil max:nil reversed:FALSE completed:^(NSError *error, NSMutableArray *posts, NSDictionary *metadata) {
        self.minID = [metadata objectForKey:@"min_id"];
        self.maxID = [metadata objectForKey:@"max_id"];
        self.moreItemsAvailable = [[metadata objectForKey:@"more"] boolValue];
        block(nil, posts);
    }];
}

- (void)loadOlderItemsWithBlock:(void (^)(NSError *error, NSMutableArray *posts))block
{
    if (!self.moreItemsAvailable) {
        block(nil, [NSMutableArray new]);
        return;
    }
    
    [SWPostAPI getFeedWithType:self.type keyID:self.keyID Min:nil max:self.minID reversed:FALSE completed:^(NSError *error, NSMutableArray *posts, NSDictionary *metadata) {
        self.minID = [metadata objectForKey:@"min_id"];
        self.maxID = [metadata objectForKey:@"max_id"];
        self.moreItemsAvailable = [[metadata objectForKey:@"more"] boolValue];
        block(nil, posts);
    }];
}
- (void)loadNewerItemsWithBlock:(void (^)(NSError *error, NSMutableArray *posts))block
{
    [SWPostAPI getFeedWithType:self.type keyID:self.keyID Min:self.maxID max:nil reversed:FALSE completed:^(NSError *error, NSMutableArray *posts, NSDictionary *metadata) {
        self.minID = [metadata objectForKey:@"min_id"];
        self.maxID = [metadata objectForKey:@"max_id"];
        self.moreItemsAvailable = [[metadata objectForKey:@"more"] boolValue];
        block(nil, posts);
    }];
}

@end
