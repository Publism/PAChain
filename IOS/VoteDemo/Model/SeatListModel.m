

#import "SeatListModel.h"

@implementation SeatListModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"candidates" : [CandidateModel class]};
}
@end
