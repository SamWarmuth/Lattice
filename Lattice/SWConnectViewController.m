//
//  SWConnectViewController.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/11/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWConnectViewController.h"

@interface SWConnectViewController ()

@end

@implementation SWConnectViewController

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userConnected) name:@"SWUserConnected" object:nil];

}

- (IBAction)connectPressed:(id)sender
{
    
    NSString *authURLString = @"https://alpha.app.net/oauth/authenticate?client_id=MtRRqKDKVU6vbgHdBhLURs4fehhBbtdg&response_type=token&redirect_uri=lattice://authenticate&scope=stream write_post follow messages";
    NSURL *authURL = [NSURL URLWithString:[authURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    [[UIApplication sharedApplication] openURL:authURL];
}

- (void)userConnected
{
    [self performSegueWithIdentifier:@"SWConnectToMenu" sender:self];
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
