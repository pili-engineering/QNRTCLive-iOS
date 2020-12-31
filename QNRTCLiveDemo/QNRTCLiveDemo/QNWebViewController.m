//
//  QNWebViewController.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/16.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNWebViewController.h"
#import <WebKit/WebKit.h>

@interface QNWebViewController ()
<
WKUIDelegate,
WKNavigationDelegate
>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) QNReachability *reachability;
@property (nonatomic, strong) QNSigleAlertView *alertContentView;
@end

@implementation QNWebViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kQNReachabilityChangedNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kQNReachabilityChangedNotification object:nil];
    
    self.reachability = [QNReachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    
    self.alertContentView = [[QNSigleAlertView alloc] init];
    [self layoutInterface];
}

- (void)layoutInterface {
    CGFloat navigationHeight = 64;
    CGFloat space = 10;
    if(QN_iPhoneX || QN_iPhoneXR || QN_iPhoneXSMAX ||
       QN_iPhone12Min || QN_iPhone12Pro || QN_iPhone12PMax) {
        navigationHeight = 88;
        space = 20;
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QN_KSCREEN_WIDTH, navigationHeight)];
    headerView.backgroundColor = QN_COLOR_RGB(30, 139, 255, 1);
    [self.view addSubview:headerView];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = QN_FONT_REGULAR(16.0);
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = _titleName;
    [titleLabel sizeToFit];
    [headerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(headerView.mas_centerX);
        make.centerY.mas_equalTo(headerView.mas_centerY).offset(space);
    }];
    
    UIButton *backButton = [[UIButton alloc] init];
    [backButton setImage:[UIImage imageNamed:@"get_back"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(headerView.mas_left).offset(22);
        make.centerY.mas_equalTo(titleLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(32, 32));
    }];
    [backButton addTarget:self action:@selector(getBack) forControlEvents:UIControlEventTouchUpInside];

    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, navigationHeight, QN_KSCREEN_WIDTH, QN_KSCREEN_HEIGHT - navigationHeight) configuration:configuration];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    _webView.allowsBackForwardNavigationGestures = YES;
    [_webView loadRequest:[NSURLRequest requestWithURL:_url]];
    [self.view addSubview:_webView];
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

#pragma mark - WKNavigationDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self.alertContentView addAlertContent:@"页面加载中..." bgView:self.view];
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self.alertContentView removeAlertContentView];
    QNSigleAlertView *alertView = [[QNSigleAlertView alloc] init];
    [alertView showAlertViewTitle:@"页面加载失败！！！" bgView:self.view];
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.alertContentView removeAlertContentView];
}
// 接收到服务器跳转请求即服务重定向时之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
}
//进程被终止时调用
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
}


- (void)getBack {
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
