

#import "XLSlideSegmentedItem.h"

@implementation XLSlideSegmentedItem

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    _textLabel = [[UILabel alloc] init];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_textLabel];
    
    _indirect = [[UILabel alloc]init];
    [_textLabel addSubview:_indirect];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _textLabel.frame = self.bounds;
    _indirect.frame = CGRectMake(_textLabel.width/2-10, _textLabel.height-YHEIGHT_SCALE(4), 20, YHEIGHT_SCALE(4));
}

@end
