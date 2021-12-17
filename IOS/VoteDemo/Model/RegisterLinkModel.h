

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RegisterLinkModel : NSObject
@property (nonatomic,copy)NSString *ID;
@property (nonatomic,copy)NSString *County;
@property (nonatomic,copy)NSString *CountyNumber;
@property (nonatomic,copy)NSString *Officials;
@property (nonatomic,copy)NSString *RegisterLink;
@property (nonatomic,copy)NSString *SOELink;
@property (nonatomic,copy)NSString *AK;
+ (NSArray *)getRegisterLinkArray;
+ (void)saveRegisterLinkInfo:(NSArray *)registerLink;
+ (RegisterLinkModel *)getRegisterLinkWithState:(NSString *)state withCounty:(NSString *)county;
@end

NS_ASSUME_NONNULL_END
