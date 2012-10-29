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
#import "Annotation.h"
#import "SWFullScreenImageView.h"
#import <MapKit/MapKit.h>

typedef enum {
    SWAnnotationTypePhoto,
    SWAnnotationTypeVideo,
    SWAnnotationTypeYoutube,
    SWAnnotationTypeGeolocation,
    SWAnnotationTypeUnknown
} SWAnnotationType;

@interface SWAnnotationView : UIView <LBYouTubePlayerControllerDelegate, MKMapViewDelegate, UIScrollViewDelegate>

@property SWAnnotationType type;
@property Annotation *annotation;
@property BOOL fullscreen;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) SWFullScreenImageView *fullScreenImageView;

+ (NSMutableArray *)annotationViewsFromPost:(Post *)post includeAuto:(BOOL)includeAuto fullscreen:(BOOL)fullscreen;
+ (SWAnnotationView *)annotationViewFromAnnotation:(Annotation *)annotationData fullscreen:(BOOL)fullscreen;
+ (SWAnnotationType)typeForAnnotationData:(Annotation *)annotationData;
+ (SWAnnotationView *)annotationViewWithPhotoData:(Annotation *)annotationData fullscreen:(BOOL)fullscreen;
+ (SWAnnotationView *)annotationViewWithGeoData:(Annotation *)annotationData fullscreen:(BOOL)fullscreen;
+ (SWAnnotationView *)annotationViewWithYoutubeURL:(NSURL *)videoURL fullscreen:(BOOL)fullscreen;

+ (NSURL *)youtubeURLWithinString:(NSString *)string;

@end
