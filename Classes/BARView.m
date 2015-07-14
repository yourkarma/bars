//
//  BARView.m
//  Bars
//
//  Created by Klaas Pieter Annema on 30-04-14.
//  Copyright (c) 2014 Karma. All rights reserved.
//

#import "BARView.h"
#import "BARView+UIScrollViewDelegate.h"

#import "BARSelectionIndicatorView.h"

CGFloat const kBarViewDefaultBarWidth = 45.0;
CGFloat const kBarAxisViewDefaultHeight = 65.0;

#define CLAMP(x, low, high)  (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))

@interface BARView () <UIScrollViewDelegate>
@property (nonatomic, readwrite, weak) id internalDelegate;

@property (nonatomic, readwrite, copy) NSArray *cachedValues;
@property (nonatomic, readwrite, strong) NSMutableDictionary *cachedLabelViews;
@property (nonatomic, readwrite, strong) NSMutableDictionary *cachedColumnViews;

@property (nonatomic, readwrite, strong) UIView *barsContainerView;
@property (nonatomic, readwrite, strong) UIView *axisContainerView;
@property (nonatomic, readwrite, strong) BARSelectionIndicatorView *selectionIndicatorView;
@property (nonatomic, readwrite, strong) UIView *gridContainerView;

@property (nonatomic, readwrite, strong) UIView *topDividerView;
@property (nonatomic, readwrite, strong) UIView *bottomDividerView;

@property (nonatomic, readwrite, assign) CGFloat heightFractionForVisibleBars;

@property (nonatomic, readwrite, assign) NSInteger selectionIndex;
@end

@implementation BARView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _barViewInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder;
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _barViewInit];
    }
    return self;
}

- (void)_barViewInit;
{
    self.showsSelectionIndicator = YES;
    self.barColor = [UIColor colorWithRed:96.0 / 255.0 green:195.0 / 255.0 blue:173.0 / 255.0 alpha:1.0];
    self.selectionIndicatorColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.gridColor = [UIColor colorWithWhite:0.0 alpha:0.05];
    self.showsHorizontalScrollIndicator = NO;
    self.clipsToBounds = YES;
    self.selectionIndicatorView = ({
        BARSelectionIndicatorView *view = [[BARSelectionIndicatorView alloc] initWithFrame:CGRectZero];
        [self addSubview:view];
        view;
    });
    
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    super.delegate = self;

    self.barWidth = kBarViewDefaultBarWidth;
    self.axisHeight = kBarAxisViewDefaultHeight;
}

- (void)reloadData;
{
    [self centerContent];
    
    self.cachedValues = nil;
    NSUInteger numberOfBars = [self numberOfBars];
    CGFloat maxValue = 0.0;
    
    self.cachedValues = ({
        NSMutableArray *values = [NSMutableArray arrayWithCapacity:numberOfBars];
        for (NSUInteger index = 0; index < numberOfBars; index++) {
            CGFloat value = [self valueForBarAtIndex:index];
            [values addObject:@(value)];
            maxValue = MAX(value, maxValue);
        }
        values;
    });
    
    self.barsContainerView = ({
        [self.barsContainerView removeFromSuperview];
        UIView *view = [[UIView alloc] initWithFrame:[self rectForBarsContainerView]];
        view.translatesAutoresizingMaskIntoConstraints = YES;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:view];
        
        self.heightFractionForVisibleBars = [self heightFractionWithAvailableHeight:CGRectGetHeight(view.frame) maxValue:maxValue];
        for (NSUInteger index = 0; index < numberOfBars; index++) {
            UIView *bar = [[UIView alloc] initWithFrame:[self rectForVisibleBarAtIndex:index]];
            [view addSubview:bar];
        }
        
        view;
    });
    
    self.cachedLabelViews = [NSMutableDictionary dictionary];
    self.axisContainerView = ({
        [self.axisContainerView removeFromSuperview];
        UIView *view = [[UIView alloc] initWithFrame:[self rectForAxisContainerView]];
        view.translatesAutoresizingMaskIntoConstraints = YES;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:view];
        view;
    });
    
    self.cachedColumnViews = [NSMutableDictionary dictionary];
    self.gridContainerView = ({
        CGRect rect = [self rectForGridContainerView];
        UIView *view = [[UIView alloc] initWithFrame:rect];
        view.translatesAutoresizingMaskIntoConstraints = YES;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:view];
        
        self.topDividerView = [[UIView alloc] initWithFrame:[self rectForTopDividerView]];
        [view addSubview:self.topDividerView];
        
        self.bottomDividerView = [[UIView alloc] initWithFrame:[self rectForBottomDividerView]];
        [view addSubview:self.bottomDividerView];
        
        view;
    });

    self.contentSize = self.barsContainerView.frame.size;
    [self setNeedsLayout];
}

