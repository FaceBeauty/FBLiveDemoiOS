
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
    [[FaceBeauty shareInstance] initFaceBeauty:@"YOUR_APP_ID" withDelegate:self];
    return YES;
}

- (void)onInitFailure {
    isSDKInit = @"初始化失败";
}

- (void)onInitSuccess {
    isSDKInit = @"初始化成功";
}

@end
