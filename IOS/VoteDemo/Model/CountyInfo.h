

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CountyInfo : NSObject
@property (nonatomic,assign)NSInteger ID;
@property (nonatomic,copy)NSString *code;
@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy)NSString *state;
@property (nonatomic,copy)NSString *urlCode;

+ (void)saveCountyInfo:(NSArray *)counties;
+ (NSArray *)getCountyArray;
+ (CountyInfo *)getCountyInfoWithName:(NSString *)name;
+ (NSArray *)getCountyInfoWithStateName:(NSString *)name;
+ (CountyInfo *)getCountyInfoWithCode:(NSString *)code;
@end

NS_ASSUME_NONNULL_END
