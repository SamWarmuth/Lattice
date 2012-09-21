//
//  SWPostDetailViewController.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/12/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWPostDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tv;
@property (nonatomic, strong) NSDictionary *post;
@property (nonatomic, strong) NSMutableArray *annotationViews;

- (UITableViewCell *)postCellForIndexPath:(NSIndexPath *)indexPath;

@end
