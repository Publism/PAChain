

#import <UIKit/UIKit.h>
#import "XLSlideSwitchDelegate.h"

@interface XLSegmentedSlideSwitch : UIView
/**
 * ViewController
 */
@property (nonatomic, strong) NSArray *viewControllers;
/**
 * title
 */
@property (nonatomic, strong) NSArray *titles;
/**
 * selectedIndex
 */
@property (nonatomic, assign) NSInteger selectedIndex;
/**
 * Segmented selectedIndex
 */
@property (nonatomic, strong) UIColor *tintColor;
/**
 * segment horizontalInset
 */
@property (nonatomic, assign) NSInteger horizontalInset;

@property (nonatomic, weak) id <XLSlideSwitchDelegate>delegate;

-(instancetype)initWithFrame:(CGRect)frame Titles:(NSArray <NSString *>*)titles viewControllers:(NSArray <UIViewController *>*)viewControllers;
/**
 * The title is displayed in the ViewController
 */
-(void)showInViewController:(UIViewController *)viewController;
/**
 * The title is displayed in the NavigationBar
 */
-(void)showInNavigationController:(UINavigationController *)navigationController;
@end
