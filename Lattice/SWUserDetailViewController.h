//
//  SWUserDetailViewController.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/12/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface SWUserDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tv;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *followButton;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSString *userID;
@property BOOL loadingUser;

- (IBAction)followButtonPressed:(id)sender;

- (void)viewPosts;
- (void)viewStarred;
- (void)viewFollowing;
- (void)viewFollowers;

@end
