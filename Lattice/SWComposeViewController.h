//
//  SWComposeViewController.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/12/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWComposeViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) IBOutlet UITextView *messageTextView;
@property (nonatomic, strong) IBOutlet UIView *progressContainerView, *progressView;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;

@end
