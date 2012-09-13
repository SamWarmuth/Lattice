//
//  SWUserCell.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/12/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWUserCell.h"
#import <QuartzCore/QuartzCore.h>
#import "AFNetworking.h"
#import "NSAttributedString+Attributes.h"

@implementation SWUserCell

+ (CGFloat)messageHeightForUser:(NSDictionary *)user
{
    NSString *text = [[user objectForKey:@"description"] objectForKey:@"text"];
    
    NSMutableAttributedString *messageString = [NSMutableAttributedString attributedStringWithString:text];
    
    CGSize constraint = CGSizeMake(172.0, 20000.0f);
    CGSize size = [messageString sizeConstrainedToSize:constraint];
    return size.height + 5.0;
    
}

+ (CGFloat)heightForUser:(NSDictionary *)user
{
    CGFloat height = MAX([self messageHeightForUser:user] + 72.0, 141.0);
    return height;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)prepareUIWithUser:(NSDictionary *)user
{
    self.avatarImageView.layer.cornerRadius = 4.0;
    self.contentView.backgroundColor = [UIColor whiteColor];

    if (!user) return;
    
    CGRect oldFrame = self.messageLabel.frame;
    self.messageLabel.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, [[self class] messageHeightForUser:user]);
    
    self.messageLabel.text = [[user objectForKey:@"description"] objectForKey:@"text"];
        
    NSDictionary *avatarInfo = [user objectForKey:@"avatar_image"];
    
    self.usernameLabel.text = [user objectForKey:@"username"];
    
    NSURL *avatarURL = [NSURL URLWithString:[avatarInfo objectForKey:@"url"]];    
    [self.avatarImageView setImageWithURL:avatarURL];    
}

- (void)handleLinkTappedWithBlock:(void (^)(NSTextCheckingResult *linkInfo))block
{
    self.URLCallbackBlock = block;
}

-(BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo
{
    if (self.URLCallbackBlock) self.URLCallbackBlock(linkInfo);
    return NO;
}

@end
