

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class ElectionModel;
@interface ConfirmVoteViewController : UIViewController
@property (nonatomic,retain)NSArray *votingData;
@property (nonatomic,copy)NSString *ballotNumber;
@property (nonatomic,retain)ElectionModel *eleModel;
@end

NS_ASSUME_NONNULL_END
