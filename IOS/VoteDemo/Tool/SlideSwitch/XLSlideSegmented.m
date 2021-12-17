

#import "XLSlideSegmented.h"
#import "XLSlideSegmentedItem.h"

static const CGFloat ItemMargin = 0.0f;
static const CGFloat ItemFontSize = 14.0f;
static const CGFloat ItemMaxScale = 1.1;

@interface XLSlideSegmented ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    UICollectionView *_collectionView;
    UIView *_bottomLine;
    UIView *_shadow;
    NSMutableArray *itemWidthArray;
}
@end

@implementation XLSlideSegmented

- (instancetype)init {
    if (self = [super init]) {
        [self buildUI];
    }
    return self;
}

- (void)reloadTitleView{
    [_collectionView reloadData];
}

- (void)buildUI {
    
//    self.backgroundColor = [UIColor colorWithRed:247.0f/255.0f green:246.0f/255.0f blue:245.0f/255.0f alpha:1];
    itemWidthArray = [[NSMutableArray alloc]init];
    [self addSubview:[UIView new]];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, ItemMargin, 0, ItemMargin);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, FUll_VIEW_WIDTH, 35) collectionViewLayout:layout];
    _collectionView.bounces = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerClass:[XLSlideSegmentedItem class] forCellWithReuseIdentifier:@"XLSlideSegmentedItem"];
    _collectionView.showsHorizontalScrollIndicator = false;
    [self addSubview:_collectionView];
    
    _shadow = [[UIView alloc] init];
    [_collectionView addSubview:_shadow];
    
    _bottomLine = [UIView new];
    _bottomLine.backgroundColor = [UIColor clearColor];
    [self addSubview:_bottomLine];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_moreButton) {
        CGFloat buttonWidth = self.bounds.size.height;
        CGFloat collectinWidth = self.bounds.size.width - buttonWidth;
        _moreButton.frame = CGRectMake(collectinWidth, 0, buttonWidth, buttonWidth);
        _collectionView.frame = CGRectMake(0, 0, collectinWidth, self.bounds.size.height);
    }else{
        _collectionView.frame = self.bounds;
    }
    
    [_collectionView performBatchUpdates:nil completion:^(BOOL finished) {
        if (_collectionView.contentSize.width < _collectionView.bounds.size.width) {
            CGFloat insetX = (_collectionView.bounds.size.width - _collectionView.contentSize.width)/2.0f;
            _collectionView.contentInset = UIEdgeInsetsMake(0, insetX, 0, insetX);
        }
    }];
    
    _shadow.backgroundColor = _itemSelectedColor;
    self.selectedIndex = _selectedIndex;
    _shadow.hidden = _hideShadow;
//    _bottomLine.frame = CGRectMake(0, self.bounds.size.height - 0.5, self.bounds.size.width, 0.5);
    _bottomLine.hidden = _hideBottomLine;
}

#pragma mark -
#pragma mark Setter
- (void)setSelectedIndex:(NSInteger)selectedIndex {
    
    _selectedIndex = selectedIndex;
    
    CGFloat rectX = [self shadowRectOfIndex:_selectedIndex].origin.x;
    if (rectX <= 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            _shadow.frame = [self shadowRectOfIndex:_selectedIndex];
        });
    }else{
        _shadow.frame = [self shadowRectOfIndex:_selectedIndex];
    }
    
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:true];
    
    [_collectionView reloadData];
    
    if ([_delegate respondsToSelector:@selector(slideSegmentDidSelectedAtIndex:)]) {
        [_delegate slideSegmentDidSelectedAtIndex:_selectedIndex];
    }
}

- (void)setShowTitlesInNavBar:(BOOL)showTitlesInNavBar {
    _showTitlesInNavBar = showTitlesInNavBar;
    self.backgroundColor = [UIColor clearColor];
    _hideBottomLine = true;
    _hideShadow = true;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    if (_ignoreAnimation) {return;}
    [self updateShadowPosition:progress];
    [self updateItem:progress];
}

- (void)setCustomTitleSpacing:(CGFloat)customTitleSpacing {
    _customTitleSpacing = customTitleSpacing;
    [_collectionView reloadData];

}

