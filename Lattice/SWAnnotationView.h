//
//  SWAnnotationView.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/20/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SWAnnotationTypePhoto,
    SWAnnotationTypeVideo,
    SWAnnotationTypeUnknown
} SWAnnotationType;

@interface SWAnnotationView : UIView

@property SWAnnotationType type;


+ (NSMutableArray *)autoAnnotationViewsFromPostDictionary:(NSDictionary *)postDict;
+ (SWAnnotationView *)annotationViewFromDictionary:(NSDictionary *)annotationData;
+ (SWAnnotationType)typeForAnnotationData:(NSDictionary *)annotationData;
+ (SWAnnotationView *)annotationViewWithPhotoData:(NSDictionary *)annotationData;

+ (NSURL *)youtubeURLWithinString:(NSString *)string;

@end
