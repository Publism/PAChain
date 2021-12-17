

#import "UserInfo.h"

#import "UserManager.h"

@implementation UserInfo
- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary isKindOfClass:[NSDictionary class]])
    {
        if (self = [super init])
        {
            [self setValuesForKeysWithDictionary:dictionary];
        }
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([value isKindOfClass:[NSNull class]])
    {
        return;
    }
    [super setValue:value forKey:key];
}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
    if([key isEqualToString:@"id"])
    {
        
    }
    
}

@end
