//
//  SWComposeViewController.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/12/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWComposeViewController.h"
#import "SWPostAPI.h"
#import "SVProgressHUD.h"

@interface SWComposeViewController ()

@end

@implementation SWComposeViewController

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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.autocompleteStrings = [[defaults objectForKey:@"SWMyFollowerUsernames"] mutableCopy];
    if (!self.autocompleteStrings) self.autocompleteStrings = [NSMutableArray new];
    NSMutableArray *following = [defaults objectForKey:@"SWMyFollowingUsernames"];
    for (NSString *username in following){
        if (![self.autocompleteStrings containsObject:username]) [self.autocompleteStrings addObject:username];
    }
    [self.autocompleteStrings  sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    [super viewDidLoad];
    //self.autocompleteStrings = [@[@"@marco", @"@siracusa", @"@samwarmuth", @"@dalton", @"@billkunz"] mutableCopy];
    self.matchingAutocompleteStrings = [NSMutableArray new];

	[self.keyboardAccessoryView removeFromSuperview];
    self.messageTextView.inputAccessoryView = self.keyboardAccessoryView;
    
    self.autocompletePicker = [[V8HorizontalPickerView alloc] initWithFrame:self.autocompletePlaceholderView.frame];
	self.autocompletePicker.backgroundColor   = [UIColor colorWithRed:0.941 green:0.941 blue:0.941 alpha:1];
	self.autocompletePicker.selectedTextColor = [UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:1];
	self.autocompletePicker.textColor   = [UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:1];
	self.autocompletePicker.delegate    = self;
	self.autocompletePicker.dataSource  = self;
	self.autocompletePicker.elementFont = [UIFont boldSystemFontOfSize:14.0f];
	self.autocompletePicker.selectionPoint = CGPointMake(160, 0);
    
    [self.view addSubview:self.autocompletePicker];
    
    self.autocompletePicker.hidden = TRUE;
    [self.autocompletePlaceholderView removeFromSuperview];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.autocompletePicker reloadData];
}


- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker
{
    if (self.matchingAutocompleteStrings.count == 0) return 1;
    return self.matchingAutocompleteStrings.count;
}

- (NSInteger)horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index
{
    if (self.matchingAutocompleteStrings.count == 0) return 140;
    
    CGSize nameSize = [[self.matchingAutocompleteStrings objectAtIndex:index] sizeWithFont:[UIFont boldSystemFontOfSize:14]];
    return (int)(nameSize.width + 20.0);
}


- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index
{
    if (self.matchingAutocompleteStrings.count == 0) {
        self.autocompletePicker.textColor = [UIColor colorWithRed:0.624 green:0.624 blue:0.624 alpha:1];
        return @"No matches found.";
    }
    self.autocompletePicker.textColor = [UIColor blackColor];

    return [self.matchingAutocompleteStrings objectAtIndex:index];
}
- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index
{
    if (index >= self.matchingAutocompleteStrings.count) return;
    
    NSMutableString *text = [self.messageTextView.text mutableCopy];
    NSRange selectedRange = [self autocompleteMatchRangeForText:text];
    NSString *replacementText = [[self.matchingAutocompleteStrings objectAtIndex:index] stringByAppendingString:@" "];
    
    if ([self textView:self.messageTextView shouldChangeTextInRange:selectedRange replacementText:replacementText]){
        [text replaceCharactersInRange:selectedRange withString:replacementText];
        self.messageTextView.text = text;
    }
        
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.messageTextView becomeFirstResponder];
    if (self.prefillText) self.messageTextView.text = self.prefillText;
}


- (IBAction)mentionButtonTapped:(id)sender
{
    NSMutableString *text = [self.messageTextView.text mutableCopy];
    NSRange selectedRange = self.messageTextView.selectedRange;
    NSString *replacementText = @"@";
    
    if ([self textView:self.messageTextView shouldChangeTextInRange:selectedRange replacementText:replacementText]){
        [text replaceCharactersInRange:selectedRange withString:replacementText];
        self.messageTextView.text = text;
    }
}

- (IBAction)hashtagButtonTapped:(id)sender
{
    NSMutableString *text = [self.messageTextView.text mutableCopy];
    NSRange selectedRange = self.messageTextView.selectedRange;
    NSString *replacementText = @"#";
    
    if ([self textView:self.messageTextView shouldChangeTextInRange:selectedRange replacementText:replacementText]){
        [text replaceCharactersInRange:selectedRange withString:replacementText];
        self.messageTextView.text = text;
    }    
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (newString.length >= 255) return NO;
    
    CGRect frame = self.progressView.frame;
    self.progressView.frame = CGRectMake(frame.origin.x, frame.origin.y, ((float)newString.length/254.0)*self.progressContainerView.frame.size.width, frame.size.height);
    
    if (newString.length == 254) self.progressView.backgroundColor = [UIColor blackColor];
    else self.progressView.backgroundColor = [UIColor colorWithRed:0.702 green:0.702 blue:0.702 alpha:1];
    
    [self checkForAutocomplete:newString];
    
    return YES;
}


- (void)checkForAutocomplete:(NSString *)text
{
    NSRange matchRange = [self autocompleteMatchRangeForText:text];
    if (matchRange.location == NSNotFound) {
        if (!self.autocompletePicker.hidden) self.autocompletePicker.hidden = TRUE;
        return;
    }    
    
    NSString *partial = [text substringWithRange:matchRange];
        
    self.matchingAutocompleteStrings = [NSMutableArray new];
    for (NSString *string in self.autocompleteStrings) {
        NSRange range = [string rangeOfString:partial];
        if (range.location != NSNotFound) {
            [self.matchingAutocompleteStrings addObject:string];
        }
    }

    [self.autocompletePicker reloadData];
    
    if (self.autocompletePicker.hidden) self.autocompletePicker.hidden = FALSE;
    
}

- (NSRange)autocompleteMatchRangeForText:(NSString *)text
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@\\w*$" options:0 error:NULL];
    NSTextCheckingResult *match = [regex firstMatchInString:text options:0 range:NSMakeRange(0, text.length)];
    if (!match || match == (id)[NSNull null]) return NSMakeRange(NSNotFound, NSNotFound);
    return [match rangeAtIndex:0];
}


- (IBAction)cancelButtonPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:TRUE];
}

- (IBAction)doneButtonPressed:(id)sender
{
    [SVProgressHUD show];
    if (self.messageTextView.text.length == 0){
        [SVProgressHUD dismissWithError:@"Posts can't be empty."];
        return;
    }
    
    [SWPostAPI createPostWithText:self.messageTextView.text replyTo:self.replyToID completed:^(NSError *error, Post *post, NSDictionary *metadata) {
        [SVProgressHUD dismissWithSuccess:@"Posted!"];
        DLog(@"Created Post! %@", post);
        [self dismissModalViewControllerAnimated:TRUE];
    }];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
