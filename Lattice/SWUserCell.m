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

@implementation SWUserCell

+ (CGFloat)messageHeightForUser:(NSDictionary *)user
{
    NSString *text = [user objectForKey:@"text"];
    
    CGSize constraint = CGSizeMake(225.0, 20000.0f);
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    return size.height;
}

+ (CGFloat)heightForUser:(NSDictionary *)user
{
    return 141.0;
    CGFloat height = MAX([self messageHeightForUser:user] + 55.0, 88.0);
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
    
    self.messageLabel.text = [[user objectForKey:@"description"] objectForKey:@"text"];
        
    NSDictionary *avatarInfo = [user objectForKey:@"avatar_image"];
    
    self.usernameLabel.text = [user objectForKey:@"username"];
    
    NSURL *avatarURL = [NSURL URLWithString:[avatarInfo objectForKey:@"url"]];    
    [self.avatarImageView setImageWithURL:avatarURL];
    
    
}
@end
