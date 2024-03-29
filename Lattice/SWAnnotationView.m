//
//  SWAnnotationView.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/20/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWAnnotationView.h"
#import "AFNetworking.h"
#import "SWPhotoImageView.h"
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SWMapAnnotation.h"
#import "RichText.h"
#import "SWFullScreenImageView.h"

@implementation SWAnnotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (NSMutableArray *)annotationViewsFromPost:(Post *)post includeAuto:(BOOL)includeAuto fullscreen:(BOOL)fullscreen
{
    NSMutableArray *annotationViews = [NSMutableArray new];
    if (includeAuto) {
        NSURL *youtubeURL = [self youtubeURLWithinString:post.text.text];
        if (youtubeURL) {
            [annotationViews addObject:[self annotationViewWithYoutubeURL:youtubeURL fullscreen:fullscreen]];
        }
    }
    
    NSOrderedSet *annotations = post.annotations;
    if (!annotations) return annotationViews;
            
    for (Annotation *annotation in annotations){
        SWAnnotationView *newAnnotationView = [SWAnnotationView annotationViewFromAnnotation:annotation fullscreen:fullscreen];
        if (newAnnotationView) [annotationViews addObject:newAnnotationView];
    }
    return annotationViews;
}

+ (SWAnnotationView *)annotationViewFromAnnotation:(Annotation *)annotation fullscreen:(BOOL)fullscreen
{
    SWAnnotationType type = [self typeForAnnotationData:annotation];
    switch (type) {
        case SWAnnotationTypePhoto:
            return [self annotationViewWithPhotoData:annotation fullscreen:fullscreen];
        case SWAnnotationTypeGeolocation:
            return [self annotationViewWithGeoData:annotation fullscreen:fullscreen];
        case SWAnnotationTypeUnknown:
            return nil;
        default:
            break;
    }
    
    return nil;
}

+ (SWAnnotationType)typeForAnnotationData:(Annotation *)annotation
{
    if ([annotation.type isEqualToString:@"net.app.core.oembed"]) {        
        if ([annotation.subType isEqualToString:@"photo"]) return SWAnnotationTypePhoto;
    } else if ([annotation.type isEqualToString:@"net.app.core.geolocation"]) {
        return SWAnnotationTypeGeolocation;
    }
    
    return SWAnnotationTypeUnknown;
}

+ (SWAnnotationView *)annotationViewWithPhotoData:(Annotation *)annotation fullscreen:(BOOL)fullscreen
{
    SWAnnotationView *annotationView = [SWAnnotationView new];
    annotationView.annotation = annotation;
    annotationView.autoresizesSubviews = TRUE;
    annotationView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    annotationView.backgroundColor = [UIColor clearColor];
    annotationView.clipsToBounds = TRUE;
    annotationView.type = SWAnnotationTypePhoto;

    NSString *photoURLString = annotation.url;
    CGFloat width = [annotation.width floatValue];
    CGFloat height = [annotation.height floatValue];    
    
    if (fullscreen) {
        annotationView.frame = CGRectMake(0, 0, 320, 416); //set the annotationView.frame to what it is in storyboard
        annotationView.fullScreenImageView = [[SWFullScreenImageView alloc] initWithFrame:annotationView.frame]; //create fullScreenImageView with annotationView's frame settings
        annotationView.fullScreenImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth; //resize fullScreenImageView to match annotationView always
        
        annotationView.fullScreenImageView.imageView.frame = CGRectMake(0, 0, width, height); //set the frame of the imageview to the image size
        annotationView.fullScreenImageView.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [annotationView.fullScreenImageView.imageView setImageWithURL:[NSURL URLWithString:photoURLString]]; //set the image from the url in annotation data
        annotationView.fullScreenImageView.scrollView.contentSize = CGSizeMake(width, height); //content size is actual size of image
        CGFloat scaledWidth = annotationView.fullScreenImageView.scrollView.frame.size.width / annotationView.fullScreenImageView.scrollView.contentSize.width; //scale the width of (screen size / image size)
        CGFloat scaledHeight = annotationView.fullScreenImageView.scrollView.frame.size.height / annotationView.fullScreenImageView.scrollView.contentSize.height; //scale the height of (screen size / image size)
        CGFloat minScale = MIN(scaledWidth, scaledHeight); //get the minimum between scaledWidth and scaledHeight
        annotationView.fullScreenImageView.scrollView.minimumZoomScale = minScale; //minimum zoom scale is above value (meaning whole image will fit on screen)
        annotationView.fullScreenImageView.scrollView.maximumZoomScale = 2.0f; //set max zoom (arbitrairily set to 2x regular image)
        annotationView.fullScreenImageView.scrollView.zoomScale = minScale; //set the zoomScale at start to the minimum (what fits on screen)
        
        [annotationView.fullScreenImageView centerScrollViewContents]; //centers the contents inside the screen
        
        [annotationView addSubview:annotationView.fullScreenImageView]; //add the fullScreenImageView to the annotationView so all the above is useful
        
    } else {
        CGFloat scale = 1.0;
        if (width > 280.0f) {
            scale = 280.0f / width;
        }
        CGFloat scaledWidth = width * scale;
        CGFloat scaledHeight = height * scale;
        annotationView.frame = CGRectMake(0, 10, 320, scaledHeight + 20);
        
        SWPhotoImageView *imageView = [[SWPhotoImageView alloc] initWithFrame:CGRectMake((320-scaledWidth)/2, 0, scaledWidth, scaledHeight)];
        imageView.clipsToBounds = FALSE;
        imageView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView setImageWithURL:[NSURL URLWithString:photoURLString]];
        [imageView setBorderWidth:3.0];
        [annotationView addSubview:imageView];
    }
    
    return annotationView;
}

