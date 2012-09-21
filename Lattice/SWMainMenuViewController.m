//
//  SWMainMenuViewController.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/11/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWMainMenuViewController.h"
#import "SWComposeViewController.h"
#import "SWFeedViewController.h"
#import "SWFeed.h"


@interface SWMainMenuViewController ()

@end

@implementation SWMainMenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewDidUnload
{
    [super viewDidUnload];

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //        composeViewController.feed = [SWFeed feedWithType:SWFeedTypeMyFeed keyID:nil];

    if (indexPath.row == 0){ // compose
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        SWComposeViewController *composeViewController = [storyboard instantiateViewControllerWithIdentifier:@"SWComposeViewController"];
        [self.navigationController presentModalViewController:composeViewController animated:TRUE];        
    } else if (indexPath.row == 1){ // Your Feed
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        SWFeedViewController *feedViewController = [storyboard instantiateViewControllerWithIdentifier:@"SWFeedViewController"];
        feedViewController.feed = [SWFeed feedWithType:SWFeedTypeMyFeed keyID:nil];
        [self.navigationController pushViewController:feedViewController animated:TRUE];
    } else if (indexPath.row == 2){ // Mentions (mentioning me)
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        SWFeedViewController *feedViewController = [storyboard instantiateViewControllerWithIdentifier:@"SWFeedViewController"];
        feedViewController.feed = [SWFeed feedWithType:SWFeedTypeUserMentions keyID:@"me"];
        [self.navigationController pushViewController:feedViewController animated:TRUE];
    } else if (indexPath.row == 3){ // Starred (posts i've starred)
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        SWFeedViewController *feedViewController = [storyboard instantiateViewControllerWithIdentifier:@"SWFeedViewController"];
        feedViewController.feed = [SWFeed feedWithType:SWFeedTypeUserStars keyID:@"me"];
        [self.navigationController pushViewController:feedViewController animated:TRUE];
    } else if (indexPath.row == 4){ // Global Feed
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        SWFeedViewController *feedViewController = [storyboard instantiateViewControllerWithIdentifier:@"SWFeedViewController"];
        feedViewController.feed = [SWFeed feedWithType:SWFeedTypeGlobal keyID:nil];
        [self.navigationController pushViewController:feedViewController animated:TRUE];
    } else if (indexPath.row == 5){ // Settings
        
    }
}

@end
