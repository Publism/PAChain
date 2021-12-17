

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VoteDataModel : NSObject
@property (nonatomic,assign)NSInteger candidateID;
@property (nonatomic,assign)NSInteger count;
@property (nonatomic,assign)NSInteger electionID;
@property (nonatomic,assign)NSInteger seatID;
@property (nonatomic,copy)NSString *percent;
@end

NS_ASSUME_NONNULL_END
