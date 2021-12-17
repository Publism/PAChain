

#import <UIKit/UIKit.h>

@protocol  PopSignatureViewDelegate <NSObject>

- (void)onSubmitBtn:(UIImage*)signatureImg;

@end

@interface PopSignatureView : UIView

@property (nonatomic, assign) id<PopSignatureViewDelegate> delegate;

- (void)show;

- (void)hide;

@end
