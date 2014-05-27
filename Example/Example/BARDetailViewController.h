//
//  BARDetailViewController.h
//  Example
//
//  Created by Klaas Pieter Annema on 30-04-14.
//  Copyright (c) 2014 Karma. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BARView;

@interface BARDetailViewController : UIViewController
@property (nonatomic, readwrite, copy) NSDictionary *data;

@property (nonatomic, readwrite, weak) IBOutlet BARView *barView;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *valueLabel;
@end
