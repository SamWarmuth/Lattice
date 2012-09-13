//
//  SWPostCell.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/11/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWPostCell.h"
#import <QuartzCore/QuartzCore.h>
#import "AFNetworking.h"
#import "SWWebViewController.h"
#import "SWHelpers.h"
#import "NSAttributedString+Attributes.h"

@implementation SWPostCell

+ (CGFloat)messageHeightForPost:(NSDictionary *)post
{
    NSString *text = [post objectForKey:@"text"];
    
    NSMutableAttributedString *messageString = [NSMutableAttributedString attributedStringWithString:text];
    [messageString setFont:[UIFont systemFontOfSize:13]];
    CGSize constraint = CGSizeMake(225.0, 20000.0f);
    CGSize size = [messageString sizeConstrainedToSize:constraint];
    return size.height;
}

+ (CGFloat)heightForPost:(NSDictionary *)post
{
    CGFloat height = MAX([self messageHeightForPost:post] + 55.0, 88.0);
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

- (void)prepareUIWithPost:(NSDictionary *)post
{
    self.avatarImageView.layer.cornerRadius = 4.0;
    self.contentView.backgroundColor = [UIColor whiteColor];
    if (!post) return;
        
    CGRect oldFrame = self.messageLabel.frame;
    self.messageLabel.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, [SWPostCell messageHeightForPost:post]);
    //self.messageLabel.backgroundColor = [UIColor greenColor];
    
    
    self.messageLabel.text = [post objectForKey:@"text"];
    
    NSLog(@"POST! %@", post);
    
    
    [self.messageLabel setAutomaticallyAddLinksForType:0];
    
    NSDictionary *entities = [post objectForKey:@"entities"];
    NSArray *hashtags = [entities objectForKey:@"hashtags"];
    NSArray *links = [entities objectForKey:@"links"];
    NSArray *mentions = [entities objectForKey:@"mentions"];
    
    NSInteger messageLength = self.messageLabel.text.length;

    
    for (NSDictionary *link in hashtags){
        NSInteger position = [[link objectForKey:@"pos"] integerValue];
        NSInteger length = [[link objectForKey:@"len"] integerValue];
        if (position >= messageLength) continue;
        if (position + length > messageLength) length = messageLength - position;
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"#%@", [link objectForKey:@"name"]]];
        [self.messageLabel addCustomLink:url inRange:NSMakeRange(position, length)];
    }
    
    for (NSDictionary *link in links) {
        NSInteger position = [[link objectForKey:@"pos"] integerValue];
        NSInteger length = [[link objectForKey:@"len"] integerValue];
        if (position >= messageLength) continue;
        if (position + length > messageLength) length = messageLength - position;
        NSLog(@"Add link.");
        NSURL *url = [NSURL URLWithString:[link objectForKey:@"url"]];
        [self.messageLabel addCustomLink:url inRange:NSMakeRange(position, length)];
    }
    for (NSDictionary *link in mentions) {
        NSInteger position = [[link objectForKey:@"pos"] integerValue];
        NSInteger length = [[link objectForKey:@"len"] integerValue];
        if (position >= messageLength) continue;
        if (position + length > messageLength) length = messageLength - position;
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"@%@", [link objectForKey:@"name"]]];
        [self.messageLabel addCustomLink:url inRange:NSMakeRange(position, length)];
    }

        
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];    
    [dateFormatter setDateFormat:@"MMM d h:mma"];
    self.dateLabel.text = [dateFormatter stringFromDate:[SWHelpers dateFromRailsDateString:[post objectForKey:@"created_at"]]];
    
    NSDictionary *user = [post objectForKey:@"user"];
    NSDictionary *avatarInfo = [user objectForKey:@"avatar_image"];
    self.usernameLabel.text = [user objectForKey:@"username"];

    NSURL *avatarURL = [NSURL URLWithString:[avatarInfo objectForKey:@"url"]];
    
    [self.avatarImageView setImageWithURL:avatarURL];
    if ([post objectForKey:@"you_starred"] && [[post objectForKey:@"you_starred"] intValue] == 1){
        self.contentView.backgroundColor = [UIColor colorWithRed:1.000 green:0.957 blue:0.580 alpha:1];
    }
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
