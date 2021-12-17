

#import "XLSlideSwitch.h"
#import "XLSlideSegmented.h"

static const CGFloat SegmentHeight = 35.0f;

@interface XLSlideSwitch ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource,XLSlideSegmentDelegate,UIScrollViewDelegate> {
    
    XLSlideSegmented *_segment;
    
    UIPageViewController *_pageVC;
}
@end

@implementation XLSlideSwitch

- (instancetype)initWithFrame:(CGRect)frame Titles:(NSArray <NSString *>*)titles viewControllers:(NSArray <UIViewController *>*)viewControllers{
    if (self = [super initWithFrame:frame]) {
        [self buildUI];
        self.titles = titles;
        self.viewControllers = viewControllers;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame Titles:(NSArray <NSString *>*)titles viewControllers:(NSArray <UIViewController *>*)viewControllers withType:(NSInteger)type{
    if (self = [super initWithFrame:frame]) {
        _viewType = type;
        [self buildUI];
        self.titles = titles;
        self.viewControllers = viewControllers;
    }
    return self;
}

- (void)reloadTitleView{
    [_segment reloadTitleView];
}

- (void)buildUI {
    [self addSubview:[UIView new]];
    
    _pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    _pageVC.view.frame = CGRectMake(0, SegmentHeight, self.bounds.size.width, self.bounds.size.height - SegmentHeight);
    _pageVC.delegate = self;
    _pageVC.dataSource = self;
    [self addSubview:_pageVC.view];
    
    if (_viewType != 2) {
        _segment = [[XLSlideSegmented alloc] init];
        _segment.frame = CGRectMake(0, 0, self.bounds.size.width, SegmentHeight);
        _segment.viewType = _viewType;
        _segment.delegate = self;
        [self addSubview:_segment];
    }else{
        _pageVC.view.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    }
    
    for (UIScrollView *scrollView in _pageVC.view.subviews) {
        if ([scrollView isKindOfClass:[UIScrollView class]]) {
            scrollView.delegate = self;
            scrollView.bounces = NO;
        }
    }
}

- (void)showInViewController:(UIViewController *)viewController {
    [viewController addChildViewController:_pageVC];
    [viewController.view addSubview:self];
}

- (void)showInNavigationController:(UINavigationController *)navigationController {
    [navigationController.topViewController.view addSubview:self];
    [navigationController.topViewController addChildViewController:_pageVC];
    navigationController.topViewController.navigationItem.titleView = _segment;
    _pageVC.view.frame = self.bounds;
    _segment.showTitlesInNavBar = true;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [self switchToIndex:_selectedIndex];
}

#pragma mark -
#pragma mark Setter&Getter

- (void)setViewControllers:(NSArray *)viewControllers {
    _viewControllers = viewControllers;
}

- (void)setTitles:(NSArray *)titles {
    _titles = titles;
    _segment.titles = titles;
}

- (void)setItemSelectedColor:(UIColor *)itemSelectedColor {
    _segment.itemSelectedColor = itemSelectedColor;
}

- (void)setItemNormalColor:(UIColor *)itemNormalColor {
    _segment.itemNormalColor = itemNormalColor;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (selectedIndex >= _titles.count) {return;}
    _selectedIndex = selectedIndex;
    [self switchToIndex:_selectedIndex];
    _segment.selectedIndex = _selectedIndex;
    _segment.ignoreAnimation = true;
}

- (void)setHideShadow:(BOOL)hideShadow {
    _hideShadow = hideShadow;
    _segment.hideShadow = _hideShadow;
}

- (void)setHideBottomLine:(BOOL)hideBottomLine {
    _hideBottomLine = hideBottomLine;
    _segment.hideBottomLine = hideBottomLine;
}

- (void)setCustomTitleSpacing:(CGFloat)customTitleSpacing {
    _customTitleSpacing = customTitleSpacing;
    _segment.customTitleSpacing = customTitleSpacing;
}

- (void)setMoreButton:(UIButton *)moreButton {
    _segment.moreButton = moreButton;
}

#pragma mark -
#pragma mark SlideSegmentDelegate

- (void)slideSegmentDidSelectedAtIndex:(NSInteger)index {
    if (index == _selectedIndex) {return;}
    [self switchToIndex:index];
}

#pragma mark -
#pragma mark UIPageViewControllerDelegate&DataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    UIViewController *vc;
    if (_selectedIndex + 1 < _viewControllers.count) {
        vc = _viewControllers[_selectedIndex + 1];
        vc.view.bounds = pageViewController.view.bounds;
    }
    return vc;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    UIViewController *vc;
    if (_selectedIndex - 1 >= 0) {
        vc = _viewControllers[_selectedIndex - 1];
        vc.view.bounds = pageViewController.view.bounds;
    }
    return vc;
}


- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    _selectedIndex = [_viewControllers indexOfObject:pageViewController.viewControllers.firstObject];
    _segment.selectedIndex = _selectedIndex;
    [self performSwitchDelegateMethod];
}

- (UIInterfaceOrientation)pageViewControllerPreferredInterfaceOrientationForPresentation:(UIPageViewController *)pageViewController NS_AVAILABLE_IOS(7_0) __TVOS_PROHIBITED {
    return UIInterfaceOrientationPortrait;
}

#pragma mark -
#pragma mark ScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x == scrollView.bounds.size.width) {return;}
    CGFloat progress = scrollView.contentOffset.x/scrollView.bounds.size.width;
    _segment.progress = progress;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    _segment.ignoreAnimation = false;
}

#pragma mark - Method

- (void)switchToIndex:(NSInteger)index {
    __weak __typeof(self)weekSelf = self;
    [_pageVC setViewControllers:@[_viewControllers[index]] direction:index<_selectedIndex animated:NO completion:^(BOOL finished) {
        _selectedIndex = index;
        [weekSelf performSwitchDelegateMethod];
    }];
}

- (void)performSwitchDelegateMethod {
    if ([_delegate respondsToSelector:@selector(slideSwitchDidselectAtIndex:)]) {
        [_delegate slideSwitchDidselectAtIndex:_selectedIndex];
    }
}

@end
