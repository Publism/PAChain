

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class ElectionListModel;
@interface BallotListModel : NSObject

@property (nonatomic,copy)NSString *ballotname;
@property (nonatomic,copy)NSString *ballotno;
@property (nonatomic,copy)NSString *ballotdate;
@property (nonatomic,copy)NSString *type;
@property (nonatomic,copy)NSString *userkey;
@property (nonatomic,copy)NSString *votingdate;
@property (nonatomic,assign)BOOL isconfirm;
@property (nonatomic,assign)BOOL isopenvoting;
@property (nonatomic,assign)BOOL isvoted;
@property (nonatomic,retain)NSArray <ElectionListModel *>*elections;

@end

NS_ASSUME_NONNULL_END
