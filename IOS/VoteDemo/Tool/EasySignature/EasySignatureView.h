//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol SignatureViewDelegate <NSObject>

@optional -(void)getSignatureImg:(UIImage*)image;

@optional -(void)onSignatureWriteAction;

@end

@interface EasySignatureView : UIView {
    CGFloat min;
    CGFloat max;
    CGRect origRect;
    CGFloat origionX;
    CGFloat totalWidth;
    BOOL  isSure;
}


@property (strong,nonatomic) NSString *showMessage;
@property(nonatomic,assign)id<SignatureViewDelegate> delegate;
@property (nonatomic, strong)UIImage *SignatureImg;
@property (nonatomic, strong)NSMutableArray *currentPointArr;
@property (nonatomic, assign) BOOL hasSignatureImg;

- (void)clear;

- (void)sure;

@end
