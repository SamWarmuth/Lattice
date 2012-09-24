//
//  SWActionCell.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/12/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWActionCell.h"

@implementation SWActionCell

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


- (void)awakeFromNib
{
    [super awakeFromNib];
    [self prepareUI];
}

- (void)prepareUI
{
}

- (void)prepareUIWithUser:(User *)user
{    
    [self.postsButton     setTitle:[NSString stringWithFormat:@"%@ Posts",     user.posts_count]     forState:UIControlStateNormal];
    [self.starredButton   setTitle:[NSString stringWithFormat:@"%@ Starred",   user.stars_count]     forState:UIControlStateNormal];
    [self.followingButton setTitle:[NSString stringWithFormat:@"%@ Following", user.following_count] forState:UIControlStateNormal];
    [self.followersButton setTitle:[NSString stringWithFormat:@"%@ Followers", user.followers_count] forState:UIControlStateNormal];
    
}

- (void)prepareUIWithPost:(Post *)post
{    
    self.starButton.highlighted = ([post.you_starred intValue] == 1);
    self.repostButton.highlighted = ([post.you_reposted intValue] == 1);

}


@end
