//
//  SWItemAPI.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/21/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWItemAPI.h"
#import "AFNetworking.h"
#import "SWAuthAPI.h"

@implementation SWItemAPI

+ (void)sendMethod:(NSString *)httpMethod
            toPath:(NSString *)path
        withParams:(NSMutableDictionary *)parameters
         completed:(void (^)(NSError *error, NSDictionary *item, NSDictionary *metadata))block
{
    if (!parameters) parameters = [NSMutableDictionary new];
    [SWAuthAPI addAuthTokenToParameters:parameters];

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://alpha-api.app.net"]];
    NSURLRequest *request = [httpClient requestWithMethod:httpMethod path:path parameters:parameters];
    AFHTTPRequestOperation *operation = [httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        DLog(@"RESPO: %@", response);
        block(nil, [response objectForKey:@"data"], [response objectForKey:@"meta"]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"HTTP Failure");
        block(nil,nil,nil);
    }];
    [httpClient enqueueHTTPRequestOperation:operation];

}



@end
