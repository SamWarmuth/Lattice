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
    
    CGFloat scaledWidth = width*scale;
    CGFloat scaledHeight = height*scale;
    
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




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
