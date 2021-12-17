

#import "ElectionListModel.h"

@implementation ElectionListModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"seats" : [SeatListModel class]};
}
@end
