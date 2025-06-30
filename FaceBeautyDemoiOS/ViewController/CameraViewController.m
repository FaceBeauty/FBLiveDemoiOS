
#import "CameraViewController.h"
#import "FBCaptureSessionManager.h"
#import "AppDelegate.h"

//todo --- facebeauty start ---
#import <FaceBeauty/FaceBeauty.h>
#import "FBUIManager.h"
//todo --- facebeauty end ---
#import <FaceBeauty/FaceBeautyView.h>

@interface CameraViewController () <FBUIManagerDelegate,FaceBeautyDelegate,HTCaptureSessionManagerDelegate>

@property (nonatomic, strong) FaceBeautyView *htLiveView;

@property (nonatomic, assign) BOOL isRenderInit;

@property (nonatomic, assign) int functionIndex;

@property (nonatomic, strong) CIImage *outputImage;
@property (nonatomic, assign) CVPixelBufferRef outputImagePixelBuffer;

@end

@implementation CameraViewController

- (FaceBeautyView *)htLiveView{
    if (!_htLiveView) {
        _htLiveView = [[FaceBeautyView alloc] init];
        _htLiveView.contentMode = FaceBeautyViewContentModeScaleAspectFill;
        _htLiveView.orientation = FaceBeautyViewOrientationLandscapeLeft;
        _htLiveView.userInteractionEnabled = YES;
    }
    return _htLiveView;
}

#pragma mark - 初始化
- (instancetype)initWithFunction:(int)index{
    self = [super init];
    if (self) {
        self.functionIndex = index;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.htLiveView];
    [self.htLiveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
        make.width.height.equalTo(self.view);
    }];
    
    //todo --- facebeauty start ---
    if ([isSDKInit  isEqual: @"初始化失败"]) {
        [[FaceBeauty shareInstance] initFaceBeauty:@"YOUR_APP_ID" withDelegate:self];
    }
    [[FBCaptureSessionManager shareManager] startAVCaptureDelegate:self];
    [[FBUIManager shareManager] loadToWindowDelegate:self];
    
    if (self.functionIndex == 0) {
        [[FBUIManager shareManager] showBeautyView];
    }else{
        if (self.functionIndex == 1) {
            [[FBUIManager shareManager] showFunView:FBItemSticker];
        }else if (self.functionIndex == 2) {
            [[FBUIManager shareManager] showFunView:FBItemMask];
        }
    }
    
    //todo --- facebeauty end ---
    
    [self.view addSubview:[FBUIManager shareManager].defaultButton];
}

//切换相机
- (void)SwitchCamera:(UIButton *)button{
    [[FBCaptureSessionManager shareManager] didClickSwitchCameraButton];
    self.isRenderInit = false;
}

// MARK: --FBUIManagerDelegate Delegate--
- (void)didClickCameraCaptureButton{
    //拍照
    [self takePhoto];
}

- (void)didClickSwitchCameraButton{
    //切换摄像头
    [[FBCaptureSessionManager shareManager] didClickSwitchCameraButton];
    self.isRenderInit = false;
}

// MARK: --HTCaptureSessionManager Delegate--
- (void)captureSampleBuffer:(CMSampleBufferRef)sampleBuffer Rotation:(NSInteger)rotation Mirror:(BOOL)isMirror{
    
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    if (pixelBuffer == NULL) {
        return;
    }
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    unsigned char *baseAddress = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    
    //todo --- facebeauty start ---
    // 视频帧格式
    FBFormatEnum format;
    switch (CVPixelBufferGetPixelFormatType(pixelBuffer)) {
        case kCVPixelFormatType_32BGRA:
            format = FBFormatBGRA;
            break;
        case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
        case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange:
            format = FBFormatNV12;
            break;
        default:
            NSLog(@"错误的视频帧格式！");
            format = FBFormatBGRA;
            break;
    }
    
    int imageWidth, imageHeight;
    if (format == FBFormatBGRA) {
        imageWidth = (int)CVPixelBufferGetBytesPerRow(pixelBuffer) / 4;
        imageHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    } else {
        imageWidth = (int)CVPixelBufferGetWidthOfPlane(pixelBuffer , 0);
        imageHeight = (int)CVPixelBufferGetHeightOfPlane(pixelBuffer , 0);
    }
    
    if (!_isRenderInit) {
        [[FaceBeauty shareInstance] releaseBufferRenderer];
        _isRenderInit = [[FaceBeauty shareInstance] initBufferRenderer:format width:imageWidth height:imageHeight rotation:FBRotationClockwise90 isMirror:isMirror maxFaces:5];
    }
    
    [[FaceBeauty shareInstance] processBuffer:baseAddress];

    //todo --- facebeauty end ---
    
    [self.htLiveView displayPixelBuffer:pixelBuffer isMirror:isMirror];
    
    self.outputImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    self.outputImagePixelBuffer = pixelBuffer;
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
}

