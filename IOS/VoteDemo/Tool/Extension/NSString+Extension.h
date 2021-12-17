//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Extension)
- (NSString *)base64Encoded;
- (NSString *)base64Decoded;
- (NSString *)transformDateStringWithFormat:(NSString *)format toformat:(NSString *)toformat;
- (NSString *)filterHTML;
- (NSString *)getTimeFromTimestamp;
- (NSArray *)getLinesArrayOfStringWidth:(CGFloat)width withFont:(UIFont *)font;
@end

NS_ASSUME_NONNULL_END
