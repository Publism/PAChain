//
//  VoteDemoHUD.h
//  VoteDemo


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VoteDemoHUD : UIView
+ (void)showLoding;

+ (void)hideLoding;

+ (void)setHUD:(NSString *)string;

+ (void)setHUD:(NSString *)string sleepTime:(NSInteger) sleepTime;
@end

NS_ASSUME_NONNULL_END
