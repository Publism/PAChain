//
//  VoteDemoHUD.m
//  VoteDemo


#import "VoteDemoHUD.h"

#define AnimationDISTANCE -100
#define LoadingWidth 50.0/375.0*FUll_VIEW_WIDTH

@implementation VoteDemoHUD

+ (void)setHUD:(NSString *)string{
    [self setHUD:string sleepTime:2];
   
}
+ (void)setHUD:(NSString *)string sleepTime:(NSInteger) sleepTime{
    MBProgressHUD * HUD = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
    [[UIApplication sharedApplication].keyWindow addSubview:HUD];
    if (string.length <= 0) {
        HUD.mode = MBProgressHUDModeIndeterminate;
    }else{
        HUD.detailsLabel.text =string;
        HUD.mode = MBProgressHUDModeText;
    }
    
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(sleepTime);
    } completionBlock:^{
        [HUD removeFromSuperview];
    }];
}

+ (void)showLoding{
    MBProgressHUD * HUD = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
    [[UIApplication sharedApplication].keyWindow addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    [HUD showAnimated:YES];
}

+ (void)hideLoding{
    for (MBProgressHUD *hud in [UIApplication sharedApplication].keyWindow.subviews) {
        if ([hud isKindOfClass:[MBProgressHUD class]]) {
            [hud hideAnimated:YES];
            [hud removeFromSuperview];
        }
    }
}

@end
