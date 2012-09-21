//
//  SWAnnotationCell.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/20/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWAnnotationCell.h"

@implementation SWAnnotationCell

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

- (void)prepareUIWithAnnotationView:(SWAnnotationView *)annotationView
{
    //self.contentView.backgroundColor = [UIColor purpleColor];
    if (self.annotationView) [self.annotationView removeFromSuperview];
    self.annotationView = annotationView;
    [self.contentView addSubview:self.annotationView];
}

@end
