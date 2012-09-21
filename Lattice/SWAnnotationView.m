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

@implementation SWAnnotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (NSMutableArray *)autoAnnotationViewsFromPostDictionary:(NSDictionary *)postDict
{
    NSMutableArray *annotationViews = [NSMutableArray new];
    NSLog(@"Post? %@", postDict);
    NSURL *youtubeURL = [self youtubeURLWithinString:[postDict objectForKey:@"text"]];
    if (youtubeURL) {
        [annotationViews addObject:[self annotationViewWithYoutubeURL:youtubeURL]];
    }
    
    return annotationViews;
}

+ (SWAnnotationView *)annotationViewFromDictionary:(NSDictionary *)annotationData
{
    NSLog(@"Anndata: %@", annotationData);
    SWAnnotationType type = [self typeForAnnotationData:annotationData];
    switch (type) {
        case SWAnnotationTypePhoto:
            return [self annotationViewWithPhotoData:annotationData];
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
    }
    return SWAnnotationTypeUnknown;
}

+ (SWAnnotationView *)annotationViewWithPhotoData:(NSDictionary *)annotationData
{
    SWAnnotationView *annotationView = [SWAnnotationView new];
    annotationView.backgroundColor = [UIColor clearColor];
    annotationView.clipsToBounds = TRUE;
    annotationView.type = SWAnnotationTypePhoto;
    
    NSDictionary *valueDict = [annotationData objectForKey:@"value"];
    NSString *photoURLString = [valueDict objectForKey:@"file_url"];
    CGFloat width = [[valueDict objectForKey:@"width"] floatValue];
    CGFloat height = [[valueDict objectForKey:@"height"] floatValue];
    CGFloat scale = 1.0;
    
    if (width > 280.0f){
        scale = 280.0f / width;
    }
    
    CGFloat scaledWidth = width * scale;
    CGFloat scaledHeight = height * scale;
    
    NSLog(@"Scale: %f w:%f h:%f", scale, scaledWidth, scaledHeight);
    
    annotationView.frame = CGRectMake(0, 0, 320, scaledHeight + 40);

    
    SWPhotoImageView *imageView = [[SWPhotoImageView alloc] initWithFrame:CGRectMake((320-scaledWidth)/2, 20, scaledWidth, scaledHeight)];
    [annotationView addSubview:imageView];
    imageView.clipsToBounds = FALSE;
    NSLog(@"image view frame: %@", NSStringFromCGRect(imageView.frame));
    imageView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView setImageWithURL:[NSURL URLWithString:photoURLString]];
    [imageView setBorderWidth:3.0];
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

+ (SWAnnotationView *)annotationViewWithYoutubeURL:(NSURL *)videoURL
{
    SWAnnotationView *annotationView = [SWAnnotationView new];
    annotationView.backgroundColor = [UIColor clearColor];
    annotationView.clipsToBounds = TRUE;
    annotationView.type = SWAnnotationTypePhoto;
    annotationView.frame = CGRectMake(0, 0, 320, 320);

    NSLog(@"YOUTUEB WITH URL: %@",videoURL);
    
    LBYouTubePlayerViewController *youtubeController = [[LBYouTubePlayerViewController alloc] initWithYouTubeURL:videoURL];
    //self.controller.delegate = self;
    youtubeController.quality = LBYouTubePlayerQualityLarge;
    youtubeController.view.frame = CGRectMake(20.0, 20.0, 280.0, 200.0);
    youtubeController.delegate = annotationView;
    youtubeController.view.center = annotationView.center;


    [annotationView addSubview:youtubeController.view];
    return annotationView;
}


- (void)youTubePlayerViewController:(LBYouTubePlayerViewController *)controller didSuccessfullyExtractYouTubeURL:(NSURL *)videoURL {
    NSLog(@"Did extract video source:%@", videoURL);
}

- (void)youTubePlayerViewController:(LBYouTubePlayerViewController *)controller failedExtractingYouTubeURLWithError:(NSError *)error {
    NSLog(@"Failed to load video due to error:%@", error);
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
