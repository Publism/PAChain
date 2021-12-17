//
//  CustomMethodTool.m
//  VoteDemo
//


#import "CustomMethodTool.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netdb.h>
#import <arpa/inet.h>

@implementation CustomMethodTool

+ (NSString *)toJsonStrWithDictionary:(NSDictionary *)dict {
    if ([dict isKindOfClass:[NSString class]]) {
        return (NSString *)dict;
    }
    NSError *parseError = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *jsonSrt = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (parseError) {
        jsonSrt = @"";
    }
    return jsonSrt;
}

+ (NSString *)arrayToJSONString:(NSArray *)array
 {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

+ (NSArray *)stringToJSONArray:(NSString *)jsonStr
 {
    if ([jsonStr isKindOfClass:[NSArray class]]) {
        return (NSArray *)jsonStr;
    }
    if (jsonStr == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSArray *resultArr = [NSJSONSerialization JSONObjectWithData:jsonData
                                                   options:NSJSONReadingMutableContainers
                                                     error:&err];
    if(err) {
        return nil;
    }
    return resultArr;
}

+ (NSDictionary *)stringToJSONDictionary:(NSString *)jsonString
 {
     if (jsonString == nil) {
         return nil;
     }

     NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
     NSError *err;
     NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&err];
     if(err)
     {
         return nil;
     }
     return dic;
}

+ (NSString *)getTimeFromTimestamp:(double)time withFormat:(NSString *)format{
    NSDate * myDate=[NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter * formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:format];
    NSString *timeStr=[formatter stringFromDate:myDate];

    return timeStr;

}

+ (NSArray *)getMonthDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    NSString *today = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *day = [[today componentsSeparatedByString:@"-"] lastObject];
    
    long long times = [NSDate date].timeIntervalSince1970;
    
    NSMutableArray *marray = [NSMutableArray arrayWithObject:today];
    
    for (int i=0; i<32; i++) {
        
        times -= 24 * 60 * 60;
        
        NSString *dateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:times]];
        
        NSString *tempDay = [[dateStr componentsSeparatedByString:@"-"] lastObject];
        
        [marray addObject:dateStr];
        if ([tempDay isEqualToString:day]) {
            break;
        }
    }
    return marray;
}

+ (BOOL) validateEmail: (NSString *) strEmail {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:strEmail];
}

+ (BOOL)connectedToNetwork{
    struct sockaddr_storage zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.ss_len=sizeof(zeroAddress);
    zeroAddress.ss_family=AF_INET;
    SCNetworkReachabilityRef  defaultRouteReachability=SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    if (!didRetrieveFlags)
    {
        return NO;
    }
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable&&!needsConnection) ? YES : NO;
    return YES;
}

+ (NSString *)stringBase64AndUrlEncode:(NSString *)string{
    string = [string stringByReplacingOccurrencesOfString:@"-----BEGIN PUBLIC KEY-----" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"-----END PUBLIC KEY-----" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"-----BEGIN PRIVATE KEY-----" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"-----END PRIVATE KEY-----" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    string = [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"+" withString:@"%2b"];
    string = [string stringByReplacingOccurrencesOfString:@"/" withString:@"%2f"];
    string = [string stringByReplacingOccurrencesOfString:@"=" withString:@"%3d"];
    string = [string stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    
    return string;
}

+ (NSString *)getUUID{
    CFUUIDRef puuid = CFUUIDCreate(nil);
    CFStringRef uuidString = CFUUIDCreateString(nil, puuid);
    NSString *result = (NSString *)CFBridgingRelease(CFStringCreateCopy(NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

@end
