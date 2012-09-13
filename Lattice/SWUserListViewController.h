//
//  SWUserListViewController.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/13/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ODRefreshControl.h"


@interface SWUserListViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tv;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSString *userID, *minID, *maxID;
@property (nonatomic, strong) ODRefreshControl *refreshControl;

@property BOOL moreUsersAvailable, loadingUsers, viewUserFollowers, viewUserFollowing;

@end
