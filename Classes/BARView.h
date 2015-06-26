//
//  BARView.h
//  Bars
//
//  Created by Klaas Pieter Annema on 30-04-14.
//  Copyright (c) 2014 Karma. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BARSelectionIndicatorView;

@protocol BARViewDataSource;

extern CGFloat const kBarViewDefaultBarWidth;
extern CGFloat const kBarAxisViewDefaultHeight;

@interface BARView : UIScrollView

@property (nonatomic, readwrite, assign) id<BARViewDataSource> dataSource;

@property (nonatomic, readwrite, assign) BOOL showsSelectionIndicator;

@property (nonatomic, readwrite, copy) UIColor *barColor;
@property (nonatomic, readwrite, copy) UIColor *selectionIndicatorColor;

@property (nonatomic, readwrite, copy) UIColor *gridColor;

@property (nonatomic, readonly, strong) UIView *barsContainerView;
@property (nonatomic, readonly, strong) UIView *axisContainerView;
@property (nonatomic, readonly, strong) BARSelectionIndicatorView *selectionIndicatorView;
@property (nonatomic, readonly, strong) UIView *gridContainerView;

@property (nonatomic, readwrite, assign) CGFloat barWidth;
@property (nonatomic, readwrite, assign) CGFloat axisHeight;

- (NSUInteger)numberOfBars;
- (CGFloat)valueForBarAtIndex:(NSUInteger)index;

- (NSRange)visibleRange;

- (CGRect)rectForVisibleBarAtIndex:(NSUInteger)index;
- (NSUInteger)indexForBarAtPoint:(CGPoint)point;

- (UIView *)labelViewForBarAtIndex:(NSInteger)index;
- (CGRect)rectForVisibleLabelAtIndex:(NSInteger)index;

- (CGRect)rectForSelectionIndicatorView;

- (NSUInteger)indexOfSelectedBar;

- (void)selectBarAtIndex:(NSUInteger)index;
- (void)selectBarAtIndex:(NSUInteger)index animated:(BOOL)animated;

- (void)reloadData;

@end

@protocol BARViewDataSource <NSObject>
- (NSUInteger)numberOfBarsInBarView:(BARView *)barView;
- (CGFloat)barView:(BARView *)barView valueForBarAtIndex:(NSUInteger)index;

@optional
- (UIView *)barView:(BARView *)barView labelViewForBarAtIndex:(NSInteger)index;
@end