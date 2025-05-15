
#import "AppDelegate.h"
#import "HomeViewController.h"
#import <FaceBeauty/FaceBeauty.h>

NSString *isSDKInit = @"未初始化";

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[HomeViewController alloc] init]];
    [self.window makeKeyAndVisible];
//    #error----在线鉴权密钥
    
    // 本地资源文件拷贝至沙盒路径
    BOOL isResourceCopied = NO;
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"FaceBeauty" ofType:@"bundle"];

    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    if (libraryPaths.count > 0) {
        NSString *libraryDirectory = [libraryPaths lastObject];
        NSString *sandboxPath = [libraryDirectory stringByAppendingPathComponent:@"FaceBeauty"];
        isResourceCopied = [[FaceBeauty shareInstance] copyResourceBundle:bundlePath toSandbox:sandboxPath];
    }

    NSString *version = [[FaceBeauty shareInstance] getVersion];
    NSLog(@"当前FaceBeauty版本 %@", version ?: @"");

    # error 需要FaceBeauty appid，与包名应用名绑定，请联系商务获取
    if (isResourceCopied) {
        [[FaceBeauty shareInstance] initFaceBeauty:@"YOUR_APP_ID" withDelegate:nil];
    }
    return YES;
}

- (void)onInitFailure {
    isSDKInit = @"初始化失败";
}

- (void)onInitSuccess {
    isSDKInit = @"初始化成功";
}

@end
