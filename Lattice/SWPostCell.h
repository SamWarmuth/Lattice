//
//  SWPostCell.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/11/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"

typedef void ((^SWURLCallbackBlock)(NSTextCheckingResult *linkInfo));


@interface SWPostCell : UITableViewCell <OHAttributedLabelDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet OHAttributedLabel *messageLabel;
@property (nonatomic, strong) IBOutlet UILabel *usernameLabel, *dateLabel;

@property (nonatomic, strong) IBOutlet UIButton *profileButton;
@property (nonatomic, strong) SWURLCallbackBlock URLCallbackBlock;

+ (CGFloat)heightForPost:(NSDictionary *)post;
- (void)prepareUIWithPost:(NSDictionary *)post;

- (void)handleLinkTappedWithBlock:(void (^)(NSTextCheckingResult *linkInfo))block;


@end
