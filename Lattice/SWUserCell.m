//
//  SWUserCell.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/12/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "NSAttributedString+Attributes.h"
#import <QuartzCore/QuartzCore.h>
#import "AFNetworking.h"
#import "SWUserCell.h"
#import "SWHelpers.h"

@implementation SWUserCell

+ (CGFloat)shortCellMessageHeightForUser:(NSDictionary *)user
{
    NSString *text = [SWHelpers fixNewlinesInString:[[user objectForKey:@"description"] objectForKey:@"text"]];
    
    NSMutableAttributedString *messageString = [NSMutableAttributedString attributedStringWithString:text];
    [messageString setFont:[UIFont systemFontOfSize:13]];
    
    CGSize constraint = CGSizeMake(222.0, 20000.0f);
    CGSize size = [messageString sizeConstrainedToSize:constraint];
    return size.height;
    
}

+ (CGFloat)messageHeightForUser:(NSDictionary *)user
{
    NSString *text = [SWHelpers fixNewlinesInString:[[user objectForKey:@"description"] objectForKey:@"text"]];

    NSMutableAttributedString *messageString = [NSMutableAttributedString attributedStringWithString:text];
    [messageString setFont:[UIFont systemFontOfSize:13]];
    CGSize constraint = CGSizeMake(172.0, 20000.0f);
    CGSize size = [messageString sizeConstrainedToSize:constraint];
    return size.height;
    
}

+ (CGFloat)shortCellHeightForUser:(NSDictionary *)user
{
    CGFloat height = MAX([self shortCellMessageHeightForUser:user] + 61.0, 91.0);
    return height;
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
    
    //DLog(@"User! %@", user);

    self.usernameLabel.text = [user objectForKey:@"username"];
    
    NSString *text = [SWHelpers fixNewlinesInString:[[user objectForKey:@"description"] objectForKey:@"text"]];


    CGRect oldFrame = self.messageLabel.frame;
    self.messageLabel.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, [[self class] messageHeightForUser:user]);
    self.messageLabel.text = text;
        
    NSDictionary *avatarInfo = [user objectForKey:@"avatar_image"];
    
    
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
