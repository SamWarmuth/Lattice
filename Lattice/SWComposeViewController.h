//
//  SWComposeViewController.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/12/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "V8HorizontalPickerView.h"
@interface SWComposeViewController : UIViewController <UITextViewDelegate, V8HorizontalPickerViewDataSource, V8HorizontalPickerViewDelegate>

@property (nonatomic, strong) IBOutlet UITextView *messageTextView;
@property (nonatomic, strong) IBOutlet UIView *progressContainerView, *progressView, *keyboardAccessoryView, *autocompletePlaceholderView;
@property (nonatomic, strong) NSMutableArray *autocompleteStrings, *matchingAutocompleteStrings;
@property (nonatomic, strong) V8HorizontalPickerView *autocompletePicker;
@property (nonatomic, strong) NSString *replyToID, *prefillText;


- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;

- (IBAction)mentionButtonTapped:(id)sender;
- (IBAction)hashtagButtonTapped:(id)sender;


@end
