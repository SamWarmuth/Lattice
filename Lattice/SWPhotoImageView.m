//
//  SWPhotoImageView.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/20/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWPhotoImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SWPhotoImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepareUI];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self prepareUI];
}

- (void)prepareUI
{
    CALayer *frameLayer = [CALayer layer];
    frameLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    frameLayer.borderColor = [[UIColor whiteColor] CGColor];
    frameLayer.borderWidth = (self._borderWidth ? (float)self._borderWidth : ceilf(self.frame.size.height / 80));
    
    [self.layer insertSublayer:frameLayer atIndex:0];
    
    
    if (self.shadowView) [self.shadowView removeFromSuperview];
    self.shadowView = [[UIView alloc] initWithFrame:self.frame];
    [self.superview insertSubview:self.shadowView belowSubview:self];
    
    CALayer *shadowLayer = self.shadowView.layer;
    shadowLayer.backgroundColor = [UIColor whiteColor].CGColor;
    
    shadowLayer.shadowColor = [UIColor colorWithWhite:0.1 alpha:1.0].CGColor;
    shadowLayer.shadowOpacity = 0.9f;
    shadowLayer.shadowOffset = CGSizeMake(0, 0.5);
    shadowLayer.shadowRadius = 0.5;
    [shadowLayer setShadowPath:[[UIBezierPath bezierPathWithRect:self.bounds] CGPath]];
    
    
}

- (void)setBorderWidth:(NSInteger)width
{
    self._borderWidth = width;
    [self prepareUI];
}



@end
