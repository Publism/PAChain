//
//  ResultBallotViewController.h
//  VoteDemo
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class BallotListModel;
@interface ResultBallotViewController : UIViewController
@property (nonatomic,retain)BallotListModel *ballotModel;
@end

NS_ASSUME_NONNULL_END