- (void)layoutSubviews;
{
    [super layoutSubviews];

    [self centerContent];

    NSRange visibleRange = [self visibleRange];
    NSArray *values = [self.cachedValues objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:visibleRange]];
    
    CGFloat maxValue = 0.0;
    for (NSNumber *value in values) {
        maxValue = MAX([value doubleValue], maxValue);
    }
    
    CGFloat availableHeight = CGRectGetHeight([self rectForBarsContainerView]);
    self.heightFractionForVisibleBars = [self heightFractionWithAvailableHeight:availableHeight maxValue:maxValue];
    
    for (NSUInteger index = visibleRange.location; index < NSMaxRange(visibleRange); index++) {
        UIView *view = self.barsContainerView.subviews[index];
        view.backgroundColor = self.barColor;
        
        [UIView animateWithDuration:0.25 animations:^{
            view.frame = [self rectForVisibleBarAtIndex:index];
        }];
    }
    
    NSInteger firstIndex = [self firstVisibleIndexClamped:NO];
    NSInteger lastIndex = [self lastVisibleIndexClamped:NO] + 1;
    
    for (NSUInteger index = 0; index < ABS(firstIndex) + lastIndex; index++) {
        NSInteger actualIndex = index - ABS(firstIndex);
    
        UIView *label = [self labelViewForBarAtIndex:actualIndex];
        label.frame = [self rectForVisibleLabelAtIndex:actualIndex];
        
        UIView *column = [self gridColumnAtIndex:actualIndex];
        column.frame = [self rectForGridColumnAtIndex:actualIndex];
        column.backgroundColor = self.gridColor;
        self.topDividerView.backgroundColor = self.gridColor;
        self.bottomDividerView.backgroundColor = self.gridColor;
    }

    self.barsContainerView.frame = [self rectForBarsContainerView];
    self.axisContainerView.frame = [self rectForAxisContainerView];
    self.selectionIndicatorView.frame = [self rectForSelectionIndicatorView];
    self.selectionIndicatorView.color = self.selectionIndicatorColor;
    self.gridContainerView.frame = [self rectForGridContainerView];
    self.topDividerView.frame = [self rectForTopDividerView];
    self.bottomDividerView.frame = [self rectForBottomDividerView];

    [self bringSubviewToFront:self.gridContainerView];
    [self bringSubviewToFront:self.selectionIndicatorView];

    self.contentSize = self.barsContainerView.frame.size;

    if (!self.isTracking && !self.isDragging && !self.isDecelerating && self.selectionIndex != [self indexOfSelectedBar]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self selectBarAtIndex:self.selectionIndex];
        });
    }
}

- (CGFloat)heightFractionWithAvailableHeight:(CGFloat)height maxValue:(CGFloat)maxValue;
{
    if (maxValue == 0) {
        return 0;
    }
    
    return height / maxValue;
}

- (void)centerContent;
{
    self.contentInset = ({
        CGFloat vertical = 0.0;
        CGFloat horizontal = floor(CGRectGetWidth(self.frame) / 2.0) - floor(self.barWidth / 2.0);
        horizontal = round(horizontal / self.barWidth) * self.barWidth;
        UIEdgeInsetsMake(vertical, horizontal, vertical, horizontal);
    });
}

- (NSUInteger)numberOfBars;
{
    if (self.cachedValues) {
        return self.cachedValues.count;
    }
    
    return [self.dataSource numberOfBarsInBarView:self];
}

- (CGFloat)valueForBarAtIndex:(NSUInteger)index;
{
    if (self.cachedValues) {
        return [self.cachedValues[index] doubleValue];
    }
    
    return [self.dataSource barView:self valueForBarAtIndex:index];
}

