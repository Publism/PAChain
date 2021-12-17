

#import "BallotListModel.h"

@implementation BallotListModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"elections" : [ElectionListModel class]};
}
@end