- (void)setMoreButton:(UIButton *)moreButton {
    _moreButton = moreButton;
    [self addSubview:moreButton];
}

#pragma mark Perform a shadow transition animation

- (void)updateShadowPosition:(CGFloat)progress {
    
    NSInteger nextIndex = progress > 1 ? _selectedIndex + 1 : _selectedIndex - 1;
    if (nextIndex < 0 || nextIndex == _titles.count) {return;}
    CGRect currentRect = [self shadowRectOfIndex:_selectedIndex];
    CGRect nextRect = [self shadowRectOfIndex:nextIndex];
    if (CGRectGetMinX(currentRect) <= 0 || CGRectGetMinX(nextRect) <= 0) {return;}
    
    progress = progress > 1 ? progress - 1 : 1 - progress;
    
    CGFloat distance = CGRectGetMidX(nextRect) - CGRectGetMidX(currentRect);
    _shadow.center = CGPointMake(CGRectGetMidX(currentRect) + progress* distance, _shadow.center.y);
}

- (void)updateItem:(CGFloat)progress {
    
}

#pragma mark CollectionViewDelegate

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (_customTitleSpacing) {
        return _customTitleSpacing;
    }
    return ItemMargin;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (_customTitleSpacing) {
        return _customTitleSpacing;
    }
    return ItemMargin;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _titles.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_viewType == 1) {
        if (itemWidthArray.count > indexPath.row) {
            return CGSizeMake([itemWidthArray[indexPath.row] integerValue], 35);
        }else{
            NSMutableArray *widthArray = [[NSMutableArray alloc]init];
            CGFloat totalWidth = 0;
            for (NSString *title in _titles) {
                NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin |
                NSStringDrawingUsesFontLeading;
                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                [style setLineBreakMode:NSLineBreakByTruncatingTail];
                NSDictionary *attributes = @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:ItemFontSize], NSParagraphStyleAttributeName : style };
                CGSize textSize = [title boundingRectWithSize:CGSizeMake(self.bounds.size.width, self.bounds.size.height)
                                                      options:opts
                                                   attributes:attributes
                                                      context:nil].size;
                totalWidth = totalWidth + textSize.width;
                [widthArray addObject:@(textSize.width)];
            }
            NSString *width = widthArray[indexPath.row];
            [itemWidthArray addObject:@([width integerValue]+(FUll_VIEW_WIDTH-totalWidth)/6)];
            return CGSizeMake([width integerValue]+(FUll_VIEW_WIDTH-totalWidth)/6, _collectionView.bounds.size.height);
        }
        
    }else{
        NSMutableArray *widthArray = [[NSMutableArray alloc]init];
        for (NSString *title in _titles) {
            NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin |
            NSStringDrawingUsesFontLeading;
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            [style setLineBreakMode:NSLineBreakByTruncatingTail];
            NSDictionary *attributes = @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:ItemFontSize], NSParagraphStyleAttributeName : style };
            CGSize textSize = [title boundingRectWithSize:CGSizeMake(self.bounds.size.width, self.bounds.size.height)
                                                  options:opts
                                               attributes:attributes
                                                  context:nil].size;
            [widthArray addObject:@(textSize.width)];
        }
        CGFloat totalWith = 0;
        for (NSString *width in widthArray) {
            totalWith = totalWith +[width integerValue];
        }
        CGFloat a = 0;
        if (widthArray.count > 0) {
            a = [[widthArray objectAtIndex:0] floatValue];
        }
        CGFloat b = 0;
        if (widthArray.count > 1) {
            b = [[widthArray objectAtIndex:1] floatValue];
        }
        CGFloat c = 0;
        if (widthArray.count > 2) {
            c = [[widthArray objectAtIndex:2] floatValue];
        }
        CGFloat d = 0;
        if (widthArray.count > 3) {
            d = [[widthArray objectAtIndex:3] floatValue];
        }
        CGFloat e = a+b+c+d;
        if (e > [UIScreen mainScreen].bounds.size.width) {
            return CGSizeMake([self itemWidthOfIndexPath:indexPath]+20, _collectionView.bounds.size.height);
        }else{
            return CGSizeMake([self itemWidthOfIndexPath:indexPath]+([UIScreen mainScreen].bounds.size.width-_titles.count-1-e)/_titles.count, _collectionView.bounds.size.height);
        }
        return CGSizeMake([self itemWidthOfIndexPath:indexPath]+([UIScreen mainScreen].bounds.size.width-_titles.count-1-e)/_titles.count, _collectionView.bounds.size.height);
    }
   
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XLSlideSegmentedItem *item = [collectionView dequeueReusableCellWithReuseIdentifier:@"XLSlideSegmentedItem" forIndexPath:indexPath];
    
    if (_viewType == 1) {
        item.textLabel.text = _titles[indexPath.row];
        item.backgroundColor = [UIColor whiteColor];
        if (self.selectedIndex == indexPath.row) {
            item.indirect.backgroundColor = HexRGBAlpha(0x0090ff, 1);
            item.textLabel.textColor =  [UIColor blackColor];
        }else{
            item.indirect.backgroundColor = [UIColor clearColor];
            item.textLabel.textColor =  [UIColor lightGrayColor];
        }
        item.textLabel.font = [UIFont systemFontOfSize:ItemFontSize];
    }else{
        item.textLabel.text = _titles[indexPath.row];
        item.textLabel.font = [UIFont boldSystemFontOfSize:ItemFontSize];
        if (self.selectedIndex == indexPath.row) {
            item.textLabel.backgroundColor = HexRGBAlpha(0xff8519, 1);;
        }else{
            item.textLabel.backgroundColor = HexRGBAlpha(0x0090ff, 1);
        }
        item.textLabel.textColor =  HexRGBAlpha(0xffffff, 1);
        CGFloat scale = indexPath.row == _selectedIndex ? ItemMaxScale : 1;
        item.transform = CGAffineTransformMakeScale(scale, scale);
    }
    return item;
}

