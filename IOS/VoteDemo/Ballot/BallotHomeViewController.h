

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class BallotListModel;
@interface BallotHomeViewController : UIViewController
@property (nonatomic,copy)NSString *type;
@property (nonatomic,retain)BallotListModel *ballotModel;
@property (nonatomic,assign)BOOL isSample;
@end

NS_ASSUME_NONNULL_END
