//
//  SWWebViewController.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/12/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWWebViewController.h"

@interface SWWebViewController ()

@end

@implementation SWWebViewController

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
    [self.webview loadRequest:[NSURLRequest requestWithURL:self.initialURL]];
    self.backButton.enabled = FALSE;
    self.forwardButton.enabled = FALSE;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{ 
    self.backButton.enabled = (webView.canGoBack);
    self.forwardButton.enabled = (webView.canGoForward);
    self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
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
