//
//  BallotResultModel.h
//  VoteDemo
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class CandidateModel;
@class SeatModel;
@interface BallotResultModel : NSObject
@property (nonatomic,retain)NSArray <CandidateModel *>*candidates;
@property (nonatomic,strong)SeatModel *seat;
@end

NS_ASSUME_NONNULL_END
