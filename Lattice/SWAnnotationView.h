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

+ (NSMutableArray *)annotationViewsFromPost:(Post *)post includeAuto:(BOOL)includeAuto;
+ (SWAnnotationView *)annotationViewFromAnnotation:(Annotation *)annotationData;
+ (SWAnnotationType)typeForAnnotationData:(Annotation *)annotationData;
+ (SWAnnotationView *)annotationViewWithPhotoData:(Annotation *)annotationData;
+ (SWAnnotationView *)annotationViewWithGeoData:(Annotation *)annotationData;
+ (SWAnnotationView *)annotationViewWithYoutubeURL:(NSURL *)videoURL fullscreen:(BOOL)fullscreen;

+ (NSURL *)youtubeURLWithinString:(NSString *)string;

@end
