//
//  SWFullScreenImageView.m
//  Lattice
//
//  Created by Kent McCullough on 10/17/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWFullScreenImageView.h"
#import "AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

@implementation SWFullScreenImageView

- (id)initWithFrame:(CGRect)frame //initalize (create) a new SWFullScreenImageView with a Frame
{
    self = [super initWithFrame:frame]; //hmm? Why self = [super initWithFrame:frame]; instead of just [super initWithFrame:frame]; ? self doesn't exist somehow, or we need it to be the same as it's superView ?
    if (self) { //if self exists, which is will since we set it the line before.... unless that's a type of if in and of itself to make sure it's super has a frame?
        [self prepareUI]; //when it's created send it to prepareUI
    }
    return self; //return itself, yay!
}

- (void)awakeFromNib //not sure what this is, but you had it in SWPhotoImageView....
{
    [super awakeFromNib]; //let the supers do their thing
    [self prepareUI]; //send to prepareUI
}


- (void)prepareUI //setup the View as needed
{
    self.scrollView = [UIScrollView new]; //make self.scrollView exist and point to something real
    self.scrollView.frame = self.frame; //set the frame of the scrollView to the frame of the SWFullScreenImageView (which is set to the annotationView)
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.imageView = [UIImageView new]; //make self.imageView exist and point to something real
    [self.scrollView addSubview:self.imageView]; //add the imageView to the scrollView
    self.scrollView.delegate = self; //set the SWFullScreenImageView to be the delegate
    [self addSubview:self.scrollView]; //add the scrollView to the SWFullScreenImageView
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)]; //create the UITapGestureRecognizer doubleTapRecognizer
    doubleTapRecognizer.numberOfTapsRequired = 2; //make it take two taps
    doubleTapRecognizer.numberOfTouchesRequired = 1; //can only use 1 finger (2 taps with 1 finger)
                                                     //(default is already 1, but I'm setting it anyway)
    [self.scrollView addGestureRecognizer:doubleTapRecognizer]; //add the UITapGestureRecognizer to the scrollView
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)]; //create the UITapGestureRecognizer
    twoFingerTapRecognizer.numberOfTapsRequired = 1; //make it take 1 tap
    twoFingerTapRecognizer.numberOfTouchesRequired = 2; // can only use 2 fingers (1 tap with 2 fingers)
    [self.scrollView addGestureRecognizer:twoFingerTapRecognizer]; //add the UITapGestureRecognizer to the scrollView
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView; //set the imageView as the view that gets zoomed inside the scrollView (even though it's the only view.... grumble)
}

- (void)centerScrollViewContents //center what's in the scrollView (the imageView)
{
    CGSize boundsSize = self.scrollView.bounds.size; //the size of the scrollView's bounds (bounds is the location & size of a view, I think that means it's like the frame?) scrollView's bounds should been screen size in this case.
    CGRect contentsFrame = self.imageView.frame; //the frame of the contents
    
    if (contentsFrame.size.width < boundsSize.width) { //if the width of the contents is less than the width of the screen
                                                       //these if's smell weird
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f; //contents will center on the x axis
                                                                                       //origin.x is the offset pixels from left, (screen width - contents width)
    } else { //if the width of the imageView is greater than or equal to the width of the screen
        contentsFrame.origin.x = 0.0f; //contents get left aligned, since they fit, and a negative number would put it off screen to the left
    }
    
    if (contentsFrame.size.height < boundsSize.height) { //if the height of the imageView is less than the height of the screen
                                                         //these if's still smell weird.
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f; //contents to be centered on the y axis
                                                                                         //origin.y is offset[64] pixels from top (screen height[416] - contents height[288])
    } else { //if the height of the imageView is greater than or equal to the height of the screen
        contentsFrame.origin.y = 0.0f; //contents get aligned with the top of the screen, since it fits, and a negative number would put it off screen above
    }
    
    self.imageView.frame = contentsFrame; //set the imageView's frame to be the new contentsFrame
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer *)recognizer //2 taps with 1 finger UITapGestureRecognizer
{
    CGPoint pointInView = [recognizer locationInView:self.imageView]; //where you tapped. (not sure if it takes the first or second tap or the average..., handeled by IOS goodness)
    CGFloat newZoomScale = self.scrollView.zoomScale * 1.5f; //a zoom amount of 1.5x what it previously was.
    newZoomScale = MIN(newZoomScale, self.scrollView.maximumZoomScale); //set zoomScale to be either (previous zoom * 1.5) or the maximumZoom, whatever is smaller
    CGSize scrollViewSize = self.scrollView.bounds.size; //size of the scrollView based off bounds
    CGFloat w = scrollViewSize.width / newZoomScale; //width of new contents (the old width / zoomScale) [zoomScale is < 1 when image is larger than original size]
    CGFloat h = scrollViewSize.height / newZoomScale; //height of new contents (old height / zoomScale) [zoomScale is < 1 when image is larger than original size]
    CGFloat x = pointInView.x - (w / 2.0f); //x axis offset (where you tapped - (new contents width / 2))
    CGFloat y = pointInView.y - (h / 2.0f); //y axis offset (where you tapped - (new contents height / 2))
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h); //the rectangle with (x offset, y offset, new width, new height)
    
    [self.scrollView zoomToRect:rectToZoomTo animated:TRUE]; //zoom the scrollview to the new rectangle
                                                             //animate it because it looks retarded if not.
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer *)recognizer //1 tap with 2 fingers UITapGestureRecognizer
{
    CGFloat newZoomScale = self.scrollView.zoomScale / 1.5f; //set the new zoomScale to be the old zoomScale / 1.5
    newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale); //set new zoomScale to be either (old zoomScale / 1.5) or the minimumZoom, whichever is bigger
    [self.scrollView setZoomScale:newZoomScale animated:TRUE]; //set the scrollView's zoomScale. This will fire scrollViewDidZoom.
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView //whenever the scrollView zooms
{
    [self centerScrollViewContents]; //center the contents.
}

@end
