//
//  SWItemAPI.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/21/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SWHTTPMethodGet    @"GET"
#define SWHTTPMethodPost   @"POST"
#define SWHTTPMethodDelete @"DELETE"

@interface SWItemAPI : NSObject

+ (void)sendMethod:(NSString *)httpMethod toPath:(NSString *)path withParams:(NSMutableDictionary *)parameters completed:(void (^)(NSError *error, NSDictionary *item, NSDictionary *metadata))block;



@end
