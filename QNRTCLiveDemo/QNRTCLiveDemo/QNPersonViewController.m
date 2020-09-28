//
//  QNPersonViewController.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/7.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNPersonViewController.h"
#import "QNMyTableViewCell.h"
#import "QNWebViewController.h"
#import "QNAppDelegate.h"
#import "QNLoginViewController.h"

static NSString *cellIdentifier = @"MyTableViewCell";

@interface QNPersonViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
QNEditAlertViewDelegate
>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *userHeaderView;
@property (nonatomic, strong) UILabel *userLabel;
@property (nonatomic, strong) UIButton *editButton;

@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) NSArray *listArray;

@property (nonatomic, strong) QNEditAlertView *editAlertView;

@property (nonatomic, strong) NSDictionary *defaultDic;

@end

@implementation QNPersonViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateUserInfo" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.defaultDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"QN_USER_INFOMATION"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo:) name:@"updateUserInfo" object:nil];

    [self layoutInterface];
}

- (void)layoutInterface {
    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mine"]];
    _imageView.frame = CGRectMake(0, 0, QN_KSCREEN_WIDTH, QN_KSCREEN_WIDTH/1.4);
    _imageView.userInteractionEnabled = YES;
    [self.view addSubview:_imageView];
    
    _userHeaderView = [[UIImageView alloc] init];
    [_imageView addSubview:_userHeaderView];
    _userHeaderView.layer.cornerRadius = 52;
    _userHeaderView.clipsToBounds = YES;
    _userHeaderView.layer.borderWidth = 6;
    _userHeaderView.layer.borderColor = QN_COLOR_RGB(2, 104, 208, 1).CGColor;
    [_userHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.imageView.mas_top).offset(62);
        make.centerX.mas_equalTo(self.imageView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(104, 104));
    }];
    
    int value = arc4random() % 5;
    _userHeaderView.image = [UIImage imageNamed:[NSString stringWithFormat:@"img_avater_%d.png", value]];
    
    _userLabel = [[UILabel alloc] init];
    _userLabel.font = QN_FONT_REGULAR(16);
    _userLabel.textColor = [UIColor whiteColor];
    _userLabel.text = self.defaultDic[@"nickname"];
    [_imageView addSubview:_userLabel];
    [_userLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userHeaderView.mas_bottom).offset(23);
        make.centerX.mas_equalTo(self.userHeaderView.mas_centerX);
        make.height.mas_equalTo(22);
    }];
    
    _editButton = [[UIButton alloc] init];
    [_editButton setImage:[UIImage imageNamed:@"icon_edit_house"] forState:UIControlStateNormal];
    [_imageView addSubview:_editButton];
    [_editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.userLabel.mas_right).offset(8);
        make.centerY.mas_equalTo(self.userLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    [_editButton addTarget:self action:@selector(changeNickName:) forControlEvents:UIControlEventTouchUpInside];
    
    _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, QN_KSCREEN_WIDTH/1.4, QN_KSCREEN_WIDTH, QN_KSCREEN_HEIGHT - QN_KSCREEN_WIDTH/1.4) style:UITableViewStylePlain];
    _listTableView.backgroundColor = QN_COLOR_RGB(245, 246, 248, 1);
    _listTableView.delegate = self;
    _listTableView.dataSource = self;
    [_listTableView registerClass:[QNMyTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_listTableView];
    
    _listArray = @[@[@"七牛 RTC", @"用户协议", @"立即咨询"], @[@"退出登陆"]];
    
    _editAlertView = [[QNEditAlertView alloc] initWithFrame:self.view.bounds person:YES title:@"修改账号信息" text:self.defaultDic[@"nickname"]];
    _editAlertView.center = self.view.center;
    _editAlertView.delegate = self;
}

# pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _listArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = _listArray[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QNMyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray *array = _listArray[indexPath.section];
    cell.nameLabel.text = array[indexPath.row];
    if (indexPath.section == 0) {
        if (indexPath.row == 2) {
            cell.phoneLabel.hidden = NO;
        } else{
            cell.phoneLabel.hidden = YES;
        }
    } else{
        cell.phoneLabel.hidden = YES;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 0) {
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"QN_USER_INFOMATION"];

        [QNNetworkRequest requestWithUrl:QN_USER_EXIT requestType:QNRequestTypePost dic:nil header:[NSString stringWithFormat:@"Bearer %@", dic[@"token"]] success:^(NSDictionary * _Nonnull resultDic) {
            NSLog(@"QN_USER_EXIT resultDic --- %@", resultDic);
            if (resultDic.count == 0) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"QN_USER_INFOMATION"];
                QNAppDelegate *appdelegate = (QNAppDelegate *)[UIApplication sharedApplication].delegate;
                if ([appdelegate.window.rootViewController isKindOfClass:[QNLoginViewController class]] == YES) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else {
                    QNLoginViewController *loginViewController = [[QNLoginViewController alloc] init];
                    loginViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self presentViewController:loginViewController animated:YES completion:nil];
                }
            }
        } error:^(NSError * _Nonnull error) {
            NSLog(@"QN_USER_EXIT error --- %@", error);
        }];
    }
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            NSURL *url = [NSURL URLWithString:@"https://doc.qnsdk.com/rtn"];
            QNWebViewController *webViewController = [[QNWebViewController alloc] init];
            webViewController.url = url;
            webViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:webViewController animated:YES completion:nil];
        }
        if (indexPath.row == 1) {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"user_agent" ofType:@"html"];
            NSURL *url = [NSURL fileURLWithPath:filePath];
            QNWebViewController *webViewController = [[QNWebViewController alloc] init];
            webViewController.url = url;
            webViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:webViewController animated:YES completion:nil];
        }
        if (indexPath.row == 2) {
            NSString *telephoneNumber = @"4008089176";
            NSMutableString * str = [[NSMutableString alloc] initWithFormat:@"tel:%@",telephoneNumber];
            UIApplication *application = [UIApplication sharedApplication];
            NSURL *URL = [NSURL URLWithString:str];
            if (@available(iOS 10.0, *)) {
                [application openURL:URL options:@{} completionHandler:^(BOOL success) {
                    NSLog(@"拨打电话 success %d",success);
                }];
            } else{
                [application openURL:URL];
            }
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QN_KSCREEN_WIDTH, 18)];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 17.5, QN_KSCREEN_WIDTH, 0.5)];
        lineView.backgroundColor = QN_COLOR_RGB(151, 151, 151, 1);
        [headerView addSubview:lineView];
        return headerView;
    } else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 18;
    } else{
        return 0;
    }
}

- (void)editAlertView:(QNEditAlertView *)editAlertView didSelectedTitleIndex:(NSInteger)titleIndex text:(NSString *)text gender:(NSString *)gender {
    [_editAlertView removeFromSuperview];
    if (titleIndex == 1) {
        [QNNetworkRequest requestWithUrl:QN_UPDATE_PROFILE requestType:QNRequestTypePost dic:@{@"id":self.defaultDic[@"id"], @"nickname":text, @"gender":gender} header:[NSString stringWithFormat:@"Bearer %@", self.defaultDic[@"token"]] success:^(NSDictionary * _Nonnull resultDic) {
            NSLog(@"QN_UPDATE_PROFILE resultDic --- %@", resultDic);
            if ([resultDic.allKeys containsObject:@"nickname"]) {
                self.userLabel.text = resultDic[@"nickname"];
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.defaultDic];
                dic[@"gender"] = resultDic[@"gender"];
                dic[@"nickname"] = resultDic[@"nickname"];
                [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"QN_USER_INFOMATION"];
                self.defaultDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"QN_USER_INFOMATION"];
            }
        } error:^(NSError * _Nonnull error) {
            NSLog(@"QN_UPDATE_PROFILE error --- %@", error);
        }];
    }
}

# pragma mark - actions

- (void)changeNickName:(UIButton *)button {
    if (![self.view.subviews containsObject:_editAlertView]) {
        [self.view addSubview:_editAlertView];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)updateUserInfo:(NSNotification *)notification {
    NSDictionary *resultDic = notification.object;
    [[NSUserDefaults standardUserDefaults] setObject:resultDic forKey:@"QN_USER_INFOMATION"];
    self.defaultDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"QN_USER_INFOMATION"];
    _userLabel.text = self.defaultDic[@"nickname"];
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
