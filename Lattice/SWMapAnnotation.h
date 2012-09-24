//
//  SWMapAnnotation.h
//  Lattice
//
//  Created by Kent McCullough on 9/21/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface SWMapAnnotation : NSObject<MKAnnotation>

@property CLLocationCoordinate2D coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord;

@end
