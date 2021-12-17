

#import "RegisterLinkModel.h"

@implementation RegisterLinkModel

+ (NSArray *)getRegisterLinkArray{
    NSArray *precinctArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathWithTitle:@"registerlink"]];
    NSMutableArray *muarray = [[NSMutableArray alloc]init];
    if (precinctArray.count > 0) {
        for (NSDictionary *dic in precinctArray) {
            RegisterLinkModel *model = [RegisterLinkModel yy_modelWithDictionary:dic];
            [muarray addObject:model];
        }
    }
    return (NSArray *)muarray;
}

+ (void)saveRegisterLinkInfo:(NSArray *)registerLink{
    [NSKeyedArchiver archiveRootObject:registerLink toFile:[self pathWithTitle:@"registerlink"]];
}

+(NSString *)pathWithTitle:(NSString *)title
{
    NSString *docDir    = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject];
    NSString *name = title;
    NSString *type = @"sql";
    
    NSString *allName = [NSString stringWithFormat:@"%@.%@",name,type];
    
    return [docDir stringByAppendingPathComponent:allName];;
}

+ (RegisterLinkModel *)getRegisterLinkWithState:(NSString *)state withCounty:(NSString *)countyNumber{
    NSArray *linkArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathWithTitle:@"registerlink"]];
    RegisterLinkModel *info = [[RegisterLinkModel alloc]init];
    if (linkArray.count > 0) {
        for (NSDictionary *dic in linkArray) {
            NSString *stateStr = [NSString stringWithFormat:@"%@",dic[@"State"]];
            NSString *countyStr = [NSString stringWithFormat:@"%@",dic[@"CountyNumber"]];
            if (countyStr.length<5) {
                countyStr = [NSString stringWithFormat:@"0%@",countyStr];
            }
            if ([stateStr isEqualToString:state] && [countyNumber isEqualToString:countyStr]) {
                RegisterLinkModel *model = [RegisterLinkModel yy_modelWithDictionary:dic];
                info = model;
                break;
            }
        }
    }
    return info;
}

@end