- (UIView *)labelViewForBarAtIndex:(NSInteger)index;
{
    NSNumber *key = @(index);
    UIView *label = self.cachedLabelViews[key];
    
    if (!label) {
        if ([self.dataSource respondsToSelector:@selector(barView:labelViewForBarAtIndex:)]) {
            label = [self.dataSource barView:self labelViewForBarAtIndex:index];
        }
        
        if (!label) {
            label = [[UIView alloc] init];
            label.hidden = YES;
        }
        self.cachedLabelViews[key] = label;
        [self.axisContainerView addSubview:label];
    }
    
    return label;
}

- (UIView *)gridColumnAtIndex:(NSInteger)index;
{
    NSNumber *key = @(index);
    UIView *column = self.cachedColumnViews[key];
    
    if (!column) {
        column = [[UIView alloc] initWithFrame:CGRectZero];
        [self.gridContainerView addSubview:column];
        self.cachedColumnViews[key] = column;
    }
    
    return column;
}

- (NSInteger)firstVisibleIndexClamped:(BOOL)clamp;
{
    CGPoint point = self.contentOffset;
    point.x -= [self horizontalOffset];
    return [self indexForBarAtPoint:point clamp:clamp];
}

- (NSInteger)lastVisibleIndexClamped:(BOOL)clamp;
{
    CGPoint point = self.contentOffset;
    point.x -= [self horizontalOffset];
    
    return [self indexForBarAtPoint:CGPointMake(point.x + CGRectGetWidth(self.bounds), 0.0) clamp:clamp];
}

- (NSUInteger)indexForBarAtPoint:(CGPoint)point;
{
    return [self indexForBarAtPoint:point clamp:YES];
}

- (NSInteger)indexForBarAtPoint:(CGPoint)point clamp:(BOOL)clamp;
{
    NSInteger index = floor(point.x / self.barWidth);
    if (clamp) {
        index = CLAMP(floor(point.x / self.barWidth), 0, [self numberOfBars] - 1);
    }
    return index;
}

- (CGRect)rectForVisibleBarAtIndex:(NSUInteger)index;
{
    CGFloat value = [self valueForBarAtIndex:index];
    CGFloat availableHeight = CGRectGetHeight([self rectForBarsContainerView]);
    
    CGFloat height = floor(value * self.heightFractionForVisibleBars);
    
    return CGRectMake(index * self.barWidth,
                      availableHeight - height,
                      self.barWidth,
                      height);
}

- (CGRect)rectForVisibleLabelAtIndex:(NSInteger)index;
{
    return CGRectMake(index * self.barWidth,
                      0.0,
                      self.barWidth,
                      self.axisHeight);
}

- (CGRect)rectForGridColumnAtIndex:(NSInteger)index;
{
    return CGRectMake(index * self.barWidth,
                      0.5,
                      0.5,
                      CGRectGetHeight([self rectForGridContainerView]) - 1.0);
}

- (NSRange)visibleRange;
{
    NSUInteger firstVisibleBarIndex = [self firstVisibleIndexClamped:YES];
    NSUInteger lastVisibleBarIndex = [self lastVisibleIndexClamped:YES] + 1;
    
    if (lastVisibleBarIndex > [self numberOfBars]) {
        lastVisibleBarIndex = [self numberOfBars];
    }
    
    return NSMakeRange(firstVisibleBarIndex, lastVisibleBarIndex - firstVisibleBarIndex);
}

- (void)selectBarAtIndex:(NSUInteger)index;
{
    return [self selectBarAtIndex:index animated:NO];
}

- (void)selectBarAtIndex:(NSUInteger)index animated:(BOOL)animated;
{
    if ([self numberOfBars] == 0) {
        return;
    }
    
    NSRange range = NSMakeRange(0, [self numberOfBars] - 1);
    if (!NSLocationInRange(index, range)) {
        index = NSMaxRange(range);
    }

    CGPoint offset = ({
        CGPoint offset = [self rectForVisibleBarAtIndex:index].origin;
        offset.x -= self.contentInset.left;
        offset.y = 0.0;
        offset;
    });
    [self setContentOffset:offset animated:animated];
    self.selectionIndex = index;
}

- (CGRect)rectForBarsContainerView;
{
    return CGRectMake([self horizontalOffset], 0.0,
                      (self.barWidth * [self numberOfBars]) + ([self horizontalOffset] * 2.0),
                      CGRectGetHeight(self.bounds) - self.axisHeight);
}

