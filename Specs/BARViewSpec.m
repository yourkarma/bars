#import "SpecHelper.h"

#import "BARView.h"

SpecBegin(BARView)

describe(@"BARView", ^{
    __block BARView *_barView;
    
    before(^{
        _barView = [[BARView alloc] initWithFrame:CGRectMake(0.0, 0.0, 24.0, 100.0)];
        
        id<BARViewDataSource> dataSource = mockProtocol(@protocol(BARViewDataSource));
        [given([dataSource numberOfBarsInBarView:_barView]) willReturnInteger:2];
        [given([dataSource barView:_barView valueForBarAtIndex:0]) willReturnDouble:49.0];
        [given([dataSource barView:_barView valueForBarAtIndex:1]) willReturnDouble:200.0];
        
        UILabel *label1 = [[UILabel alloc] init];
        label1.text = @"1/1";
        [given([dataSource barView:_barView labelViewForBarAtIndex:0]) willReturn:label1];
        
        UILabel *label2 = [[UILabel alloc] init];
        label2.text = @"2/2";
        [given([dataSource barView:_barView labelViewForBarAtIndex:1]) willReturn:label2];
        _barView.dataSource = dataSource;

        setFrame(_barView, CGRectMake(0.0, 0.0, 24.0, 100.0));
    });
    
    it(@"hides the horizontal scroll indicators", ^{
        expect(_barView.showsHorizontalScrollIndicator).to.equal(NO);
    });
    
    it(@"has a default bar color", ^{
        expect(_barView.barColor).toNot.beNil();
    });
    
    it(@"has a default selection indicator color", ^{
        expect(_barView.selectionIndicatorColor).toNot.beNil();
    });
    
    it(@"reloads the data when a data source is set", ^{
        [verify(_barView.dataSource) numberOfBarsInBarView:_barView];
        expect([_barView numberOfBars]).to.equal(2);
    });
    
    it(@"requests the data source for the value of each bar", ^{
        [verify(_barView.dataSource) barView:_barView valueForBarAtIndex:0];
        [verify(_barView.dataSource) barView:_barView valueForBarAtIndex:1];
    });

    it(@"adds all bars to the bar container", ^{
        expect(_barView.barsContainerView.subviews.count).to.equal(2);
    });
    
    describe(@"index at point", ^{
        it(@"can determine the index of a bar at a certain point", ^{
            expect([_barView indexForBarAtPoint:CGPointMake(47.0, 0.0)]).to.equal(1);
        });
        
        it(@"never returns an index smaller than 0", ^{
            expect([_barView indexForBarAtPoint:CGPointMake(-50.0, 0.0)]).to.equal(0);
        });
        
        it(@"never returns an index higher than the number of bars", ^{
            expect([_barView indexForBarAtPoint:CGPointMake(1000.0, 0.0)]).to.equal(1);
        });
    });
    
    describe(@"visible range", ^{
        it(@"can determine the visible bars", ^{
            _barView.contentOffset = CGPointMake(46.0, 0.0);
            NSRange visibleRange = [_barView visibleRange];
            expect(visibleRange.location).to.equal(1);
            expect(visibleRange.length).to.equal(1);
        });
        
        it(@"never returns a range larger than the number of bars", ^{
            [given([_barView.dataSource numberOfBarsInBarView:_barView]) willReturnInteger:0];
            [_barView reloadData];
            NSRange visibleRange = [_barView visibleRange];
            expect(visibleRange.location).to.equal(0);
            expect(visibleRange.length).to.equal(0);
        });
    });
});

SpecEnd
