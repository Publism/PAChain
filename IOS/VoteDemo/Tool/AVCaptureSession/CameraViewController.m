

#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface CameraViewController () <AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>
{
    AVCaptureSession          *_session;
    AVCaptureDeviceInput      *_deviceInput;
    AVCaptureConnection       *_videoConnection;
    AVCaptureVideoDataOutput  *_videoOutput;
    AVCaptureStillImageOutput *_imageOutput;
    AVCaptureVideoPreviewLayer * previewLayer;
    UILabel *tipLab;
}

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSError *error = [self setUpSession];
    
    if (!error) {
        previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
        UIView * aView = self.view;
        previewLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [aView.layer addSublayer:previewLayer];
        
        [self startCaptureSession];
        
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        if ([_sessionType isEqualToString:@"1"]) {
            imgView.image = [UIImage imageNamed:@"faceCamera"];
        }else{
            imgView.image = [UIImage imageNamed:@"driverLicense"];
        }
        [self.view addSubview:imgView];
        
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(20, 20, 35, 35);
        [backBtn setImage:[UIImage imageNamed:@"cancle"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:backBtn];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(self.view.frame.size.width/2-YWIDTH_SCALE(60), self.view.frame.size.height-YHEIGHT_SCALE(200), YWIDTH_SCALE(120),YWIDTH_SCALE(120));
        [btn setImage:[UIImage imageNamed:@"Cammer"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

- (void)backBtnClick{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)takePhoto{
    [self getVidioImage];
}

- (NSError*)setUpSession
{
    NSError *error;
    _session = [[AVCaptureSession alloc]init];
    _session.sessionPreset = AVCaptureSessionPresetHigh;
    
    [self setupSessionInputs:&error];
    
    [self setupSessionOutputs:&error];
    
    return error;
}

- (void)setupSessionInputs:(NSError **)error{
    
    AVCaptureDevicePosition desiredPosition;
    if ([_sessionType isEqualToString:@"1"]) {
        desiredPosition = AVCaptureDevicePositionFront;
    }else{
        desiredPosition = AVCaptureDevicePositionBack;
    }
    AVCaptureDeviceInput *videoInput = [self cameraForPosition:desiredPosition];
    if (videoInput) {
        if ([_session canAddInput:videoInput]){
            [_session addInput:videoInput];
        }
    }
    _deviceInput = videoInput;
}

- (AVCaptureDeviceInput *)cameraForPosition:(AVCaptureDevicePosition)desiredPosition {
  for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
    if ([device position] == desiredPosition) {
        NSError *error = nil;
      AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                          error:&error];
      if ([_session canAddInput:input]) {
        return input;
      }
    }
  }
  return nil;
}

- (void)setupSessionOutputs:(NSError **)error{
    dispatch_queue_t captureQueue = dispatch_queue_create("com.cc.captureQueue", DISPATCH_QUEUE_SERIAL);
    
    AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
    [videoOut setAlwaysDiscardsLateVideoFrames:YES];
    [videoOut setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
    [videoOut setSampleBufferDelegate:self queue:captureQueue];
    if ([_session canAddOutput:videoOut]){
        [_session addOutput:videoOut];
    }
    _videoOutput = videoOut;
    _videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
    
    AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];
    if (@available(iOS 11.0, *)) {
        imageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecTypeJPEG};
    } else {
        imageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    }
    if ([_session canAddOutput:imageOutput]) {
        [_session addOutput:imageOutput];
    }
    _imageOutput = imageOutput;
    if ([_sessionType isEqualToString:@"1"]) {
        AVCaptureConnection *connection = [_imageOutput connectionWithMediaType:AVMediaTypeVideo];
        connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        connection.videoMirrored = YES;
    }
}

#pragma mark - -
- (void)startCaptureSession{
    if (!_session.isRunning){
        [_session startRunning];
    }
}

- (void)stopCaptureSession{
    if (_session.isRunning){
        [_session stopRunning];
    }
}

- (void)getVidioImage
{
    
    AVCaptureConnection *connection = [_imageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    [_imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        if (error) {
            return;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [[UIImage alloc]initWithData:imageData];
        if ([self.sessionType isEqualToString:@"1"]) {
            [self stopCaptureSession];
            image = [self cropImage:image toRect:CGRectMake(((CGFloat)image.size.width/(self.view.frame.size.width*2))*(YWIDTH_SCALE(116)*2), ((CGFloat)image.size.height/(self.view.frame.size.height*2))*(YWIDTH_SCALE(336)*2), ((CGFloat)image.size.width/(self.view.frame.size.width*2))*(YWIDTH_SCALE(514)*2), ((CGFloat)image.size.width/(self.view.frame.size.width*2))*(YWIDTH_SCALE(514)*2))];
            CIImage *ciimg = [CIImage imageWithCGImage:image.CGImage];
            CIContext *context = [CIContext contextWithOptions:nil];
            NSDictionary *param = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
            CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:param];
            NSArray *detectResult = [faceDetector featuresInImage:ciimg];
            if (detectResult.count > 0) {
                CIFaceFeature *face = [detectResult firstObject];
                if (face.hasMouthPosition && face.hasLeftEyePosition && face.hasRightEyePosition) {
                    if (self.ReturnImageBlock) {
                        self.ReturnImageBlock(image);
                    }
                    [self dismissViewControllerAnimated:YES completion:^{
                        
                    }];
                }else{
                    [self startCaptureSession];
                    [VoteDemoHUD setHUD:@"No face detected"];
                }
            }else{
                [self startCaptureSession];
                [VoteDemoHUD setHUD:@"No face detected"];
            }
        }else{
            image = [self cropImage:image toRect:CGRectMake(((CGFloat)image.size.width/(self.view.frame.size.width*2))*(YWIDTH_SCALE(82)*2), ((CGFloat)image.size.height/(self.view.frame.size.height*2))*(YWIDTH_SCALE(368)*2), ((CGFloat)image.size.width/(self.view.frame.size.width*2))*(YWIDTH_SCALE(586)*2), ((CGFloat)image.size.width/(self.view.frame.size.width*2))*(YWIDTH_SCALE(360)*2))];
            if (self.ReturnImageBlock) {
                self.ReturnImageBlock(image);
            }
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }];
}

- (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect {
    CGFloat x = rect.origin.x;
    CGFloat y = rect.origin.y;
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    CGRect croprect = CGRectMake(floor(x), floor(y), round(width), round(height));
    UIImage *toCropImage = [self fixOrientation:image];// 纠正方向
    CGImageRef cgImage = CGImageCreateWithImageInRect(toCropImage.CGImage, croprect);
    UIImage *cropped = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return cropped;
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
    if (aImage.imageOrientation ==UIImageOrientationUp)
        return aImage;
    CGAffineTransform transform =CGAffineTransformIdentity;
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width,0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width,0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height,0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    CGContextRef ctx =CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage),0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx,CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
        default:
            CGContextDrawImage(ctx,CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    CGImageRef cgimg =CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);

    return img;

}

@end
