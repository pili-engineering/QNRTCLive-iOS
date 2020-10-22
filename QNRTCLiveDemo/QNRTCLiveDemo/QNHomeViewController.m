//
//  QNHomeViewController.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/7.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNHomeViewController.h"
#import "QNPersonViewController.h"
#import "QNLiveViewController.h"
#import "QNListViewController.h"

@interface QNHomeViewController ()
<
UITabBarControllerDelegate,
UITabBarDelegate
>

@property (nonatomic, strong) QNReachability *reachability;

@end

@implementation QNHomeViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kQNReachabilityChangedNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kQNReachabilityChangedNotification object:nil];
    
    self.reachability = [QNReachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    
    [QNRTCEngine requestCameraAccessWithCompletionHandler:^(BOOL granted) {
       
    }];
    
    [QNRTCEngine requestMicrophoneAccessWithCompletionHandler:^(BOOL granted) {
        
    }];

    self.view.backgroundColor = [UIColor whiteColor];

    [self layoutInterfaceView];

    self.delegate = self;
}

- (void)reachabilityChanged:(NSNotification *)notification {
    QNReachability *curReachability = [notification object];
    QNNetworkStatus netStatus = [curReachability currentReachabilityStatus];
    QNSigleAlertView *sigleView = [[QNSigleAlertView alloc]init];
    NSString *alertContent = @"";
    switch (netStatus){
           case QNNotReachable:        {
               alertContent = @"网络服务不可用，请及时连接网络！";
               break;
           }

           case QNReachableViaWWAN:        {
               alertContent = @"运营商网络服务";
               break;
           }
           case QNReachableViaWiFi:        {
               alertContent = @"WiFi 网络服务";
               break;
           }
    }
    [sigleView showAlertViewTitle:alertContent bgView:self.view];
}

# pragma mark - views

- (void)layoutInterfaceView {
    
    // 首页
    QNListViewController *listViewController = [[QNListViewController alloc]init];
    listViewController.tabBarItem.title = @"首页";
    listViewController.tabBarItem.tag = 0;
    [listViewController.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0,-10)];
    [listViewController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Helvetica" size:18.0f],NSFontAttributeName,nil] forState:UIControlStateNormal];

    // 我的
    QNPersonViewController *personViewController = [[QNPersonViewController alloc]init];
    personViewController.tabBarItem.title = @"我的";
    personViewController.tabBarItem.tag = 1;
    [personViewController.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0,-10)];
    [personViewController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Helvetica" size:18.0f],NSFontAttributeName,nil] forState:UIControlStateNormal];
   
    self.viewControllers = @[listViewController, personViewController];
    self.selectedIndex = 0;
    self.tabBar.barTintColor = [UIColor whiteColor];
    self.tabBar.tintColor = [UIColor blackColor];
    
    UIButton *liveButton = [[UIButton alloc] init];
    [liveButton setImage:[UIImage imageNamed:@"icon_start live"] forState:UIControlStateNormal];
    [liveButton addTarget:self action:@selector(enterLiveView) forControlEvents:UIControlEventTouchUpInside];
    liveButton.highlighted = NO;
    [self.view addSubview:liveButton];
    
    [liveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.tabBar.mas_centerX);
        make.centerY.mas_equalTo(self.tabBar.mas_centerY).offset(-26);
        make.size.mas_equalTo(CGSizeMake(78, 78));
    }];
    
}
   
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {

    NSInteger index = [tabBarController.childViewControllers indexOfObject:viewController];

}


# pragma mark - actions

- (void)enterLiveView {
    // 进入直播
    QNLiveViewController *liveViewController = [[QNLiveViewController alloc]init];
    liveViewController.hidesBottomBarWhenPushed = YES;
    liveViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:liveViewController animated:YES completion:nil];
}

- (void)getback {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
