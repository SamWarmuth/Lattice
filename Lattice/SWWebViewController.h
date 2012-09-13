//
//  SWWebViewController.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/12/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWWebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webview;
@property (nonatomic, strong) NSURL *initialURL;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *backButton, *forwardButton, *shareButton;

@end
