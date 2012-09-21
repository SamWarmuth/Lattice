//
//  SWAnnotationCell.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/20/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWAnnotationView.h"
@interface SWAnnotationCell : UITableViewCell

@property (nonatomic, strong) IBOutlet SWAnnotationView *annotationView;

- (void)prepareUIWithAnnotationView:(SWAnnotationView *)annotationView;


@end
