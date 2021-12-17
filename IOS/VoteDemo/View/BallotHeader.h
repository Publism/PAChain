

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class ElectionModel;
@class SeatListModel;
@interface BallotHeader : UITableViewHeaderFooterView
@property (nonatomic,retain)ElectionModel *model;
@property (nonatomic,retain)SeatListModel *seatModel;
@property (nonatomic,copy)NSString *verifyTipStr;
@property (nonatomic,assign)BOOL isConfirm;
@property (nonatomic,assign)BOOL isSample;
@property (nonatomic,strong) void(^viewProgress)(BOOL);
@property (nonatomic,assign)NSInteger section;
@end

NS_ASSUME_NONNULL_END
