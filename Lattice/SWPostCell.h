//
//  SWPostCell.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/11/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"
#import "Post.h"

typedef void ((^SWURLCallbackBlock)(NSTextCheckingResult *linkInfo));


@interface SWPostCell : UITableViewCell <OHAttributedLabelDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView, *conversationMarkerImageView;
@property (nonatomic, strong) IBOutlet OHAttributedLabel *messageLabel;
@property (nonatomic, strong) IBOutlet UILabel *usernameLabel, *dateLabel, *repostLabel;

@property (nonatomic, strong) IBOutlet UIButton *profileButton;
@property (nonatomic, strong) SWURLCallbackBlock URLCallbackBlock;
@property BOOL suppressConversationMarker, marked;


+ (CGFloat)heightForPost:(Post *)post;
- (void)prepareUIWithPost:(Post *)post;

- (void)handleLinkTappedWithBlock:(void (^)(NSTextCheckingResult *linkInfo))block;


@end
