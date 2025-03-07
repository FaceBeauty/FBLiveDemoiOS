
#import <Masonry/Masonry.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol HTCaptureSessionManagerDelegate <NSObject>

- (void)captureSampleBuffer:(CMSampleBufferRef)sampleBuffer Rotation:(NSInteger)rotation Mirror:(BOOL)isMirror;

@end

@interface FBCaptureSessionManager : NSObject
/**
 *   初始化单例
 */
+ (FBCaptureSessionManager *)shareManager;
/**
 * 释放资源
 */
- (void)destroy;

- (void)startAVCaptureDelegate:(id<HTCaptureSessionManagerDelegate>)delegate;

- (void)didClickSwitchCameraButton;

@property(nonatomic, weak) id <HTCaptureSessionManagerDelegate> delegate;

@property (nonatomic, strong) AVCaptureDevice *cameraPosition;
@property (nonatomic, strong) AVCaptureSession *session;

@end
