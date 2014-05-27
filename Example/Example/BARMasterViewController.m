//
//  BARMasterViewController.m
//  Example
//
//  Created by Klaas Pieter Annema on 30-04-14.
//  Copyright (c) 2014 Karma. All rights reserved.
//

#import "BARMasterViewController.h"

#import "BARDetailViewController.h"

@interface BARMasterViewController ()
@end

@implementation BARMasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.detailViewController = (BARDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    self.detailViewController.data = [self dataForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
}

#pragma mark - Table View

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.detailViewController.data = [self dataForRowAtIndexPath:indexPath];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] hasPrefix:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        BARDetailViewController *detailViewController = segue.destinationViewController;
        detailViewController.data = [self dataForRowAtIndexPath:indexPath];
    }
}

- (NSDictionary *)dataForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    for (NSUInteger i = 0; i < [self numberOfDataPointsForRowAtIndexPath:indexPath]; i++) {
        NSDate *date = [NSDate date];
        NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
        [dateComponent setValue:@(i) forKey:[self dateComponentKeyForRowAtIndexPath:indexPath]];
        date = [calendar dateByAddingComponents:dateComponent toDate:date options:0];
        data[date] = @(arc4random_uniform(10000));
    }
    
    return [data copy];
}

- (NSUInteger)numberOfDataPointsForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return [[@[@24, @31, @12, @0] objectAtIndex:indexPath.row] unsignedIntegerValue];
}

- (NSString *)dateComponentKeyForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return [@[@"hour", @"day", @"month", @"day"] objectAtIndex:indexPath.row];
}

@end
