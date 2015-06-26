//
//  BARSelectionIndicatorView.m
//  Bars
//
//  Created by Klaas Pieter Annema on 20-05-14.
//  Copyright (c) 2014 Karma. All rights reserved.
//

#import "BARSelectionIndicatorView.h"

@implementation BARSelectionIndicatorView

- (instancetype)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureSelectionIndicatorView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder;
{
    self = [super initWithCoder:coder];
    if (self) {
        [self configureSelectionIndicatorView];
    }
    return self;
}

- (void)configureSelectionIndicatorView;
{
    self.upwardsArrowSize = CGSizeMake(16.0, 8.0);
    self.upwardsArrowBottomInset = 0.0;
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGRect bounds = self.bounds;
    CGFloat arrowWidth = self.upwardsArrowSize.width;
    CGFloat arrowHeight = self.upwardsArrowSize.height;

    CGPoint lines[3] = {
        CGPointMake(floor(CGRectGetMidX(bounds) - (arrowWidth / 2.0)), CGRectGetHeight(bounds) - self.upwardsArrowBottomInset),
        CGPointMake(floor(CGRectGetMidX(bounds)), CGRectGetHeight(bounds) - arrowHeight - self.upwardsArrowBottomInset),
        CGPointMake(floor(CGRectGetMidX(bounds) + (arrowWidth / 2.0)), CGRectGetHeight(bounds) - self.upwardsArrowBottomInset)
    };

    [[UIColor whiteColor] set];
    CGContextSetShadowWithColor(context, self.upwardsArrowShadow.shadowOffset, self.upwardsArrowShadow.shadowBlurRadius, [self.upwardsArrowShadow.shadowColor CGColor]);
    CGContextAddLines(context, lines, 3);
    CGContextFillPath(context);

    [self.color set];
    CGContextFillRect(context, self.bounds);
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    [self setNeedsDisplay];
}

@end
