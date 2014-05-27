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
@property (nonatomic, readwrite, assign) id internalDelegate;

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
@end

@implementation BARView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _barViewInit];
    }
    return self;
}

- (void)awakeFromNib;
{
    [super awakeFromNib];
    [self _barViewInit];
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
        
        self.heightFractionForVisibleBars = CGRectGetHeight(view.frame) / maxValue;
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
        
        self.topDividerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(rect), 0.5)];
        [view addSubview:self.topDividerView];
        
        self.bottomDividerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, CGRectGetHeight(rect) - kBarAxisViewDefaultHeight - 0.5, CGRectGetWidth(rect), 0.5)];
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
    self.heightFractionForVisibleBars = availableHeight / maxValue;
    
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
    self.selectionIndicatorView.backgroundColor = self.selectionIndicatorColor;
    self.gridContainerView.frame = [self rectForGridContainerView];
    
    [self bringSubviewToFront:self.gridContainerView];
    [self bringSubviewToFront:self.selectionIndicatorView];
    
    self.contentSize = self.barsContainerView.frame.size;
}

- (void)centerContent;
{
    self.contentInset = ({
        CGFloat vertical = 0.0;
        CGFloat horizontal = floor(CGRectGetWidth(self.frame) / 2.0) - floor(kBarViewDefaultBarWidth / 2.0);
        horizontal = round(horizontal / kBarViewDefaultBarWidth) * kBarViewDefaultBarWidth;
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
    NSInteger index = floor(point.x / kBarViewDefaultBarWidth);
    if (clamp) {
        index = CLAMP(floor(point.x / kBarViewDefaultBarWidth), 0, [self numberOfBars] - 1);
    }
    return index;
}

- (CGRect)rectForVisibleBarAtIndex:(NSUInteger)index;
{
    CGFloat value = [self valueForBarAtIndex:index];
    CGFloat availableHeight = CGRectGetHeight([self rectForBarsContainerView]);
    
    CGFloat height = floor(value * self.heightFractionForVisibleBars);
    
    return CGRectMake(index * kBarViewDefaultBarWidth,
                      availableHeight - height,
                      kBarViewDefaultBarWidth,
                      height);
}

- (CGRect)rectForVisibleLabelAtIndex:(NSInteger)index;
{
    return CGRectMake(index * kBarViewDefaultBarWidth,
                      0.0,
                      kBarViewDefaultBarWidth,
                      kBarAxisViewDefaultHeight);
}

- (CGRect)rectForGridColumnAtIndex:(NSInteger)index;
{
    return CGRectMake(index * kBarViewDefaultBarWidth,
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
}

- (CGRect)rectForBarsContainerView;
{
    return CGRectMake([self horizontalOffset], 0.0,
                      (kBarViewDefaultBarWidth * [self numberOfBars]) + ([self horizontalOffset] * 2.0),
                      CGRectGetHeight(self.bounds) - kBarAxisViewDefaultHeight);
}

- (CGRect)rectForAxisContainerView;
{
    CGRect barsRect = [self rectForBarsContainerView];
    
    return CGRectMake([self horizontalOffset], CGRectGetMaxY(barsRect), (kBarViewDefaultBarWidth * [self numberOfBars]) * 2.0, kBarAxisViewDefaultHeight);
}

- (CGRect)rectForGridContainerView;
{
    return CGRectMake([self horizontalOffset], 0.0, (kBarViewDefaultBarWidth * [self numberOfBars]) * 2.0, CGRectGetHeight(self.bounds));
}

- (CGRect)rectForSelectionIndicatorView;
{
    if (!self.showsSelectionIndicator || [self numberOfBars] <= 0) {
        return CGRectZero;
    }
    
    CGFloat width = kBarViewDefaultBarWidth;
    CGFloat height = CGRectGetHeight([self rectForBarsContainerView]);
    
    CGFloat x = self.contentOffset.x + floor(CGRectGetWidth(self.frame) / 2.0) - floor(kBarViewDefaultBarWidth / 2.0);
    CGFloat y = 0.0;
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
    return (floor(CGRectGetWidth(self.frame) / 2.0) - floor(kBarViewDefaultBarWidth / 2.0)) - self.contentInset.left;
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