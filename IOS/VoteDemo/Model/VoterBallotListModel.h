

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VoterBallotListModel : NSObject
@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy)NSString *number;
@property (nonatomic,copy)NSString *electionDay;
@property (nonatomic,assign)BOOL HasVoted;
@end

NS_ASSUME_NONNULL_END
