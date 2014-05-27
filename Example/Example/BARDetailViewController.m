    //
//  BARDetailViewController.m
//  Example
//
//  Created by Klaas Pieter Annema on 30-04-14.
//  Copyright (c) 2014 Karma. All rights reserved.
//

#import "BARDetailViewController.h"

#import "BARView.h"

@interface BARDetailViewController () <BARViewDataSource, UISplitViewControllerDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@property (nonatomic, readwrite, copy) NSArray *sortedDates;
@property (nonatomic, readwrite, copy) NSDate *earliestDate;
@property (nonatomic, readwrite, copy) NSDate *lastDate;

@end

@implementation BARDetailViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    self.barView.dataSource = self;
    self.barView.delegate = self;
}

- (void)setData:(NSDictionary *)data;
{
    if (_data == data) {
        return;
    }
    
    _data = data;
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
    
    self.sortedDates = [data.allKeys sortedArrayUsingSelector:@selector(compare:)];
    [self.barView reloadData];
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    
    [self.barView reloadData];
    
    // Intentionally go out of bounds :)
    [self.barView selectBarAtIndex:3100 animated:YES];
}

#pragma mark - Bar view
- (NSUInteger)numberOfBarsInBarView:(BARView *)barView;
{
    NSLog(@"numberOfBarsInBarView: %lu", self.data.count);
    return self.data.count;
}

- (id<NSCopying>)keyAtIndex:(NSUInteger)index;
{
    if (index >= self.sortedDates.count) {
        return nil;
    }
    return self.sortedDates[index];
}

- (CGFloat)barView:(BARView *)barView valueForBarAtIndex:(NSUInteger)index;
{
    id <NSCopying> key = [self keyAtIndex:index];
    CGFloat value = [self.data[key] doubleValue];
    NSLog(@"valueForBarAtIndex: %lu : %f", (unsigned long)index, value);
    return value;
}

- (UIView *)barView:(BARView *)barView labelViewForBarAtIndex:(NSInteger)index;
{
    NSDate *date;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"dd MM" options:0 locale:[NSLocale currentLocale]];
    
    if (index < 0) {
        dayComponent.day = index;
        date = [calendar dateByAddingComponents:dayComponent toDate:self.earliestDate options:0];
    } else if (index >= self.data.count) {
        NSInteger offset = (index - self.data.count) + 1;
        dayComponent.day = offset;
        date = [calendar dateByAddingComponents:dayComponent toDate:self.lastDate options:0];
    } else {
        date = (NSDate *)[self keyAtIndex:index];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = [formatter stringFromDate:date];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:8.0];
    
    return label;
}

- (NSDate *)earliestDate;
{
    if (!self.sortedDates.count) {
        return [NSDate date];
    }
    return self.sortedDates.firstObject;
}

- (NSDate *)lastDate;
{
    if (!self.sortedDates.count) {
        return [NSDate date];
    }
    return self.sortedDates.lastObject;
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Scroll view
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    NSUInteger index = [self.barView indexOfSelectedBar];
    id<NSCopying> key = [self keyAtIndex:index];
    self.valueLabel.text = [self.data[key] stringValue];
}

@end
