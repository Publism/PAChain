

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StateInfo : NSObject
@property (nonatomic,assign)NSInteger ID;
@property (nonatomic,copy)NSString *code;
@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy)NSString *shortName;

+ (void)saveStateInfo:(NSArray *)states;
+ (NSArray *)getStateArray;
+ (StateInfo *)getStateInfoWithStateID:(NSString *)StateID;
+ (StateInfo *)getStateInfoWithName:(NSString *)name;
+ (StateInfo *)getStateInfoWithShortName:(NSString *)stateName;
@end

NS_ASSUME_NONNULL_END
