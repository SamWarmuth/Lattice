//
//  SWPhotoImageView.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/20/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWPhotoImageView : UIImageView

@property (nonatomic, strong) UIView *shadowView;
@property NSInteger _borderWidth;

- (void)setBorderWidth:(NSInteger)width;


@end
