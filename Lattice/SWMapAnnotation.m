//
//  SWMapAnnotation.m
//  Lattice
//
//  Created by Kent McCullough on 9/21/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWMapAnnotation.h"

@implementation SWMapAnnotation
@synthesize coordinate;

- (NSString *)subtitle
{
    return nil;
}

- (NSString *)title
{
    return nil;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D) c
{
    coordinate = c;
    return self;
}

@end
