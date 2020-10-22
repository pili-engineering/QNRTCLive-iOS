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
@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) QNReachability *reachability;
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
    
    CGFloat space = 20;
    if(QN_iPhoneX || QN_iPhoneXR || QN_iPhoneXSMAX) {
        space = 40;
    }
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, space, QN_KSCREEN_WIDTH, QN_KSCREEN_HEIGHT - space) configuration:configuration];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    _webView.allowsBackForwardNavigationGestures = YES;
    [_webView loadRequest:[NSURLRequest requestWithURL:_url]];
    [self.view addSubview:_webView];
    
    self.backButton = [[UIButton alloc] init];
    [_backButton setImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateNormal];
    _backButton.backgroundColor = QN_COLOR_RGB(0, 0, 0, 0.6);
    _backButton.layer.cornerRadius = 26;
    _backButton.clipsToBounds = YES;
    [self.view addSubview:_backButton];
       
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).mas_offset(20);
        make.top.mas_equalTo(self.view.mas_top).mas_offset(space);
        make.size.mas_equalTo(CGSizeMake(52, 52));
    }];
    [_backButton addTarget:self action:@selector(getBack) forControlEvents:UIControlEventTouchUpInside];
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
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
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
