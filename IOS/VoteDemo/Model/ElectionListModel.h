

#import <Foundation/Foundation.h>
@class ElectionModel;
@class SeatListModel;
NS_ASSUME_NONNULL_BEGIN

@interface ElectionListModel : NSObject
@property (nonatomic,strong)ElectionModel *election;
@property (nonatomic,retain)NSArray <SeatListModel *>*seats;
@end

NS_ASSUME_NONNULL_END
