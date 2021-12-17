

#import <UIKit/UIKit.h>

@interface DropdownListItem : NSObject
@property (nonatomic, copy, readonly) NSString *itemId;
@property (nonatomic, copy, readonly) NSString *itemName;

- (instancetype)initWithItem:(NSString*)itemId itemName:(NSString*)itemName NS_DESIGNATED_INITIALIZER;
@end


@class DropListView;

typedef void (^DropdownListViewSelectedBlock)(DropListView *dropdownListView);

@interface DropListView : UIView

// default is blackColor
@property (nonatomic, strong) UIColor *textColor;
// default is 14
@property (nonatomic, strong) UIFont *font;

@property (nonatomic, strong) NSArray *dataSource;
// The first one is selected by default
@property (nonatomic, assign) NSUInteger selectedIndex;

@property (nonatomic, strong, readonly) DropdownListItem *selectedItem;


- (instancetype)initWithDataSource:(NSArray*)dataSource;

- (void)setViewBorder:(CGFloat)width borderColor:(UIColor*)borderColor cornerRadius:(CGFloat)cornerRadius;

- (void)setDropdownListViewSelectedBlock:(DropdownListViewSelectedBlock)block;

@end
