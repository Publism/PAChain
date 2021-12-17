//


#import "CustomTextfield.h"

#define kTextFieldPaddingWidth  (10.0f)
#define kTextFieldPaddingHeight (1.0f)

@implementation CustomTextfield

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor grayColor].CGColor;
    }
    return self;
}
  
- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds,self.insetX == 0.0f ? kTextFieldPaddingWidth : self.insetX,self.insetY == 0.0f ? kTextFieldPaddingHeight : self.insetY);
}
  
- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds,self.insetX == 0.0f ? kTextFieldPaddingWidth : self.insetX,self.insetY == 0.0f ? kTextFieldPaddingHeight : self.insetY);
}
  
- (void)setDx:(CGFloat)dx
{
    _insetX = dx;
    [self setNeedsDisplay];
}
  
- (void)setDy:(CGFloat)dy
{
    _insetY = dy;
    [self setNeedsDisplay];
}

@end
