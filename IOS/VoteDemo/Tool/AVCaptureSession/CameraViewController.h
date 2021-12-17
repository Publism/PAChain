

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraViewController : UIViewController
/*
*image:photo
*/
@property (nonatomic,copy)void (^ ReturnImageBlock)(UIImage *image);

/*
 *sessionType:
 * 1.face
 * 2.driver license
 */
@property (nonatomic,copy)NSString *sessionType;

@end

NS_ASSUME_NONNULL_END
