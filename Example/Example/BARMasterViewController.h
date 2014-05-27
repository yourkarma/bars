//
//  BARMasterViewController.h
//  Example
//
//  Created by Klaas Pieter Annema on 30-04-14.
//  Copyright (c) 2014 Karma. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BARDetailViewController;

@interface BARMasterViewController : UITableViewController

@property (strong, nonatomic) BARDetailViewController *detailViewController;

@end
