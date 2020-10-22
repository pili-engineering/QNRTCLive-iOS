//
//  QNAppDelegate.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/7.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNAppDelegate.h"
#import "QNLoginViewController.h"
#import "QNHomeViewController.h"
#import "RCCRRongCloudIMManager.h"

@interface QNAppDelegate ()

@end

@implementation QNAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController.view.frame = self.window.bounds;
    self.window.rootViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth |
       UIViewAutoresizingFlexibleHeight;
    
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"QN_USER_INFOMATION"];
    if (dic != nil && dic.count != 0) {
        QNHomeViewController *homeViewController = [[QNHomeViewController alloc] init];
        self.window.rootViewController = homeViewController;
    } else{
        QNLoginViewController *loginViewController = [[QNLoginViewController alloc] init];
        self.window.rootViewController = loginViewController;
    }
    [self.window makeKeyAndVisible];
    
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] initRongCloud:RCIMAPPKey];
    
    // Xcode 调试时，请注释下述代码
    // 下述代码会影响控制台输出
    [self redirectNSlogToDocumentFolder];
    return YES;
}

// 写日志入沙盒
- (void)redirectNSlogToDocumentFolder {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *dataFilePath = [documentDirectory stringByAppendingPathComponent:@"APPLogs"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:dataFilePath isDirectory:&isDir];
    if (!(isDir && existed)) {
        // 在Document目录下创建一个目录
        [fileManager createDirectoryAtPath:dataFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    NSString *fileName = [NSString stringWithFormat:@"QNRTCLiveDemo-%@.log", [self currentDateStr]];
    NSString *logFilePath = [dataFilePath stringByAppendingPathComponent:fileName];
    // 将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+", stderr);
}

- (NSString *)currentDateStr{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd-hh:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    return dateString;
}

@end
