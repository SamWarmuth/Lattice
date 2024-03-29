//
//  SWUserCell.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/12/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"
#import "User.h"

typedef void ((^SWURLCallbackBlock)(NSTextCheckingResult *linkInfo));

@interface SWUserCell : UITableViewCell <OHAttributedLabelDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet OHAttributedLabel *messageLabel;
@property (nonatomic, strong) IBOutlet UILabel *usernameLabel;
@property (nonatomic, strong) SWURLCallbackBlock URLCallbackBlock;

+ (CGFloat)shortCellHeightForUser:(User *)user;

+ (CGFloat)heightForUser:(User *)user;
- (void)prepareUIWithUser:(User *)user;

- (void)handleLinkTappedWithBlock:(void (^)(NSTextCheckingResult *linkInfo))block;

@end
