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

@implementation SWAnnotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (NSMutableArray *)annotationViewsFromPostDictionary:(NSDictionary *)postDict includeAuto:(BOOL)includeAuto fullscreen:(BOOL)fullscreen
{
    NSMutableArray *annotationViews = [NSMutableArray new];
    if (includeAuto) {
        NSLog(@"AUTO IS BROKEN.");
        NSURL *youtubeURL = [self youtubeURLWithinString:[postDict objectForKey:@"text"]];
        if (youtubeURL) {
            [annotationViews addObject:[self annotationViewWithYoutubeURL:youtubeURL fullscreen:fullscreen]];
        }
    }
    
    NSArray *annotations = [postDict objectForKey:@"annotations"];
    if (!annotations) return annotationViews;
            
    for (NSDictionary *annotationDict in annotations){
        SWAnnotationView *newAnnotationView = [SWAnnotationView annotationViewFromAnnotationDictionary:annotationDict fullscreen:fullscreen];
        if (newAnnotationView) [annotationViews addObject:newAnnotationView];
    }
    return annotationViews;
}

+ (SWAnnotationView *)annotationViewFromAnnotationDictionary:(NSDictionary *)annotationData fullscreen:(BOOL)fullscreen
{
    SWAnnotationType type = [self typeForAnnotationData:annotationData];
    switch (type) {
        case SWAnnotationTypePhoto:
            return [self annotationViewWithPhotoData:annotationData fullscreen:fullscreen];
        case SWAnnotationTypeGeolocation:
            return [self annotationViewWithGeoData:annotationData fullscreen:fullscreen];
        case SWAnnotationTypeUnknown:
            return nil;
        default:
            break;
    }
    
    return nil;
}

+ (SWAnnotationType)typeForAnnotationData:(NSDictionary *)annotationData
{
    NSString *typeString = [annotationData objectForKey:@"type"];
    if ([typeString isEqualToString:@"net.app.core.oembed"]) {
        NSString *subTypeString = [[annotationData objectForKey:@"value"] objectForKey:@"type"];
        
        if ([subTypeString isEqualToString:@"photo"]) return SWAnnotationTypePhoto;
        
    } else if ([typeString isEqualToString:@"net.app.core.geolocation"]) {
        return SWAnnotationTypeGeolocation;
    }
    
    return SWAnnotationTypeUnknown;
}

+ (SWAnnotationView *)annotationViewWithPhotoData:(NSDictionary *)annotationData fullscreen:(BOOL)fullscreen
{
    SWAnnotationView *annotationView = [SWAnnotationView new];
    annotationView.annotation = annotationData;
    annotationView.backgroundColor = [UIColor clearColor];
    annotationView.clipsToBounds = TRUE;
    annotationView.type = SWAnnotationTypePhoto;
    
    NSDictionary *valueDict = [annotationData objectForKey:@"value"];
    NSString *photoURLString = [valueDict objectForKey:@"file_url"];
    CGFloat width = [[valueDict objectForKey:@"width"] floatValue];
    CGFloat height = [[valueDict objectForKey:@"height"] floatValue];
    

    if (fullscreen) {
        UIScrollView *scrollView = [UIScrollView new];
        [annotationView addSubview:scrollView];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        KLog(@"%f, %f", width, height);
        [imageView setImageWithURL:[NSURL URLWithString:photoURLString]];
        [scrollView addSubview:imageView];
        
        scrollView.contentSize = CGSizeMake(width, height);
        CGRect scrollViewFrame = scrollView.frame;
        CGFloat scaledWidth = scrollViewFrame.size.width / scrollView.contentSize.width;
        CGFloat scaledHeight = scrollViewFrame.size.height / scrollView.contentSize.height;
        CGFloat minScale = MIN(scaledWidth, scaledHeight);
        scrollView.minimumZoomScale = minScale;
        scrollView.maximumZoomScale = 2.0f;
        scrollView.zoomScale = minScale;
        
        
    } else {
        CGFloat scale = 1.0;
        if (width > 280.0f){
            scale = 280.0f / width;
        }
        CGFloat scaledWidth = width * scale;
        CGFloat scaledHeight = height * scale;
        annotationView.frame = CGRectMake(0, 0, 320, scaledHeight + 20);
        
        SWPhotoImageView *imageView = [[SWPhotoImageView alloc] initWithFrame:CGRectMake((320-scaledWidth)/2, 0, scaledWidth, scaledHeight)];
        imageView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView setImageWithURL:[NSURL URLWithString:photoURLString]];
        [imageView setBorderWidth:3.0];
        [annotationView addSubview:imageView];
    }
    return annotationView;
}

+ (SWAnnotationView *)annotationViewWithGeoData:(NSDictionary *)annotationData fullscreen:(BOOL)fullscreen
{
    SWAnnotationView *annotationView = [SWAnnotationView new];
    annotationView.autoresizesSubviews = YES;
    annotationView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    annotationView.annotation = annotationData;
    annotationView.backgroundColor = [UIColor clearColor];
    annotationView.clipsToBounds = TRUE;
    annotationView.type = SWAnnotationTypeGeolocation;
    annotationView.frame = CGRectMake(0, 0, 320, 240);

    
    NSDictionary *valueDict = [annotationData objectForKey:@"value"];
    CGFloat latitude = [[valueDict objectForKey:@"latitude"] floatValue];
    CGFloat longitude = [[valueDict objectForKey:@"longitude"] floatValue];
    

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
    annotationView.type = SWAnnotationTypePhoto;
    annotationView.frame = CGRectMake(0, 0, 320, 220);

    KLog(@"YOUTUBE WITH URL: %@", videoURL);
    
    LBYouTubePlayerViewController *youtubeController = [[LBYouTubePlayerViewController alloc] initWithYouTubeURL:videoURL];
    //self.controller.delegate = self;
    youtubeController.quality = LBYouTubePlayerQualityLarge;
    youtubeController.view.frame = CGRectMake(20.0, 0, 280.0, 200.0);
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
