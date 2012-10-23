//
//  SWFullScreenImageView.h
//  Lattice
//
//  Created by Kent McCullough on 10/17/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWFullScreenImageView : UIView <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

- (void)centerScrollViewContents;
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer *)recognizer;
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer *)recognizer;

@end
