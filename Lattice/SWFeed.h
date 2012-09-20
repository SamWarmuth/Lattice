//
//  SWFeed.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/19/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SWFeedTypeMyFeed,
    SWFeedTypeHashtag,
    SWFeedTypeUserPosts,
    SWFeedTypeUserStars,
    SWFeedTypeUserFollowers,
    SWFeedTypeUserFollowing,
    SWFeedTypeUserMentions,
    SWFeedTypeConversation,
    SWFeedTypeGlobal
} SWFeedType;



@interface SWFeed : NSObject

@property SWFeedType type;
@property (nonatomic, strong) NSString *minID, *maxID, *keyID;
@property BOOL moreItemsAvailable, reversed;

+ (SWFeed *)feedWithType:(SWFeedType)type keyID:(NSString *)keyID;

- (void)loadItemsWithBlock:(void (^)(NSError *error, NSMutableArray *posts))block;
- (void)loadOlderItemsWithBlock:(void (^)(NSError *error, NSMutableArray *posts))block;
- (void)loadNewerItemsWithBlock:(void (^)(NSError *error, NSMutableArray *posts))block;


@end
