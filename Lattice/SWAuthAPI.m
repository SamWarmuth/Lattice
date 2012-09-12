//
//  SWAuthAPI.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/11/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWAuthAPI.h"

@implementation SWAuthAPI

+ (void)addAuthTokenToParameters:(NSMutableDictionary *)parameters
{
    if (!parameters) return;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults objectForKey:@"SWAPToken"];
    
    [parameters setObject:token forKey:@"access_token"];
    
}
@end
