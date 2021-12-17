

#import <UIKit/UIKit.h>
#import "XLSlideSwitchDelegate.h"

@interface XLSlideSwitch : UIView

/**
 * Set the presentation style according to the type
 * 2.Voter Register
 */
@property (nonatomic, assign) NSInteger viewType;

/**
 * The view that needs to be displayed
 */
@property (nonatomic, strong) NSArray *viewControllers;

@property (nonatomic, strong) NSArray *titles;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, strong) UIColor *itemNormalColor;

@property (nonatomic, strong) UIColor *itemSelectedColor;

@property (nonatomic, assign) BOOL hideShadow;

@property (nonatomic, assign) BOOL hideBottomLine;

@property (nonatomic, assign) CGFloat customTitleSpacing;

@property (nonatomic, strong) UIButton *moreButton;

@property (nonatomic, weak) id <XLSlideSwitchDelegate>delegate;

-(instancetype)initWithFrame:(CGRect)frame Titles:(NSArray <NSString *>*)titles viewControllers:(NSArray <UIViewController *>*)viewControllers;

- (instancetype)initWithFrame:(CGRect)frame Titles:(NSArray <NSString *>*)titles viewControllers:(NSArray <UIViewController *>*)viewControllers withType:(NSInteger)type;

-(void)showInViewController:(UIViewController *)viewController;

-(void)showInNavigationController:(UINavigationController *)navigationController;

-(void)reloadTitleView;

@end
