//
//  SWAnnotationDetailViewController.m
//  Lattice
//
//  Created by Kent McCullough on 9/24/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWAnnotationDetailViewController.h"
#import "SWAnnotationCell.h"


@interface SWAnnotationDetailViewController ()

@end

@implementation SWAnnotationDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tv.backgroundColor = [UIColor colorWithRed:0.957 green:0.957 blue:0.957 alpha:1];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.annotationView.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self annotationCellForIndexPath:indexPath];
}

- (UITableViewCell *)annotationCellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SWAnnotationCell";
    SWAnnotationCell *cell = [self.tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SWAnnotationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell prepareUIWithAnnotationView:self.annotationView];
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
