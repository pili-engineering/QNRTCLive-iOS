//
//  QNLoginViewController.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/7.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNLoginViewController.h"
#import "QNHomeViewController.h"
#import "QNAppDelegate.h"
#import "QNWebViewController.h"

@interface QNLoginViewController ()
<
UITextFieldDelegate
>
@property (nonatomic, strong) UIImageView *logoImageView;

@property (nonatomic, strong) UIView *inputView;
@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UITextField *checkTextField;

@property (nonatomic, strong) UIButton *getCodeButton;
@property (nonatomic, strong) UIButton *loginButton;

@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) UIButton *userAgentButton;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger countNumber;

@property (nonatomic, strong) QNReachability *reachability;
@end

@implementation QNLoginViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kQNReachabilityChangedNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kQNReachabilityChangedNotification object:nil];
    
    self.reachability = [QNReachability reachabilityForInternetConnection];
    [self.reachability startNotifier];

    self.view.backgroundColor = [UIColor whiteColor];
    
    [self layoutInterfaceView];
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
    
    // 输入视图
    self.inputView = [[UIView alloc] init];
    [self.view addSubview:_inputView];
    [_inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).mas_offset(40);
        make.right.mas_equalTo(self.view.mas_right).mas_offset(-40);
        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-310);
        make.height.mas_equalTo(102);
    }];
    
    UIView *lineViewOne = [[UIView alloc] init];
    lineViewOne.backgroundColor = QN_COLOR_RGB(151, 151, 151, 1);
    [_inputView addSubview:lineViewOne];
    [lineViewOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.inputView.mas_left);
        make.right.mas_equalTo(self.inputView.mas_right);
        make.bottom.mas_equalTo(self.inputView.mas_bottom).mas_offset(-50);
        make.height.mas_equalTo(1);
    }];
    
    UIView *lineViewTwo = [[UIView alloc] init];
    lineViewTwo.backgroundColor = QN_COLOR_RGB(151, 151, 151, 1);
    [_inputView addSubview:lineViewTwo];
    [lineViewTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.inputView.mas_left);
        make.right.mas_equalTo(self.inputView.mas_right);
        make.bottom.mas_equalTo(self.inputView.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    
    self.phoneTextField = [[UITextField alloc] init];
    self.phoneTextField.backgroundColor = [UIColor whiteColor];
    self.phoneTextField.placeholder = @"请输入手机号";
    self.phoneTextField.borderStyle = UITextBorderStyleNone;
    self.phoneTextField.font = QN_FONT_REGULAR(14);
    self.phoneTextField.textColor = [UIColor blackColor];
    self.phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.phoneTextField.delegate = self;
    self.phoneTextField.keyboardType = UIKeyboardTypePhonePad;
    [_inputView addSubview:_phoneTextField];
    [self.phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.inputView.mas_left).mas_offset(15);
        make.right.mas_equalTo(self.inputView.mas_right).mas_offset(-15);
        make.bottom.mas_equalTo(lineViewOne.mas_bottom).mas_offset(-8);
        make.height.mas_equalTo(22);
    }];
    
    self.getCodeButton = [[UIButton alloc] init];
    self.getCodeButton.layer.cornerRadius = 2;
    self.getCodeButton.clipsToBounds = YES;
    self.getCodeButton.layer.borderWidth = 0.5;
    self.getCodeButton.layer.borderColor = QN_COLOR_RGB(140, 140, 140, 1).CGColor;
    self.getCodeButton.titleLabel.font = QN_FONT_REGULAR(11);
    [self.getCodeButton setTitleColor:QN_COLOR_RGB(140, 140, 140, 1) forState:UIControlStateNormal];
    [self.getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_inputView addSubview:_getCodeButton];
       
    [self.getCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.inputView.mas_right).mas_offset(-10);
        make.bottom.mas_equalTo(lineViewTwo.mas_bottom).mas_offset(-8);
        make.size.mas_equalTo(CGSizeMake(72, 21));
    }];
    [self.getCodeButton addTarget:self action:@selector(getCode) forControlEvents:UIControlEventTouchUpInside];
    
    self.checkTextField = [[UITextField alloc] init];
    self.checkTextField.backgroundColor = [UIColor whiteColor];
    self.checkTextField.placeholder = @"请输入验证码";
    self.checkTextField.borderStyle = UITextBorderStyleNone;
    self.checkTextField.font = QN_FONT_REGULAR(14);
    self.checkTextField.textColor = [UIColor blackColor];
    self.checkTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.checkTextField.delegate = self;
    self.checkTextField.keyboardType = UIKeyboardTypePhonePad;
    [_inputView addSubview:_checkTextField];
    [self.checkTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.inputView.mas_left).mas_offset(15);
        make.right.mas_equalTo(self.getCodeButton.mas_left).mas_offset(-20);
        make.bottom.mas_equalTo(lineViewTwo.mas_bottom).mas_offset(-8);
        make.height.mas_equalTo(22);
    }];
    
    [self adjustColor];
    
    // 登陆按钮
    self.loginButton = [[UIButton alloc] init];
    [self.loginButton setImage:[UIImage imageNamed:@"icon_landed"] forState:UIControlStateNormal];
    [self.view addSubview:_loginButton];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-164);
        make.size.mas_equalTo(CGSizeMake(250, 52));
    }];
    [self.loginButton addTarget:self action:@selector(enterHomeView) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 用户协议视图
    UIView *agreementView = [[UIView alloc] init];
    [self.view addSubview:agreementView];
    [agreementView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-50);
        make.size.mas_equalTo(CGSizeMake(180, 20));
    }];
    
    self.selectButton = [[UIButton alloc] init];
    [self.selectButton setImage:[UIImage imageNamed:@"icon_Set switch_nor"] forState:UIControlStateNormal];
    [self.selectButton setImage:[UIImage imageNamed:@"icon_Set switch_sel"] forState:UIControlStateSelected];
    [agreementView addSubview:_selectButton];
    
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(agreementView.mas_left);
        make.bottom.mas_equalTo(agreementView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    [self.selectButton addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    self.selectButton.selected = YES;

    self.userAgentButton = [[UIButton alloc] init];
    self.userAgentButton.titleLabel.font = QN_FONT_REGULAR(14);
    [self.userAgentButton setTitle:@"用户协议" forState:UIControlStateNormal];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"用户协议"];
    NSRange strRange = {0,4};
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [str addAttribute:NSForegroundColorAttributeName value:QN_COLOR_RGB(33, 166, 255, 1) range:strRange];

    [self.userAgentButton setAttributedTitle:str forState:UIControlStateNormal];
    [agreementView addSubview:_userAgentButton];
       
    [self.userAgentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(agreementView.mas_right);
        make.bottom.mas_equalTo(agreementView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(58, 21));
    }];
    [self.userAgentButton addTarget:self action:@selector(enterUserAgent) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *infolabel = [[UILabel alloc] init];
    infolabel.font = QN_FONT_REGULAR(14);
    infolabel.textColor = QN_COLOR_RGB(135, 135, 135, 1);
    infolabel.textAlignment = NSTextAlignmentCenter;
    infolabel.text = @"登录即表示同意";
    [infolabel sizeToFit];
    [agreementView addSubview:infolabel];
    [infolabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.userAgentButton.mas_left);
        make.bottom.mas_equalTo(agreementView.mas_bottom);
        make.height.mas_equalTo(20);
    }];
    
    // logo
    self.logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    [self.view addSubview:_logoImageView];
    
    CGFloat space = 10;
    if(QN_KSCREEN_HEIGHT > 568) {
        space = 50;
    }
    if(QN_KSCREEN_HEIGHT > 667) {
        space = 70;
    }
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.bottom.mas_equalTo(self.inputView.mas_top).mas_offset(-space);
        make.size.mas_equalTo(CGSizeMake(120, 120));
    }];
}

