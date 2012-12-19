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
#import <MessageUI/MessageUI.h>

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

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

-(Annotation *)annotation
{
    return self.annotationView.annotation;
}

- (void)setAnnotation:(Annotation *)annotation
{
    self.annotationView = [SWAnnotationView annotationViewFromAnnotation:annotation fullscreen:TRUE];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.annotationView) return;
    
    self.annotationView.frame = self.view.frame;
    [self.view addSubview:self.annotationView];
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
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save to Camera Roll", @"Send in Email", nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleAutomatic;
    popupQuery.tag = SWAnnotationTypePhoto;
    [popupQuery showInView:self.view];
}

- (void)geolocationActionSheet:(id)sender
{
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in Maps", nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleAutomatic;
    popupQuery.tag = SWAnnotationTypeGeolocation;
    [popupQuery showInView:self.view];
}

- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void *)contextInfo
{
    NSString *title;
    NSString *message;
    if (error) {
        title = @"Error";
        message = [error description];
    } else {
        title = @"Saved";
        message = @"The image has been saved to the camera roll.";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case SWAnnotationTypePhoto: {
            UIImage *annotationImage = self.annotationView.fullScreenImageView.imageView.image;
            switch (buttonIndex) {
                    
                case 0: {
                    KLog(@"Save to Camera Roll");
                    UIImageWriteToSavedPhotosAlbum(annotationImage, self, @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), nil);
                    break;
                }
                    
                case 1: {
                    KLog(@"Email");
                    MFMailComposeViewController *composer = [MFMailComposeViewController new];
                    if ([MFMailComposeViewController canSendMail]) {
                        [composer setMailComposeDelegate:self];
                        NSData *data = UIImageJPEGRepresentation(annotationImage, 1);
                        [composer addAttachmentData:data mimeType:@"image/jpeg" fileName:@"Picture.jpg"];
                        [composer setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
                        
                        [self presentViewController:composer animated:TRUE completion:nil];
                        
                    } else {
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unavailable" message:@"Your device is not set up for email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alert show];
                    }
                    
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
                    
                    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
                        NSString* addr = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@,%@", self.annotation.latitude,self.annotation.longitude];
                        NSURL* url = [[NSURL alloc] initWithString:[addr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                        [[UIApplication sharedApplication] openURL:url];
                    } else {
                        NSString* addr = [NSString stringWithFormat:@"http://maps.apple.com/maps?q=%@,%@", self.annotation.latitude,self.annotation.longitude];
                        NSURL* url = [[NSURL alloc] initWithString:[addr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                        [[UIApplication sharedApplication] openURL:url];                        
                    }
                    
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
