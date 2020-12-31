//
//  QNListViewController.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/7.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNListViewController.h"
#import "QNPlayerListTableViewCell.h"
#import "QNPlayerViewController.h"
#import "QNAppDelegate.h"
#import "QNLoginViewController.h"
#import "QNAudioRoomViewController.h"

static NSString *cellIdentifier = @"PlayerListTableViewCell";

@interface QNListViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, strong) MJRefreshGifHeader *header;
@property (nonatomic, strong) UIButton *tintButton;
@end

@implementation QNListViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateListView" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateListView:) name:@"updateListView" object:nil];
    
    CGFloat navigationHeight = 64;
    CGFloat space = 10;
    if(QN_iPhoneX || QN_iPhoneXR || QN_iPhoneXSMAX ||
       QN_iPhone12Min || QN_iPhone12Pro || QN_iPhone12PMax) {
        navigationHeight = 88;
        space = 20;
    }
        
    self.tintButton = [[UIButton alloc] init];
    self.tintButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.tintButton.titleLabel.font = QN_FONT_REGULAR(15.0);
    [self.tintButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.tintButton setTitle:@"没有在直播的直播间，点我刷新！" forState:UIControlStateNormal];
    [self.tintButton addTarget:self action:@selector(refreshListViewData) forControlEvents:UIControlEventTouchUpInside];
    [self.tintButton sizeToFit];
    [self.view addSubview:_tintButton];
    [self.tintButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.view.mas_centerY);
    }];
        
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QN_KSCREEN_WIDTH, navigationHeight)];
    headerView.backgroundColor = QN_COLOR_RGB(30, 139, 255, 1);
    [self.view addSubview:headerView];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = QN_FONT_REGULAR(16.0);
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"首页";
    [titleLabel sizeToFit];
    [headerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(headerView.mas_centerX);
        make.centerY.mas_equalTo(headerView.mas_centerY).offset(space);
    }];
    
    self.header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshListViewData)];
    [self.header setTitle:@"正在刷新" forState:MJRefreshStateRefreshing];
    self.header.stateLabel.font = QN_FONT_LIGHT(12);
    self.header.lastUpdatedTimeLabel.font = QN_FONT_LIGHT(11);
    self.header.stateLabel.textColor = [UIColor blackColor];
    self.header.lastUpdatedTimeLabel.textColor = [UIColor blackColor];
   
    _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationHeight, QN_KSCREEN_WIDTH, QN_KSCREEN_HEIGHT - navigationHeight) style:UITableViewStylePlain];
    _listTableView.backgroundColor = [UIColor whiteColor];
    _listTableView.delegate = self;
    _listTableView.dataSource = self;
    [_listTableView registerClass:[QNPlayerListTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _listTableView.mj_header = self.header;
    [self.view addSubview:_listTableView];
    
    [self refreshListViewData];
}

- (void)refreshListViewData {
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"QN_USER_INFOMATION"];
    [self.listTableView.mj_header endRefreshing];
    [QNNetworkRequest requestWithUrl:QN_GET_LIVE_ROOMS requestType:QNRequestTypeGet dic:nil header:[NSString stringWithFormat:@"Bearer %@", dic[@"token"]] success:^(NSDictionary * _Nonnull resultDic) {
        NSLog(@"QN_GET_LIVE_ROOMS resultDic --- %@", resultDic);
        if ([resultDic.allKeys containsObject:@"rooms"]) {
            NSArray *array = [NSArray array];
            if ([resultDic[@"rooms"] isKindOfClass:[NSArray class]]) {
                array = resultDic[@"rooms"];
            }
            if (array.count == 0) {
                self.listTableView.hidden = YES;
                self.tintButton.hidden = NO;
                
                QNSigleAlertView *alertView = [[QNSigleAlertView alloc] init];
                [alertView showAlertViewTitle:@"没有正在直播的直播间" bgView:self.view];
            } else {
                self.listTableView.hidden = NO;
                self.tintButton.hidden = YES;
                self.listArray = [NSMutableArray arrayWithArray:array];
                [self.listTableView reloadData];
            }
        } else {
            if ([resultDic[@"code"] longValue] == 401003) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"QN_USER_INFOMATION"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"QN_USER_IM_TOKEN"];
                QNAppDelegate *appdelegate = (QNAppDelegate *)[UIApplication sharedApplication].delegate;
                if ([appdelegate.window.rootViewController isKindOfClass:[QNLoginViewController class]] == YES) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else {
                    QNLoginViewController *loginViewController = [[QNLoginViewController alloc] init];
                    loginViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self presentViewController:loginViewController animated:YES completion:nil];
                }
            }
        }
    } error:^(NSError * _Nonnull error) {
        NSLog(@"QN_GET_LIVE_ROOMS error --- %@", error);
        QNSigleAlertView *sigleView = [[QNSigleAlertView alloc]init];
        [sigleView showAlertViewTitle:[NSString stringWithFormat:@"获取直播列表失败 %ld", (long)error.code] bgView:self.view];
    }];
}

- (void)updateListView:(NSNotification *)notification {
    [self refreshListViewData];
}

# pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QNPlayerListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dic = _listArray[indexPath.row];
    [cell setParameterWithDic:dic];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 205.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = _listArray[indexPath.row];
    NSDictionary *defaultDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"QN_USER_INFOMATION"];

    [QNNetworkRequest requestWithUrl:QN_ENTER_ROOM requestType:QNRequestTypePost dic:@{@"userID":defaultDic[@"id"], @"roomID":dic[@"id"]} header:[NSString stringWithFormat:@"Bearer %@", defaultDic[@"token"]] success:^(NSDictionary * _Nonnull resultDic) {
        NSLog(@"QN_ENTER_ROOM resultDic --- %@", resultDic);
        if ([resultDic.allKeys containsObject:@"roomID"]) {
            if ([resultDic[@"roomType"] isEqualToString:@"voice"]) {
                // 观众进入语音房
                QNAudioRoomViewController *audioRoomViewController = [[QNAudioRoomViewController alloc]init];
                audioRoomViewController.isAdmin = NO;
                audioRoomViewController.resultDic = resultDic;
                audioRoomViewController.hidesBottomBarWhenPushed = YES;
                audioRoomViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:audioRoomViewController animated:YES completion:nil];
            } else{
                // 观众进入直播间
                QNPlayerViewController *playerViewController = [[QNPlayerViewController alloc] init];
                playerViewController.dic = resultDic;
                playerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:playerViewController animated:YES completion:nil];
            }
        } else {
            if ([resultDic[@"code"] longValue] == 404002) {
                QNSigleAlertView *alertView = [[QNSigleAlertView alloc] init];
                [alertView showAlertViewTitle:@"该直播房间已关闭，列表刷新啦～" bgView:self.view];
                [self refreshListViewData];
            }
        }
    } error:^(NSError * _Nonnull error) {
        NSLog(@"QN_ENTER_ROOM error --- %@", error);
        QNSigleAlertView *sigleView = [[QNSigleAlertView alloc]init];
        [sigleView showAlertViewTitle:[NSString stringWithFormat:@"进入直播间失败 %ld", (long)error.code] bgView:self.view];
    }];
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
