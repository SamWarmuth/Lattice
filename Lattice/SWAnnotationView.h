//
//  SWAnnotationView.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/20/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBYouTubePlayerViewController.h"

typedef enum {
    SWAnnotationTypePhoto,
    SWAnnotationTypeVideo,
    SWAnnotationTypeYoutube,
    SWAnnotationTypeGeolocation,
    SWAnnotationTypeUnknown
} SWAnnotationType;

@interface SWAnnotationView : UIView <LBYouTubePlayerControllerDelegate>

@property SWAnnotationType type;


+ (NSMutableArray *)autoAnnotationViewsFromPostDictionary:(NSDictionary *)postDict;
+ (SWAnnotationView *)annotationViewFromDictionary:(NSDictionary *)annotationData;
+ (SWAnnotationType)typeForAnnotationData:(NSDictionary *)annotationData;
+ (SWAnnotationView *)annotationViewWithPhotoData:(NSDictionary *)annotationData;
+ (SWAnnotationView *)annotationViewWithYoutubeURL:(NSURL *)videoURL;


+ (NSURL *)youtubeURLWithinString:(NSString *)string;

@end