- (void)takePhoto {
    if (self.outputImage) {
        /* 录制 前置摄像头修正图片朝向*/
        UIImage *processedImage = [self image:[self imageFromCVPixelBufferRef:_outputImagePixelBuffer] rotation:FBRotationClockwise270];
        UIImageWriteToSavedPhotosAlbum(processedImage, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
    }else{
        UIAlertController *alertView = [[UIAlertController alloc] init];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
        [alertView addAction:cancelAction];
        [alertView setTitle:@"拍照失败,请重试"];
        [self presentViewController:alertView animated:NO completion:nil];
    }
}

- (void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    UIAlertController *alertView = [[UIAlertController alloc] init];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
    [alertView addAction:cancelAction];
    [alertView setTitle:@"拍照成功"];
    
    if (error) {
        [alertView setMessage:[NSString stringWithFormat:@"拍照失败，原因：%@", error]];
        NSLog(@"save failed.");
    } else {
        [alertView setMessage:[NSString stringWithFormat:@"已为您保存到相册！"]];
        NSLog(@"save success.");
    }
    [self presentViewController:alertView animated:NO completion:nil];
    
}

#pragma mark -- CVPixelBufferRef-BGRA转UIImage
- (UIImage *)imageFromCVPixelBufferRef:(CVPixelBufferRef)pixelBuffer{
    UIImage *image;
    @autoreleasepool {
        CGImageRef cgImage = NULL;
        CVPixelBufferRef pb = (CVPixelBufferRef)pixelBuffer;
        CVPixelBufferLockBaseAddress(pb, kCVPixelBufferLock_ReadOnly);
        OSStatus res = CreateCGImageFromCVPixelBuffer(pb,&cgImage);
        if (res == noErr){
            image= [UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationUp];
        }
        CVPixelBufferUnlockBaseAddress(pb, kCVPixelBufferLock_ReadOnly);
        CGImageRelease(cgImage);
    }
    return image;
}

static OSStatus CreateCGImageFromCVPixelBuffer(CVPixelBufferRef pixelBuffer, CGImageRef *imageOut)
{
    OSStatus err = noErr;
    OSType sourcePixelFormat;
    size_t width, height, sourceRowBytes;
    void *sourceBaseAddr = NULL;
    CGBitmapInfo bitmapInfo;
    CGColorSpaceRef colorspace = NULL;
    CGDataProviderRef provider = NULL;
    CGImageRef image = NULL;
    sourcePixelFormat = CVPixelBufferGetPixelFormatType( pixelBuffer );
    if ( kCVPixelFormatType_32ARGB == sourcePixelFormat )
        bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaNoneSkipFirst;
    else if ( kCVPixelFormatType_32BGRA == sourcePixelFormat )
        bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
    else
        return -95014; // only uncompressed pixel formats
    sourceRowBytes = CVPixelBufferGetBytesPerRow( pixelBuffer );
    width = CVPixelBufferGetWidth( pixelBuffer );
    height = CVPixelBufferGetHeight( pixelBuffer );
    CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
    sourceBaseAddr = CVPixelBufferGetBaseAddress( pixelBuffer );
    colorspace = CGColorSpaceCreateDeviceRGB();
    CVPixelBufferRetain( pixelBuffer );
    provider = CGDataProviderCreateWithData( (void *)pixelBuffer, sourceBaseAddr, sourceRowBytes * height, ReleaseCVPixelBuffer);
    image = CGImageCreate(width, height, 8, 32, sourceRowBytes, colorspace, bitmapInfo, provider, NULL, true, kCGRenderingIntentDefault);
    if ( err && image ) {
        CGImageRelease( image );
        image = NULL;
    }
    if ( provider ) CGDataProviderRelease( provider );
    if ( colorspace ) CGColorSpaceRelease( colorspace );
    *imageOut = image;
    return err;
}

static void ReleaseCVPixelBuffer(void *pixel, const void *data, size_t size)
{
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)pixel;
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    CVPixelBufferRelease(pixelBuffer);
}

#pragma mark -- 旋转UIImage为正向
- (UIImage *)image:(UIImage *)image rotation:(FBRotationEnum)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case FBRotationClockwise90:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case FBRotationClockwise270:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case FBRotationClockwise180:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    
    if ([[FBCaptureSessionManager shareManager].cameraPosition position] == AVCaptureDevicePositionFront) {
        //前置摄像头要转换镜像图片
        newPic = [self convertMirrorImage:newPic];
    }
    
    return newPic;
}

- (UIImage *)convertMirrorImage:(UIImage *)image {
    //Quartz重绘图片
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 2);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextClipToRect(currentContext, rect);
    CGContextRotateCTM(currentContext, (CGFloat) M_PI);
    CGContextTranslateCTM(currentContext, -rect.size.width, -rect.size.height);
    CGContextDrawImage(currentContext, rect, image.CGImage);
    
    //翻转图片
    UIImage *drawImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *flipImage = [[UIImage alloc] initWithCGImage:drawImage.CGImage];
    
    return flipImage;
}

- (void)dealloc {
    //todo --- facebeauty start ---
    [[FaceBeauty shareInstance] releaseBufferRenderer];
    [[FBUIManager shareManager] destroy];
    //todo --- facebeauty end ---
}

- (void)onInitFailure {
    isSDKInit = @"初始化失败";
}

- (void)onInitSuccess {
    isSDKInit = @"初始化成功";
}

@end
