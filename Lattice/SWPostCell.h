//
//  SWPostCell.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/11/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWPostCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel, *usernameLabel, *dateLabel;
@property (nonatomic, strong) IBOutlet UIButton *profileButton;

+ (CGFloat)heightForPost:(NSDictionary *)post;
- (void)prepareUIWithPost:(NSDictionary *)post;

@end
