//


#import <UIKit/UIKit.h>

@protocol XLSlideSegmentDelegate <NSObject>

- (void)slideSegmentDidSelectedAtIndex:(NSInteger)index;

@end

@interface XLSlideSegmented : UIView

@property (nonatomic, assign) NSInteger viewType;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, strong) NSArray *titles;

@property (nonatomic, strong) UIColor *itemNormalColor;

@property (nonatomic, strong) UIColor *itemSelectedColor;

@property (nonatomic, assign) BOOL showTitlesInNavBar;

@property (nonatomic, assign) BOOL hideShadow;

@property (nonatomic, assign) BOOL hideBottomLine;

@property (nonatomic, weak) id<XLSlideSegmentDelegate>delegate;

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, assign) BOOL ignoreAnimation;

@property (nonatomic, assign) CGFloat customTitleSpacing;

@property (nonatomic, strong) UIButton *moreButton;

-(void)reloadTitleView;

@end
