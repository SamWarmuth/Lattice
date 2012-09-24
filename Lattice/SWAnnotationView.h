//
//  SWAnnotationView.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/20/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBYouTubePlayerViewController.h"
#import "Post.h"

typedef enum {
    SWAnnotationTypePhoto,
    SWAnnotationTypeVideo,
    SWAnnotationTypeYoutube,
    SWAnnotationTypeGeolocation,
    SWAnnotationTypeUnknown
} SWAnnotationType;

@interface SWAnnotationView : UIView <LBYouTubePlayerControllerDelegate>

@property SWAnnotationType type;


+ (NSMutableArray *)annotationViewsFromPost:(Post *)postDict includeAuto:(BOOL)includeAuto;
+ (SWAnnotationView *)annotationViewFromAnnotationDictionary:(NSDictionary *)annotationData;
+ (SWAnnotationType)typeForAnnotationData:(NSDictionary *)annotationData;
+ (SWAnnotationView *)annotationViewWithPhotoData:(NSDictionary *)annotationData;
+ (SWAnnotationView *)annotationViewWithGeoData:(NSDictionary *)annotationData;
+ (SWAnnotationView *)annotationViewWithYoutubeURL:(NSURL *)videoURL;


+ (NSURL *)youtubeURLWithinString:(NSString *)string;

@end
