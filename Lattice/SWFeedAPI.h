//
//  SWFeedAPI.h
//  Lattice
//
//  Created by Kent McCullough on 9/20/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWFeed.h"


@interface SWFeedAPI : NSObject

+ (void)getFeedWithType:(SWFeedType)type keyID:(NSString *)keyID Min:(NSString *)minID max:(NSString *)maxID reversed:(BOOL)reversed completed:(void (^)(NSError *error, NSMutableArray *posts, NSDictionary *metadata))block;

+ (void)loadItemsWithPath:(NSString *)path
                      min:(NSString *)minID
                      max:(NSString *)maxID
                 reversed:(BOOL)reversed
                completed:(void (^)(NSError *error, NSMutableArray *posts, NSDictionary *metadata))block;

@end
