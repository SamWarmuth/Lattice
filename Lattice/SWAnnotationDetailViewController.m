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
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    SWAnnotationView *annotationView = [SWAnnotationView annotationViewFromAnnotationDictionary:self.annotation fullscreen:TRUE];
    annotationView.frame = self.annotationView.frame;
    [self.view addSubview: annotationView];
    [self.annotationView removeFromSuperview];
    self.annotationView = annotationView;
    KLog(@"subviews : %@", self.view.subviews);


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
