

#import "PrecinctInfo.h"

@implementation PrecinctInfo



+ (void)savePrecinctInfo:(NSArray *)precincts{
    [NSKeyedArchiver archiveRootObject:precincts toFile:[self pathWithTitle:@"precinct"]];
}

+(NSString *)pathWithTitle:(NSString *)title
{
    NSString *docDir    = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject];
    NSString *name = title;
    NSString *type = @"sql";
    
    NSString *allName = [NSString stringWithFormat:@"%@.%@",name,type];
    
    return [docDir stringByAppendingPathComponent:allName];;
}

+ (NSArray *)getPrecinctArray{
    NSArray *precinctArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathWithTitle:@"precinct"]];
    NSMutableArray *muarray = [[NSMutableArray alloc]init];
    if (precinctArray.count > 0) {
        for (NSDictionary *dic in precinctArray) {
            PrecinctInfo *model = [PrecinctInfo yy_modelWithDictionary:dic];
            [muarray addObject:model];
        }
    }
    return (NSArray *)muarray;
}

+ (NSArray *)getPrecinctInfoWithState:(NSString *)state withCounty:(NSString *)county{
    NSArray *precinctArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathWithTitle:@"precinct"]];
    NSMutableArray *sourceArray = [[NSMutableArray alloc]init];
    if (precinctArray.count > 0) {
        for (NSDictionary *dic in precinctArray) {
            NSString *stateStr = [NSString stringWithFormat:@"%@",dic[@"State"]];
            NSString *countyStr = [NSString stringWithFormat:@"%@",dic[@"CountyNumber"]];
            if ([state isEqualToString:stateStr] && [countyStr isEqualToString:county]) {
                PrecinctInfo *model = [PrecinctInfo yy_modelWithDictionary:dic];
                [sourceArray addObject:model];
            }
        }
    }
    return sourceArray;
}

+ (PrecinctInfo *)getPrecinctInfoWithPrecinctNumber:(NSString *)precinctNumber{
    NSArray *precinctArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathWithTitle:@"precinct"]];
    PrecinctInfo *info = [[PrecinctInfo alloc]init];
    if (precinctArray.count > 0) {
        for (NSDictionary *dic in precinctArray) {
            NSString *state = [NSString stringWithFormat:@"%@",dic[@"PrecinctNumber"]];
            if ([precinctNumber isEqualToString:state]) {
                PrecinctInfo *model = [PrecinctInfo yy_modelWithDictionary:dic];
                info = model;
                break;
            }
        }
    }
    return info;
}

@end
