//
//  CustomMethodTool.h
//  VoteDemo
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomMethodTool : NSObject
+ (NSString *)toJsonStrWithDictionary:(NSDictionary *)dict;
+ (NSString *)arrayToJSONString:(NSArray *)array;
+ (NSArray *)stringToJSONArray:(NSString *)string;
+ (NSDictionary *)stringToJSONDictionary:(NSString *)string;
+ (NSString *)getTimeFromTimestamp:(double)time  withFormat:(NSString *)format;
+ (NSArray *)getMonthDate;
+ (BOOL) validateEmail: (NSString *) strEmail;
+ (BOOL)connectedToNetwork;
+ (NSString *)stringBase64AndUrlEncode:(NSString *)string;
+ (NSString *)getUUID;
@end

NS_ASSUME_NONNULL_END
