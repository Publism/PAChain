

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SeatModel : NSObject
@property (nonatomic,assign)NSInteger level;
@property (nonatomic,assign)NSInteger seatid;
@property (nonatomic,copy)NSString *city;
@property (nonatomic,copy)NSString *county;
@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy)NSString *number;
@property (nonatomic,copy)NSString *office;
@property (nonatomic,copy)NSString *state;
@property (nonatomic,copy)NSString *type;
@property (nonatomic,retain)NSArray *candidateids;
@end

NS_ASSUME_NONNULL_END
