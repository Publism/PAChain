

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VoterRegisterViewController : UIViewController
@property (nonatomic,copy)NSString *step;
@property (nonatomic,copy)void (^ ReturnBlock)(BOOL isBack);
@property (nonatomic,copy)void (^ ReturnFirstBlock)(NSInteger index,NSString *firstName,NSString *middleName,NSString *lastName,NSString *nameSuffix,NSString *number,NSString *emai,NSString *address,NSString *signature,NSString *state,NSString *county,NSString *precintNumber);
@property (nonatomic,copy)void (^ ReturnSecondBlock)(NSInteger index,NSString *backID,NSString *frontID);
@property (nonatomic,copy)void (^ ReturnThirdBlock)(NSInteger index,NSString *imageID,NSString *imageData);
@property (nonatomic,copy)void (^ ReturnForthBlock)(BOOL isRegister);

@property (nonatomic,copy)NSString *voterID;
@property (nonatomic,copy)NSString *state;

@property (nonatomic,retain)NSDictionary *requestDic;
@property (nonatomic,copy)NSString *userPhoto;
@end

NS_ASSUME_NONNULL_END
