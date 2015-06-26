//
//  BARSelectionIndicatorView.h
//  Bars
//
//  Created by Klaas Pieter Annema on 20-05-14.
//  Copyright (c) 2014 Karma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BARSelectionIndicatorView : UIView

@property (nonatomic, readwrite, copy) UIColor *color;

@property (nonatomic, readwrite, assign) CGSize upwardsArrowSize;
@property (nonatomic, readwrite, assign) CGFloat upwardsArrowBottomInset;
@property (nonatomic, readwrite, copy) NSShadow *upwardsArrowShadow;

@end
