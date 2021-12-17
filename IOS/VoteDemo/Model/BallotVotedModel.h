
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BallotVotedModel : NSObject
@property (nonatomic,copy)NSString *county;
@property (nonatomic,copy)NSString *precinctNumber;
@property (nonatomic,copy)NSString *state;
@property (nonatomic,copy)NSString *votingDate;
@property (nonatomic,assign)NSInteger count;
@end

NS_ASSUME_NONNULL_END
