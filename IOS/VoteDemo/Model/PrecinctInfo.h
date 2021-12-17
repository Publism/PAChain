

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PrecinctInfo : NSObject
@property (nonatomic,copy)NSString *PrecinctNumber;
@property (nonatomic,copy)NSString *StateNumber;
@property (nonatomic,copy)NSString *Precinct;
@property (nonatomic,copy)NSString *State;
@property (nonatomic,copy)NSString *CountyNumber;
@property (nonatomic,copy)NSString *County;

+ (void)savePrecinctInfo:(NSArray *)precincts;
+ (NSArray *)getPrecinctArray;
+ (PrecinctInfo *)getPrecinctInfoWithPrecinctNumber:(NSString *)precinctNumber;
+ (NSArray *)getPrecinctInfoWithState:(NSString *)state withCounty:(NSString *)county;
@end

NS_ASSUME_NONNULL_END