- (void)adjustColor {
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor grayColor];
            } else {
                return [UIColor darkGrayColor];
            }
        }];
        [_phoneTextField setValue:dyColor forKeyPath:@"placeholderLabel.textColor"];
        [_checkTextField setValue:dyColor forKeyPath:@"placeholderLabel.textColor"];
    }
}

# pragma mark -


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField isEqual:self.phoneTextField]) {
        if (textField.text.length >= 11) {
            if (string.length == 0) {
                return YES;
            } else{
                return NO;
            }
        } else{
            return YES;
        }
    } else{
        if (textField.text.length >= 6) {
            if (string.length == 0) {
                return YES;
            } else{
                return NO;
            }
        } else{
            return YES;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

# pragma mark - actions

- (void)selectAction:(UIButton *)button {
    button.selected = !button.selected;
}

- (void)enterUserAgent {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"user_agent" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    QNWebViewController *webViewController = [[QNWebViewController alloc] init];
    webViewController.url = url;
    webViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:webViewController animated:YES completion:nil];
}

- (void)getCode {
    QNSigleAlertView *sigleView = [[QNSigleAlertView alloc]init];
    if (self.phoneTextField.text.length == 0) {
        [sigleView showAlertViewTitle:@"请填写手机号码！" bgView:self.view];
        return;
    }
    
    if (self.phoneTextField.text.length < 11 || self.phoneTextField.text.length > 11) {
        [sigleView showAlertViewTitle:@"请填写正确的手机号码！" bgView:self.view];
        return;
    }
    
    [QNNetworkRequest requestWithUrl:QN_SEND_CODE(self.phoneTextField.text) requestType:QNRequestTypePost dic:nil header:nil success:^(NSDictionary * _Nonnull resultDic) {
        NSLog(@"QN_SEND_CODE resultDic --- %@", resultDic);
        if (resultDic.count == 0) {
            [sigleView showAlertViewTitle:@"发送成功！" bgView:self.view];
            self.countNumber = 300;
            self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(secondsCount) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        }
    } error:^(NSError * _Nonnull error) {
        NSLog(@"QN_SEND_CODE error --- %@", error);
        [sigleView showAlertViewTitle:[NSString stringWithFormat:@"获取验证码错误 %ld", (long)error.code] bgView:self.view];
    }];
}

- (void)enterHomeView {
    QNSigleAlertView *sigleView = [[QNSigleAlertView alloc]init];
    if (self.phoneTextField.text.length == 0 || self.checkTextField.text.length == 0) {
        [sigleView showAlertViewTitle:@"手机号码及验证码不能为空！" bgView:self.view];
        return;
    }
    if (!self.selectButton.selected) {
        [sigleView showAlertViewTitle:@"请勾选同意用户协议！" bgView:self.view];
        return;
    }
    
    [QNNetworkRequest requestWithUrl:QN_USE_CODE_LOGIN requestType:QNRequestTypePost dic:@{@"phoneNumber": self.phoneTextField.text, @"smsCode": self.checkTextField.text} header:nil success:^(NSDictionary * _Nonnull resultDic) {
        NSLog(@"QN_USE_CODE_LOGIN resultDic --- %@", resultDic);
        if ([resultDic.allKeys containsObject:@"gender"] &&
            [resultDic.allKeys containsObject:@"nickname"]) {
            
            [[NSUserDefaults standardUserDefaults] setObject:resultDic forKey:@"QN_USER_INFOMATION"];
            
            QNAppDelegate *appdelegate = (QNAppDelegate *)[UIApplication sharedApplication].delegate;
            if ([appdelegate.window.rootViewController isKindOfClass:[QNLoginViewController class]] == NO) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:resultDic];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateListView" object:resultDic];
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                QNHomeViewController *homeViewController = [[QNHomeViewController alloc] init];
                homeViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:homeViewController animated:YES completion:nil];
            }
        } else{
            if ([resultDic.allKeys containsObject:@"code"]) {
                NSInteger codeNumber = [resultDic[@"code"] integerValue];
                if (codeNumber == 401002) {
                    [sigleView showAlertViewTitle:@"验证码错误或已过期！" bgView:self.view];
                }
            }
        }
    } error:^(NSError * _Nonnull error) {
        NSLog(@"QN_USE_CODE_LOGIN error --- %@", error);
        QNSigleAlertView *sigleView = [[QNSigleAlertView alloc]init];
        [sigleView showAlertViewTitle:[NSString stringWithFormat:@"用户登录失败 %ld", (long)error.code] bgView:self.view];
    }];
}

# pragma mark - others

- (void)secondsCount {
    self.countNumber--;
    if (self.countNumber == 0) {
        self.getCodeButton.enabled = YES;
        [self.getCodeButton setTitle:@"重新发送" forState:UIControlStateNormal];
        [self.timer invalidate];
        self.timer = nil;
    } else {
        self.getCodeButton.enabled = NO;
        [self.getCodeButton setTitle:[NSString stringWithFormat:@"已发送 %ld s", self.countNumber] forState:UIControlStateNormal];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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
