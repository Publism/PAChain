

#import <Foundation/Foundation.h>
@class CandidateModel;
@class SeatModel;
NS_ASSUME_NONNULL_BEGIN

@interface SeatListModel : NSObject
@property (nonatomic,retain)NSArray <CandidateModel *>*candidates;
@property (nonatomic,strong)SeatModel *seat;
@end

NS_ASSUME_NONNULL_END
