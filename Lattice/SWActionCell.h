//
//  SWActionCell.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/12/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Post.h"

@interface SWActionCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIButton *replyButton, *repostButton, *starButton, *postsButton, *starredButton, *followingButton, *followersButton;

- (void)prepareUIWithUser:(User *)user;
- (void)prepareUIWithPost:(Post *)post;

@end
