

#import "StateInfo.h"

@implementation StateInfo

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"ID":@"id"};
}

+ (void)saveStateInfo:(NSArray *)states{
    [NSKeyedArchiver archiveRootObject:states toFile:[self pathWithTitle:@"state"]];
}

+ (NSArray *)getStateArray{
    NSArray *stateArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathWithTitle:@"state"]];
    NSMutableArray *muarray = [[NSMutableArray alloc]init];
    if (stateArray.count > 0) {
        for (NSDictionary *dic in stateArray) {
            StateInfo *model = [StateInfo yy_modelWithDictionary:dic];
            [muarray addObject:model];
        }
    }
    return (NSArray *)muarray;
}

+ (StateInfo *)getStateInfoWithStateID:(NSString *)StateID{
    NSArray *stateArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathWithTitle:@"state"]];
    StateInfo *info = [[StateInfo alloc]init];
    if (stateArray.count > 0) {
        for (NSDictionary *dic in stateArray) {
            NSString *state = [NSString stringWithFormat:@"%@",dic[@"code"]];
            if ([StateID isEqualToString:state]) {
                StateInfo *model = [StateInfo yy_modelWithDictionary:dic];
                info = model;
                break;
            }
        }
    }
    return info;
}

+ (StateInfo *)getStateInfoWithShortName:(NSString *)stateName{
    NSArray *stateArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathWithTitle:@"state"]];
    StateInfo *info = [[StateInfo alloc]init];
    if (stateArray.count > 0) {
        for (NSDictionary *dic in stateArray) {
            NSString *state = [NSString stringWithFormat:@"%@",dic[@"shortName"]];
            if ([stateName isEqualToString:state]) {
                StateInfo *model = [StateInfo yy_modelWithDictionary:dic];
                info = model;
                break;
            }
        }
    }
    return info;
}

+ (StateInfo *)getStateInfoWithName:(NSString *)name{
    NSArray *stateArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathWithTitle:@"state"]];
    StateInfo *info = [[StateInfo alloc]init];
    if (stateArray.count > 0) {
        for (NSDictionary *dic in stateArray) {
            NSString *state = [NSString stringWithFormat:@"%@",dic[@"name"]];
            if ([name isEqualToString:state]) {
                StateInfo *model = [StateInfo yy_modelWithDictionary:dic];
                info = model;
                break;
            }
        }
    }
    return info;
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
