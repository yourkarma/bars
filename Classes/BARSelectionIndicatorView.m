//
//  BARSelectionIndicatorView.m
//  Bars
//
//  Created by Klaas Pieter Annema on 20-05-14.
//  Copyright (c) 2014 Karma. All rights reserved.
//

#import "BARSelectionIndicatorView.h"

@implementation BARSelectionIndicatorView

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] set];
    
    CGRect bounds = self.bounds;
    CGFloat arrowWidth = 16.0;
    CGFloat arrowHeight = 8.0;
    
    CGContextMoveToPoint(context, floor(CGRectGetMidX(bounds) - (arrowWidth / 2.0)), CGRectGetHeight(bounds));
    CGContextAddLineToPoint(context, floor(CGRectGetMidX(bounds)), CGRectGetHeight(bounds) - arrowHeight);
    CGContextAddLineToPoint(context, floor(CGRectGetMidX(bounds) + (arrowWidth / 2.0)), CGRectGetHeight(bounds));
    CGContextFillPath(context);
}

- (void)setBackgroundColor:(UIColor *)backgroundColor;
{
    [super setBackgroundColor:backgroundColor];
    [self setNeedsDisplay];
}

@end
