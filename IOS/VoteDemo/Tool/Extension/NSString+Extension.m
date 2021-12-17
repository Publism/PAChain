//


#import "NSString+Extension.h"
#import <CoreText/CoreText.h>


@implementation NSString (Extension)

- (NSString *)base64Encoded{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSString *stringBase64 = [data base64EncodedStringWithOptions:0];
    return stringBase64;
}

- (NSString *)base64Decoded{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    return string;
}

- (NSString *)transformDateStringWithFormat:(NSString *)format toformat:(NSString *)toformat{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];

    [formatter setDateFormat:format];

    NSDate *date = [formatter dateFromString:self];

    NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
    
    [formatter2 setDateFormat:toformat];

    return [formatter2 stringFromDate:date];
}

-(NSString *)filterHTML
{
    NSString *html = self;
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        [scanner scanUpToString:@"<" intoString:nil];
        [scanner scanUpToString:@">" intoString:&text];
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    return html;
}

- (NSString *)getTimeFromTimestamp{

    double time =[self doubleValue];

    NSDate * myDate=[NSDate dateWithTimeIntervalSince1970:time];

    NSDateFormatter * formatter=[[NSDateFormatter alloc]init];

    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSString *timeStr=[formatter stringFromDate:myDate];

    return timeStr;

}

- (NSArray *)getLinesArrayOfStringWidth:(CGFloat)width withFont:(UIFont *)font {
    if (self == nil) {
        return nil;
    }
    CTFontRef myFont = CTFontCreateWithName(( CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:self];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attStr.length)];
    [attStr addAttribute:(NSString *)kCTFontAttributeName
                   value:(__bridge  id)myFont
                   range:NSMakeRange(0, attStr.length)];
    CFRelease(myFont);
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(( CFAttributedStringRef)attStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,width,100000));
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    NSArray *lines = ( NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    for (id line in lines) {
        CTLineRef lineRef = (__bridge  CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        NSString *lineString = [self substringWithRange:range];
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr,
                                       lineRange,
                                       kCTKernAttributeName,
                                       (CFTypeRef)([NSNumber numberWithFloat:0.0]));
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr,
                                       lineRange,
                                       kCTKernAttributeName,
                                       (CFTypeRef)([NSNumber numberWithInt:0.0]));
        NSString * lineString2 = [lineString stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (lineString2.length > 0) {
            [linesArray addObject:lineString];
        }
        
    }
    CGPathRelease(path);
    CFRelease(frame);
    CFRelease(frameSetter);
    
    return (NSArray *)linesArray;
}


@end
