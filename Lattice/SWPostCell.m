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
#import "SWHelpers.h"

@implementation SWPostCell

+ (CGFloat)messageHeightForPost:(NSDictionary *)post
{
    NSString *text = [post objectForKey:@"text"];
    
    CGSize constraint = CGSizeMake(225.0, 20000.0f);
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
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
        
    NSLog(@"POST!: %@", post);
    self.messageLabel.text = [post objectForKey:@"text"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    "created_at" = "2012-09-11T17:57:49Z";
    
    [dateFormatter setDateFormat:@"MMM dd h:mm a"];
    
    self.dateLabel.text = [dateFormatter stringFromDate:[SWHelpers dateFromRailsDateString:[post objectForKey:@"created_at"]]];
    
    NSDictionary *user = [post objectForKey:@"user"];
    NSDictionary *avatarInfo = [user objectForKey:@"avatar_image"];
    
    self.usernameLabel.text = [user objectForKey:@"username"];

    NSURL *avatarURL = [NSURL URLWithString:[avatarInfo objectForKey:@"url"]];
    
    
    [self.avatarImageView setImageWithURL:avatarURL];
}


@end
