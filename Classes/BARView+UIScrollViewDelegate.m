//
//  BARView+UIScrollViewDelegate.m
//  Bars
//
//  Created by Klaas Pieter Annema on 08-05-14.
//  Copyright (c) 2014 Karma. All rights reserved.
//

#import "BARView+UIScrollViewDelegate.h"

@interface BARView ()
@property (nonatomic, readwrite, assign) NSInteger selectionIndex;
- (CGPoint)targetContentOffsetForContentOffset:(CGPoint)point;
- (CGFloat)horizontalOffset;
@end

@implementation BARView (UIScrollViewDelegate)

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView;
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate scrollViewDidZoom:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;
{
    *targetContentOffset = [self targetContentOffsetForContentOffset:*targetContentOffset];
    
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView;
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    CGPoint offset = self.rectForSelectionIndicatorView.origin;
    offset.x -= [self horizontalOffset];

    self.selectionIndex = [self indexForBarAtPoint:offset];

    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView;
{
    if ([self.delegate respondsToSelector:_cmd]) {
        return [self.delegate viewForZoomingInScrollView:scrollView];
    }
    
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view;
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale;
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView;
{
    if ([self.delegate respondsToSelector:_cmd]) {
        return [self.delegate scrollViewShouldScrollToTop:scrollView];
    }
    
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView;
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self scrollViewDidScrollToTop:scrollView];
    }
}


@end