+ (SWAnnotationView *)annotationViewWithGeoData:(Annotation *)annotation fullscreen:(BOOL)fullscreen
{
    SWAnnotationView *annotationView = [SWAnnotationView new];
    annotationView.autoresizesSubviews = YES;
    annotationView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    annotationView.annotation = annotation;
    annotationView.backgroundColor = [UIColor clearColor];
    annotationView.clipsToBounds = TRUE;
    annotationView.type = SWAnnotationTypeGeolocation;
    annotationView.frame = CGRectMake(0, 10, 320, 240);
    
    CGFloat latitude = [annotation.latitude floatValue];
    CGFloat longitude = [annotation.longitude floatValue];
    

    MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(20, 0, annotationView.frame.size.width - 40, annotationView.frame.size.height - 20)];
    mapView.userInteractionEnabled = FALSE;
    mapView.delegate = annotationView;

    [annotationView addSubview:mapView];
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = latitude;
    zoomLocation.longitude = longitude;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 25000, 25000);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustedRegion animated:TRUE];
    
    SWMapAnnotation *annotationToAdd = [[SWMapAnnotation alloc] initWithCoordinate:zoomLocation];
    [mapView addAnnotation:annotationToAdd];
    
    mapView.layer.borderColor = [UIColor colorWithRed:0.992 green:0.886 blue:0.616 alpha:1].CGColor;
    mapView.layer.borderWidth = 4.0;
    
    UIView *shadowView = [[UIView alloc] initWithFrame:mapView.frame];
    [mapView.superview insertSubview:shadowView belowSubview:mapView];
    
    CALayer *shadowLayer = shadowView.layer;
    shadowLayer.backgroundColor = [UIColor whiteColor].CGColor;
    
    shadowLayer.shadowColor = [UIColor colorWithWhite:0.3 alpha:1.0].CGColor;
    shadowLayer.shadowOpacity = 0.8f;
    shadowLayer.shadowOffset = CGSizeMake(0, 0.5);
    shadowLayer.shadowRadius = 0.5;
    [shadowLayer setShadowPath:[[UIBezierPath bezierPathWithRect:mapView.bounds] CGPath]];
    
    if (fullscreen) {
        annotationView.frame = CGRectMake(0, 0, 320, 416);
        mapView.frame = annotationView.frame;
        mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        mapView.userInteractionEnabled = TRUE;
    }
    
    return annotationView;    

}

+ (NSURL *)youtubeURLWithinString:(NSString *)string
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(www.youtube.com\\/watch\\?v=\\w+)" options:0 error:NULL];
    NSTextCheckingResult *match = [regex firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
    if (!match || match == (id)[NSNull null]) return nil;
    
    NSRange matchRange = [match rangeAtIndex:0];
    return [NSURL URLWithString:[@"http://" stringByAppendingString:[string substringWithRange:matchRange]]];
}

+ (SWAnnotationView *)annotationViewWithYoutubeURL:(NSURL *)videoURL fullscreen:(BOOL)fullscreen
{
    SWAnnotationView *annotationView = [SWAnnotationView new];
    annotationView.backgroundColor = [UIColor clearColor];
    annotationView.clipsToBounds = TRUE;
    annotationView.type = SWAnnotationTypeYoutube;
    annotationView.frame = CGRectMake(0, 0, 320, 220);

    KLog(@"Youtube WITH URL: %@",videoURL);

    
    LBYouTubePlayerViewController *youtubeController = [[LBYouTubePlayerViewController alloc] initWithYouTubeURL:videoURL];
    //self.controller.delegate = self;
    youtubeController.quality = LBYouTubePlayerQualityMedium;
    youtubeController.view.frame = CGRectMake(10.0, 10.0, 280.0, 200.0);
    youtubeController.delegate = annotationView;
    youtubeController.view.center = annotationView.center;

    [annotationView addSubview:youtubeController.view];

    return annotationView;
}


- (void)youTubePlayerViewController:(LBYouTubePlayerViewController *)controller didSuccessfullyExtractYouTubeURL:(NSURL *)videoURL {
    KLog(@"Did extract video source:%@", videoURL);
}

- (void)youTubePlayerViewController:(LBYouTubePlayerViewController *)controller failedExtractingYouTubeURLWithError:(NSError *)error {
    KLog(@"Failed to load video due to error:%@", error);
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
