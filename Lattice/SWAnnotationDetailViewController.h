//
//  SWAnnotationDetailViewController.h
//  Lattice
//
//  Created by Kent McCullough on 9/24/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWAnnotationView.h"

@interface SWAnnotationDetailViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) IBOutlet SWAnnotationView *annotationView;

- (void)setAnnotation:(Annotation *)annotation;
- (IBAction)activityButtonTapped:(id)sender;

@end
