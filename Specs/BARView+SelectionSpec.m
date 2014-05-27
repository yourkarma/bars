#import "SpecHelper.h"

#import "BARView.h"
#import "BARSelectionIndicatorView.h"

SpecBegin(BARViewSpec_Selection)

__block BARView *_barView;

describe(@"BARView+Selection", ^{
    before(^{
        _barView = [[BARView alloc] initWithFrame:CGRectZero];
        id<BARViewDataSource> dataSource = mockProtocol(@protocol(BARViewDataSource));
        [given([dataSource numberOfBarsInBarView:_barView]) willReturnInteger:2];
        [given([dataSource barView:_barView valueForBarAtIndex:0]) willReturnDouble:49.0];
        [given([dataSource barView:_barView valueForBarAtIndex:1]) willReturnDouble:200.0];
        _barView.dataSource = dataSource;
        setFrame(_barView, CGRectMake(0.0, 0.0, 100.0, 100.0));
    });
    
    it(@"supports not showing a selection indicator", ^{
        _barView.showsSelectionIndicator = NO;
        [_barView layoutSubviews];
        expect(_barView.selectionIndicatorView.frame).to.equal(CGRectZero);
    });
    
    it(@"can determine the index of the selected bar", ^{
        _barView.contentOffset = CGPointMake(_barView.contentOffset.x + kBarViewDefaultBarWidth,
                                             _barView.contentOffset.y);
        expect([_barView indexOfSelectedBar]).to.equal(1);
    });
    
    it(@"can scroll to the selected bar", ^{
        [_barView selectBarAtIndex:1];
        expect(_barView.contentOffset).to.equal(CGPointMake(0.0, 0.0));
    });
    
    it(@"cannot select bars outside of the upper bounds", ^{
        [_barView selectBarAtIndex:2];
        expect([_barView indexOfSelectedBar]).to.equal(1);
    });
    
    it(@"cannot select bars when there is no data", ^{
        [given([_barView.dataSource numberOfBarsInBarView:_barView]) willReturnInteger:0];
        [_barView reloadData];
        [_barView selectBarAtIndex:2];
        expect([_barView indexOfSelectedBar]).to.equal(NSNotFound);
    });
});

SpecEnd