- (CGRect)rectForAxisContainerView;
{
    CGRect barsRect = [self rectForBarsContainerView];
    
    return CGRectMake([self horizontalOffset], CGRectGetMaxY(barsRect), (self.barWidth * [self numberOfBars]) * 2.0, self.axisHeight);
}

- (CGRect)rectForGridContainerView;
{
    return CGRectMake([self horizontalOffset], 0.0, (self.barWidth * [self numberOfBars]) * 2.0, CGRectGetHeight(self.bounds));
}

- (CGPoint)targetContentOffsetForContentOffset:(CGPoint)point {
    point.x = (round(point.x / self.barWidth) * self.barWidth);
    return point;
}

- (CGRect)rectForSelectionIndicatorView;
{
    if (!self.showsSelectionIndicator || [self numberOfBars] <= 0) {
        return CGRectZero;
    }
    
    CGFloat width = self.barWidth;
    CGFloat height = CGRectGetHeight([self rectForBarsContainerView]);

    CGPoint contentOffset = CGPointZero;
    if (self.isTracking || self.isDragging || self.decelerating) {
        contentOffset = self.contentOffset;
    } else {
        contentOffset = [self targetContentOffsetForContentOffset:self.contentOffset];
    }

    CGFloat x = contentOffset.x + floor(CGRectGetWidth(self.frame) / 2.0) - floor(self.barWidth / 2.0);
    CGFloat y = 0.0;
    return CGRectMake(x, y, width, height);
}

- (CGRect)rectForTopDividerView;
{
    CGFloat x = CGRectGetMinX(self.bounds);
    CGFloat y = 0.0;
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = 0.5;
    return CGRectMake(x, y, width, height);
}

- (CGRect)rectForBottomDividerView;
{
    CGFloat x = CGRectGetMinX(self.bounds);
    CGFloat y = CGRectGetHeight(self.bounds) - self.axisHeight - 0.5;
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = 0.5;
    return CGRectMake(x, y, width, height);
}

- (void)setDataSource:(id<BARViewDataSource>)dataSource;
{
    if (_dataSource == dataSource) {
        return;
    }
    
    _dataSource = dataSource;
    [self reloadData];
}

- (void)setShowsSelectionIndicator:(BOOL)showsSelectionIndicator;
{
    if (_showsSelectionIndicator == showsSelectionIndicator) {
        return;
    }
    
    _showsSelectionIndicator = showsSelectionIndicator;
    [self setNeedsLayout];
}

- (void)setBarColor:(UIColor *)barColor;
{
    if (_barColor == barColor) {
        return;
    }
    
    _barColor = barColor;
    [self setNeedsLayout];
}

- (void)setSelectionIndicatorColor:(UIColor *)selectionIndicatorColor;
{
    if (_selectionIndicatorColor == selectionIndicatorColor) {
        return;
    }
    
    _selectionIndicatorColor = selectionIndicatorColor;
    [self setNeedsLayout];
}

- (NSUInteger)indexOfSelectedBar;
{
    if ([self numberOfBars] <= 0) {
        return NSNotFound;
    }
    
    CGPoint selectionPoint = CGPointMake(self.contentOffset.x + floor(CGRectGetWidth(self.frame) / 2.0),
                                         self.contentOffset.y);
    return [self indexForBarAtPoint:selectionPoint];
}

- (CGFloat)horizontalOffset;
{
    // Imagine a view that is 45ps wide and each bar being 25ps.
    // Laying out each bar normally would get a bar at x=0 and at x=25.
    // The selection indicator (which is centered) would be displayed at x = floor((45 / 2) - (25 / 2)) = 10.
    // In other words the selection indicator does not match up with any of the bars.
    // This method calculates what offset the bars (or actually the view containing the bars) need to be displayed at
    // in order to match up with the selection indicator.
    // Completing our initial example. The first bar will now be displayed at x=10 and the second bar at x=35.
    return (floor(CGRectGetWidth(self.frame) / 2.0) - floor(self.barWidth / 2.0)) - self.contentInset.left;
}

- (id<UIScrollViewDelegate>)delegate;
{
    return _internalDelegate;
}

- (void)setDelegate:(id<UIScrollViewDelegate>)delegate;
{
    _internalDelegate = delegate;
}

@end
