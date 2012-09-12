//
//  SWAuthAPI.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/11/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWAuthAPI : NSObject

+ (void)addAuthTokenToParameters:(NSMutableDictionary *)parameters;

@end
