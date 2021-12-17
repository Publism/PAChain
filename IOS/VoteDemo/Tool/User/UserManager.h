

#import <Foundation/Foundation.h>
@class UserInfo;
NS_ASSUME_NONNULL_BEGIN

@interface UserManager : NSObject


+ (BOOL)saveUserInfo:(NSDictionary *)dic;

+ (UserInfo *)userInfo;

+ (BOOL)updateUserInfoWithDictionary:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
