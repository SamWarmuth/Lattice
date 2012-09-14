//
//  SWComposeViewController.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/12/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWComposeViewController.h"

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
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.messageTextView becomeFirstResponder];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (newString.length >= 255) return NO;
    
    CGRect frame = self.progressView.frame;
    self.progressView.frame = CGRectMake(frame.origin.x, frame.origin.y, ((float)newString.length/255.0)*self.progressContainerView.frame.size.width, frame.size.height);
    return YES;
}

- (IBAction)cancelButtonPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:TRUE];
}

- (IBAction)doneButtonPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:TRUE];
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
