//


#import "EasySignatureView.h"
#import <QuartzCore/QuartzCore.h>

#define StrWidth 210
#define StrHeight 20

static CGPoint midpoint(CGPoint p0,CGPoint p1) {
    return (CGPoint) {
        (p0.x + p1.x) /2.0,
        (p0.y + p1.y) /2.0
    };
}

@interface EasySignatureView () {
    UIBezierPath *path;
    CGPoint previousPoint;
    BOOL isHaveDraw;
}
@end

@implementation EasySignatureView

- (void)commonInit {
    
    path = [UIBezierPath bezierPath];
    [path setLineWidth:2];
    
    max = 0;
    min = 0;
    // Capture touches
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.maximumNumberOfTouches = pan.minimumNumberOfTouches =1;
    [self addGestureRecognizer:pan];
    
}

-(void)clearPan
{
    path = [UIBezierPath bezierPath];
    [path setLineWidth:3];
    
    [self setNeedsDisplay];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
        [self commonInit];
    self.currentPointArr = [NSMutableArray array];
    self.hasSignatureImg = NO;
    isHaveDraw = NO;
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
        [self commonInit];
    return self;
}

- (UIImage*) imageBlackToTransparent:(UIImage*) image
{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    
    CGColorSpaceRef colorSpace =CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i =0; i < pixelNum; i++, pCurPtr++)
    {
        if (*pCurPtr == 0xffffff)
        {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] =0;
        }
        
    }
    
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight,/*ProviderReleaseData**/NULL);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8,32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true,kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return resultUIImage;
}


-(void)handelSingleTap:(UITapGestureRecognizer*)tap
{
    return [self imageRepresentation];
}
-(void) imageRepresentation {
    
    if(&UIGraphicsBeginImageContextWithOptions !=NULL)
    {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size,NO, [UIScreen mainScreen].scale);
    }else {
        UIGraphicsBeginImageContext(self.bounds.size);
        
    }
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image =UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    image = [self imageBlackToTransparent:image];
    
    self.SignatureImg = image;
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    CGPoint currentPoint = [pan locationInView:self];
    CGPoint midPoint = midpoint(previousPoint, currentPoint);
    [self.currentPointArr addObject:[NSValue valueWithCGPoint:currentPoint]];
    self.hasSignatureImg = YES;
    CGFloat viewHeight = self.frame.size.height;
    CGFloat currentY = currentPoint.y;
    if (pan.state ==UIGestureRecognizerStateBegan) {
        [path moveToPoint:currentPoint];
        
    } else if (pan.state ==UIGestureRecognizerStateChanged) {
        [path addQuadCurveToPoint:midPoint controlPoint:previousPoint];
        
        
    }
    
    if(0 <= currentY && currentY <= viewHeight)
    {
        if(max == 0&&min == 0)
        {
            max = currentPoint.x;
            min = currentPoint.x;
        }
        else
        {
            if(max <= currentPoint.x)
            {
                max = currentPoint.x;
            }
            if(min>=currentPoint.x)
            {
                min = currentPoint.x;
            }
        }
        
    }
    
    previousPoint = currentPoint;
    
    [self setNeedsDisplay];
    isHaveDraw = YES;
    if (self.delegate != nil &&[self.delegate respondsToSelector:@selector(onSignatureWriteAction)]) {
        [self.delegate onSignatureWriteAction];
    }
}

- (void)drawRect:(CGRect)rect
{
    self.backgroundColor = [UIColor whiteColor];
    [[UIColor blackColor] setStroke];
    [path stroke];
    
    /*self.layer.cornerRadius =5.0;
     self.clipsToBounds =YES;
     self.layer.borderWidth =0.5;
     self.layer.borderColor = [[UIColor grayColor] CGColor];*/
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    if(!isSure && !isHaveDraw)
    {
    }
    else
    {
        isSure = NO;
    }
    
}

- (void)clear
{
    if (self.currentPointArr && self.currentPointArr.count > 0) {
        [self.currentPointArr removeAllObjects];
    }
    self.hasSignatureImg = NO;
    max = 0;
    min = 0;
    path = [UIBezierPath bezierPath];
    [path setLineWidth:2];
    isHaveDraw = NO;
    [self setNeedsDisplay];
    
}
- (void)sure
{
    if(min == 0&&max == 0)
    {
        min = 0;
        max = 0;
    }
    isSure = YES;
    [self setNeedsDisplay];
    return [self imageRepresentation];
}


@end
