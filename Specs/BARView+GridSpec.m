#import "SpecHelper.h"

#import "BARView.h"

SpecBegin(BARView_Grid)

__block BARView *_view;

describe(@"BARView+Grid", ^{
    before(^{
        _view = [[BARView alloc] init];
    });
    
    it(@"has a grid color", ^{
        expect(_view.gridColor).toNot.beNil();
    });
});

SpecEnd
