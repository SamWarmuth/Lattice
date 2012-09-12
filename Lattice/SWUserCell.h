//
//  SWUserCell.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/12/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWUserCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel, *usernameLabel, *URLLabel;

+ (CGFloat)heightForUser:(NSDictionary *)user;
- (void)prepareUIWithUser:(NSDictionary *)user;

@end
