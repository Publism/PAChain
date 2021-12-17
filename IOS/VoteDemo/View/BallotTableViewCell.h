

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class CandidateModel;
@class BallotTableViewCell;
@protocol BallotCellDelegate <NSObject>
- (void)voteClick:(BallotTableViewCell *)cell withModel:(CandidateModel *)model;
@end
@interface BallotTableViewCell : UITableViewCell
@property (nonatomic,copy)NSString *voteJSON;
@property (nonatomic,retain)CandidateModel *model;
@property (nonatomic,assign)BOOL showSelect;
@property (nonatomic,weak) id<BallotCellDelegate>delegate;
@property (nonatomic,retain)NSDictionary *saveDic;
@end

NS_ASSUME_NONNULL_END
