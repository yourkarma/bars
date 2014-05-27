#import "SpecHelper.h"

#import "BARView.h"

@interface FakeDataSource : NSObject <BARViewDataSource>
@end
@implementation FakeDataSource

- (NSUInteger)numberOfBarsInBarView:(BARView *)barView;
{
    return 2;
}

- (CGFloat)barView:(BARView *)barView valueForBarAtIndex:(NSUInteger)index;
{
    return index;
}

@end

SpecBegin(BARViewAxisSpec)

describe(@"BARViewAxis", ^{
    __block BARView *_barView;
    
    before(^{
        _barView = [[BARView alloc] initWithFrame:CGRectZero];
        
        id<BARViewDataSource> dataSource = mockProtocol(@protocol(BARViewDataSource));
        [given([dataSource numberOfBarsInBarView:_barView]) willReturnInteger:2];
        [given([dataSource barView:_barView valueForBarAtIndex:0]) willReturnDouble:49.0];
        [given([dataSource barView:_barView valueForBarAtIndex:1]) willReturnDouble:200.0];

        _barView.dataSource = dataSource;
    });
    
    describe(@"data source with labels", ^{
        before(^{
            UILabel *label1 = [[UILabel alloc] init];
            label1.text = @"1/1";
            [given([_barView.dataSource barView:_barView labelViewForBarAtIndex:0]) willReturn:label1];
            setFrame(_barView, CGRectMake(0.0, 0.0, 24.0, 100.0));
        });
        
        it(@"asks the data source for the view for each axis label", ^{
            _barView.contentOffset = CGPointMake(-kBarViewDefaultBarWidth, 0.0);
            [_barView layoutSubviews];
            [verify(_barView.dataSource) barView:_barView labelViewForBarAtIndex:-1];
            [verify(_barView.dataSource) barView:_barView labelViewForBarAtIndex:0];
        });
        
        it(@"adds axis label to the axis view", ^{
            expect(_barView.axisContainerView.subviews.count).to.equal(1);
        });
    });
    
    it(@"does not ask for labels if data source does not implement the method", ^{
        id<BARViewDataSource> dataSource = [[FakeDataSource alloc] init];
        _barView.dataSource = dataSource;
        
        expect(^{
            [_barView labelViewForBarAtIndex:0];
        }).toNot.raise(NSInvalidArgumentException);
    });
});

SpecEnd