- (CGFloat)itemWidthOfIndexPath:(NSIndexPath*)indexPath {
    NSString *title = _titles[indexPath.row];
    NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin |
    NSStringDrawingUsesFontLeading;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByTruncatingTail];
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:ItemFontSize], NSParagraphStyleAttributeName : style };
    CGSize textSize = [title boundingRectWithSize:CGSizeMake(self.bounds.size.width, self.bounds.size.height)
                                          options:opts
                                       attributes:attributes
                                          context:nil].size;
    return textSize.width;
}


- (CGRect)shadowRectOfIndex:(NSInteger)index {
    return CGRectMake([_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]].frame.origin.x, self.bounds.size.height - 2, [self itemWidthOfIndexPath:[NSIndexPath indexPathForRow:index inSection:0]], 2);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath.row;
    _ignoreAnimation = true;
}

#pragma mark - Method
- (UIColor *)transformFromColor:(UIColor*)fromColor toColor:(UIColor *)toColor progress:(CGFloat)progress {
    
    if (!fromColor || !toColor) {
        NSLog(@"Warning !!! color is nil");
        return [UIColor blackColor];
    }
    
    progress = progress >= 1 ? 1 : progress;
    
    progress = progress <= 0 ? 0 : progress;
    
    const CGFloat * fromeComponents = CGColorGetComponents(fromColor.CGColor);

    const CGFloat * toComponents = CGColorGetComponents(toColor.CGColor);
    
    size_t  fromColorNumber = CGColorGetNumberOfComponents(fromColor.CGColor);
    size_t  toColorNumber = CGColorGetNumberOfComponents(toColor.CGColor);
    
    if (fromColorNumber == 2) {
        CGFloat white = fromeComponents[0];
        fromColor = [UIColor colorWithRed:white green:white blue:white alpha:1];
        fromeComponents = CGColorGetComponents(fromColor.CGColor);
    }
    
    if (toColorNumber == 2) {
        CGFloat white = toComponents[0];
        toColor = [UIColor colorWithRed:white green:white blue:white alpha:1];
        toComponents = CGColorGetComponents(toColor.CGColor);
    }
    
    CGFloat red = fromeComponents[0]*(1 - progress) + toComponents[0]*progress;
    CGFloat green = fromeComponents[1]*(1 - progress) + toComponents[1]*progress;
    CGFloat blue = fromeComponents[2]*(1 - progress) + toComponents[2]*progress;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}


@end
