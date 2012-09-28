//
//  SWAnnotationDetailViewController.m
//  Lattice
//
//  Created by Kent McCullough on 9/24/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWAnnotationDetailViewController.h"
#import "SWAnnotationCell.h"
#import "SWActionCell.h"
#import "SWAnnotationView.h"
#import "SWPhotoImageView.h"


@interface SWAnnotationDetailViewController ()

@end

@implementation SWAnnotationDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    KLog(@"annotationView.subviews : %@", self.annotationView.subviews);
    switch (self.annotationView.type)
    {
        case SWAnnotationTypePhoto: {
            
            self.scrollView.backgroundColor = [UIColor colorWithRed:0.957 green:0.957 blue:0.957 alpha:1];
            for (int i=0; i < self.annotationView.subviews.count; i++) {
                if ([[self.annotationView.subviews objectAtIndex:i] isKindOfClass:[SWPhotoImageView class]]) {
                    SWPhotoImageView *image = [self.annotationView.subviews objectAtIndex:i];
                    self.scrollView.contentSize = image.frame.size;

                    [self.scrollView addSubview:image];
                    break;
                }
            }
            //[self.scrollView addSubview:self.annotationView];
            
            UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
            doubleTapRecognizer.numberOfTapsRequired = 2;
            doubleTapRecognizer.numberOfTouchesRequired = 1;
            [self.scrollView addGestureRecognizer:doubleTapRecognizer];
            
            UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
            twoFingerTapRecognizer.numberOfTapsRequired = 1;
            twoFingerTapRecognizer.numberOfTouchesRequired = 2;
            [self.scrollView addGestureRecognizer:twoFingerTapRecognizer];
            break;
        }
            
        case SWAnnotationTypeGeolocation: {
            self.scrollView.userInteractionEnabled = FALSE;
            MKMapView *mapView = [MKMapView new];
            for (int i=0; i < self.annotationView.subviews.count; i++) {
                if ([[self.annotationView.subviews objectAtIndex:i] isKindOfClass:[MKMapView class]]) {
                    mapView = [self.annotationView.subviews objectAtIndex:i];
                    mapView.frame = CGRectMake(0, 0, 320, 416);
                    mapView.contentMode = UIViewContentModeCenter;
                    mapView.userInteractionEnabled = TRUE;
                    [self.view addSubview:mapView];
                    
                    break;
                }
            }
            break;
        }
            
        default: {
            /*
            self.annotationView.frame = CGRectMake(0, 0, 320, 416);
            [self.view addSubview:self.annotationView];
            self.scrollView.userInteractionEnabled = FALSE;
            
            for (int i = 0; i < self.annotationView.subviews.count; i++) {
                UIView *view = [self.annotationView.subviews objectAtIndex:i];
                view.frame = self.annotationView.frame;
                view.userInteractionEnabled = TRUE;
            }
            */
            break;
        }
    }
    KLog(@"scrollView.subviews : %@", self.scrollView.subviews);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 2.0f;
    self.scrollView.zoomScale = minScale;
    
    //[self centerScrollViewContents];
}

- (void)centerScrollViewContents
{
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.annotationView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.annotationView.frame = contentsFrame;
}


- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer
{
    CGPoint pointInView = [recognizer locationInView:self.scrollView];
    CGFloat newZoomScale = self.scrollView.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, 15.0f);
    
    CGSize scrollViewSize = self.scrollView.bounds.size;
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    [self.scrollView zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer
{
    CGFloat newZoomScale = self.scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
    [self.scrollView setZoomScale:newZoomScale animated:YES];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.annotationView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    // The scroll view has zoomed, so you need to re-center the contents
    [self centerScrollViewContents];
}

- (IBAction)activityButtonTapped:(id)sender
{
    switch (self.annotationView.type) {
        case SWAnnotationTypePhoto: {
            [self photoActionSheet:sender];
            break;
        }
            
        case SWAnnotationTypeGeolocation: {
            [self geolocationActionSheet:sender];
            break;
        }
            
        default:
            break;
    }
}

- (void)photoActionSheet:(id)sender
{
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save to Camera Roll", @"Email", nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleAutomatic;
    popupQuery.tag = SWAnnotationTypePhoto;
    [popupQuery showInView:self.view];
}

- (void)geolocationActionSheet:(id)sender
{
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in Maps", @"Email?", nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleAutomatic;
    popupQuery.tag = SWAnnotationTypeGeolocation;
    [popupQuery showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case SWAnnotationTypePhoto: {
            switch (buttonIndex) {
                    
                case 0: {
                    KLog(@"Save to Camera Roll");
                    break;
                }
                    
                case 1: {
                    KLog(@"Email");
                    break;
                }
                    
                default: {
                    KLog(@"default");
                    break;
                }
            }
            break;
        }
        
        case SWAnnotationTypeGeolocation: {
            switch (buttonIndex) {

                case 0: {
                    KLog(@"Open in Maps");
                    break;
                }
                    
                case 1: {
                    KLog(@"Email?");
                    break;
                }
                    
                default: {
                    KLog(@"default");
                    break;
                }
            }
            break;
        }
        default: {
            KLog(@"default");
            break;
        }
            
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
