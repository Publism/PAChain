

#import "CountyInfo.h"

@implementation CountyInfo

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"ID":@"id"};
}

+ (void)saveCountyInfo:(NSArray *)counties{
    [NSKeyedArchiver archiveRootObject:counties toFile:[self pathWithTitle:@"county"]];
}
+ (NSArray *)getCountyArray{
    NSArray *stateArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathWithTitle:@"county"]];
    NSMutableArray *muarray = [[NSMutableArray alloc]init];
    if (stateArray.count > 0) {
        for (NSDictionary *dic in stateArray) {
            CountyInfo *model = [CountyInfo yy_modelWithDictionary:dic];
            [muarray addObject:model];
        }
    }
    return (NSArray *)muarray;
}
+ (CountyInfo *)getCountyInfoWithName:(NSString *)name{
    NSArray *stateArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathWithTitle:@"county"]];
    CountyInfo *info = [[CountyInfo alloc]init];
    if (stateArray.count > 0) {
        for (NSDictionary *dic in stateArray) {
            NSString *state = [NSString stringWithFormat:@"%@",dic[@"name"]];
            if ([name isEqualToString:state]) {
                CountyInfo *model = [CountyInfo yy_modelWithDictionary:dic];
                info = model;
                break;
            }
        }
    }
    return info;
}

+ (CountyInfo *)getCountyInfoWithCode:(NSString *)code{
    NSArray *stateArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathWithTitle:@"county"]];
    CountyInfo *info = [[CountyInfo alloc]init];
    if (stateArray.count > 0) {
        for (NSDictionary *dic in stateArray) {
            NSString *state = [NSString stringWithFormat:@"%@",dic[@"code"]];
            if ([code isEqualToString:state]) {
                CountyInfo *model = [CountyInfo yy_modelWithDictionary:dic];
                info = model;
                break;
            }
        }
    }
    return info;
}

+ (NSArray *)getCountyInfoWithStateName:(NSString *)name{
    NSArray *stateArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathWithTitle:@"county"]];
    NSMutableArray *muarray = [[NSMutableArray alloc]init];
    if (stateArray.count > 0) {
        for (NSDictionary *dic in stateArray) {
            CountyInfo *model = [CountyInfo yy_modelWithDictionary:dic];
            if ([model.state isEqualToString:name]) {
                [muarray addObject:model];
            }
        }
    }
    return (NSArray *)muarray;
}

+(NSString *)pathWithTitle:(NSString *)title
{
    NSString *docDir    = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject];
    NSString *name = title;
    NSString *type = @"sql";
    
    NSString *allName = [NSString stringWithFormat:@"%@.%@",name,type];
    
    return [docDir stringByAppendingPathComponent:allName];;
}


@end
