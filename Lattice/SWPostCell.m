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
#import "RichText.h"
#import "User.h"
#import "Image.h"
#import "TextEntity.h"

@implementation SWPostCell

+ (CGFloat)messageHeightForPost:(Post *)post
{
    BOOL isRepost = !![post valueForKey:@"repost_of"];
    
    NSString *text;
    
    if (isRepost) text = post.repost_of.text.text;
    else text = post.text.text;


    NSMutableAttributedString *messageString = [NSMutableAttributedString attributedStringWithString:[SWHelpers removeEmojiFromString:[SWHelpers fixNewlinesInString:text]]];
    [messageString setFont:[UIFont systemFontOfSize:13]];
    CGSize constraint = CGSizeMake(225.0, 20000.0f);
    CGSize size = [messageString sizeConstrainedToSize:constraint];
    if (isRepost) return size.height + 19;
    return size.height;
}

+ (CGFloat)heightForPost:(Post *)post
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

- (void)prepareUIWithPost:(Post *)post
{
    BOOL isRepost = !![post valueForKey:@"repost_of"];
    self.repostLabel.hidden = !isRepost;
    Post *originalPost;
    if (isRepost) {
        originalPost = post;
        post = post.repost_of;
    }
    
    if (!post) return;
    
    //NSLog(@"Post? %@", post);

    CGFloat messageHeight = [SWPostCell messageHeightForPost:post];

    
    self.avatarImageView.layer.cornerRadius = 4.0;
    
    if (self.marked) self.contentView.backgroundColor = [UIColor colorWithRed:0.957 green:0.957 blue:0.957 alpha:1];
    else self.contentView.backgroundColor = [UIColor whiteColor];
    
    
    CGRect oldFrame = self.messageLabel.frame;
    self.messageLabel.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, messageHeight);
        
    oldFrame = self.conversationMarkerImageView.frame;
    
    NSLog(@"Replies : %@, reply_to: %@", post.num_replies, post.reply_to);
    BOOL threadExists = (post.num_replies != @0 || post.reply_to);
    if (!self.suppressConversationMarker && threadExists) {
        self.conversationMarkerImageView.hidden = FALSE;
        //self.conversationMarkerView.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, [SWPostCell heightForPost:post] - 40.0);
        self.conversationMarkerImageView.frame = CGRectMake(oldFrame.origin.x, ([SWPostCell heightForPost:post]/2 - 8), oldFrame.size.width, oldFrame.size.height);
    } else {
        self.conversationMarkerImageView.hidden = TRUE;
    }
    
    self.repostLabel.text = [NSString stringWithFormat:@"Reposted by @%@", originalPost.user.username];
    oldFrame = self.repostLabel.frame;
    self.repostLabel.frame =  CGRectMake(oldFrame.origin.x, messageHeight + 42, oldFrame.size.width, oldFrame.size.height);
    
    
    self.messageLabel.text = [SWHelpers fixNewlinesInString:post.text.text];
    
    //DLog(@"POST! %@", post);
    
    
    [self.messageLabel setAutomaticallyAddLinksForType:0];
    
    NSInteger messageLength = self.messageLabel.text.length;
    
    RichText *text = post.text;
    
    NSSet *entities = text.entities;
    
    for (TextEntity *entity in entities) {
        NSInteger position = [entity.pos integerValue];
        NSInteger length = [entity.len integerValue];
        if (position >= messageLength) continue;
        if (position + length > messageLength) length = messageLength - position;
        
        NSURL *url;
        if ([entity.type isEqualToString:@"hashtags"]) {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"#%@", entity.name]];
        } else if ([entity.type isEqualToString:@"links"]) {
            url = [NSURL URLWithString:entity.url];
        } else if ([entity.type isEqualToString:@"mentions"]) {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"@%@", entity.name]];
        }
        
        [self.messageLabel addCustomLink:url inRange:NSMakeRange(position, length)];
    
    }


        
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];    
    [dateFormatter setDateFormat:@"MMM d h:mma"];
    self.dateLabel.text = [dateFormatter stringFromDate:post.created_at];
    
    User *user = post.user;
    Image *avatarImage = user.avatar_image;
    self.usernameLabel.text = user.username;

    NSURL *avatarURL = [NSURL URLWithString:avatarImage.url];
    [self.avatarImageView setImageWithURL:avatarURL];
    
    if ([post valueForKey:@"you_starred"] && [[post valueForKey:@"you_starred"] intValue] == 1){
        self.contentView.backgroundColor = [UIColor colorWithRed:1.000 green:0.957 blue:0.580 alpha:1]; //Color Starred posts.
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
