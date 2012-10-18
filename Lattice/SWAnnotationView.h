//
//  SWAnnotationView.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/20/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBYouTubePlayerViewController.h"
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
@property NSDictionary *annotation;
@property BOOL fullscreen;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

+ (NSMutableArray *)annotationViewsFromPostDictionary:(NSDictionary *)postDict includeAuto:(BOOL)includeAuto fullscreen:(BOOL)fullscreen;
+ (SWAnnotationView *)annotationViewFromAnnotationDictionary:(NSDictionary *)annotationData fullscreen:(BOOL)fullscreen;
+ (SWAnnotationType)typeForAnnotationData:(NSDictionary *)annotationData;
+ (SWAnnotationView *)annotationViewWithPhotoData:(NSDictionary *)annotationData fullscreen:(BOOL)fullscreen;
+ (SWAnnotationView *)annotationViewWithGeoData:(NSDictionary *)annotationData fullscreen:(BOOL)fullscreen;
+ (SWAnnotationView *)annotationViewWithYoutubeURL:(NSURL *)videoURL fullscreen:(BOOL)fullscreen;


+ (NSURL *)youtubeURLWithinString:(NSString *)string;

@end
