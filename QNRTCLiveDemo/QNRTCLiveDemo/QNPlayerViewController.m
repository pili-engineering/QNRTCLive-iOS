//
//  QNPlayerViewController.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/7.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNPlayerViewController.h"
// IM
#import "RCChatRoomView.h"
#import "RCChatroomWelcome.h"
#import "RCCRRongCloudIMManager.h"
#import "RCChatroomSignal.h"

static NSString *playStatus[] = {
    @"PLPlayerStatusUnknow",
    @"PLPlayerStatusPreparing",
    @"PLPlayerStatusReady",
    @"PLPlayerStatusOpen",
    @"PLPlayerStatusCaching",
    @"PLPlayerStatusPlaying",
    @"PLPlayerStatusPaused",
    @"PLPlayerStatusStopped",
    @"PLPlayerStatusError",
    @"PLPlayerStateAutoReconnecting",
    @"PLPlayerStatusCompleted"
};

static NSString *SIGNAL_STREAMER_SWITCH_TO_BACKGROUND = @"streamer_switch_to_backstage";

static NSString *SIGNAL_STREAMER_BACK_TO_LIVING = @"streamer_back_to_living";

@interface QNPlayerViewController ()
<
UIGestureRecognizerDelegate,
PLPlayerDelegate,
RCChatRoomViewDelegate
>

@property (nonatomic, strong) PLPlayer *player;
@property (nonatomic, strong) PLPlayerOption *playerOption;

@property (nonatomic, strong) UILabel *roomLabel;
@property (nonatomic, strong) UIButton *listButton;
@property (nonatomic, strong) UILabel *roomNumberLabel;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *exitButton;

@property (nonatomic, strong) NSDictionary *defaultDic;

@property (nonatomic, strong) NSTimer *timer;

// IM
@property (nonatomic, strong) RCChatRoomView * chatRoomView;
@property (nonatomic, strong) RCCRLiveModel * model;
@property (nonatomic, strong) UIImageView *backImage;

@property (nonatomic, strong) QNReachability *reachability;

@end

@implementation QNPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kQNReachabilityChangedNotification object:nil];
    
    self.reachability = [QNReachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    
    self.defaultDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"QN_USER_INFOMATION"];
    
    [self setupPlayer];
    
    [self layoutInterfaceView];
    
    self.timer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(updateAudienceCount) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    // IM
    [self setupIMUI];
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

# pragma mark - player

- (void)setupPlayer {
    self.playerOption = [PLPlayerOption defaultOption];
    self.player = [PLPlayer playerWithURL:[NSURL URLWithString:_dic[@"playURL"]] option:_playerOption];
    
    self.player.delegate = self;
    self.player.playerView.frame = self.view.bounds;
    self.player.playerView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.backImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"creator_leave_temporarily"]];
    self.backImage.frame = self.player.playerView.bounds;
        
    // 是否开启重连，默认为 NO
    self.player.autoReconnectEnable = YES;
    [self.view insertSubview:_player.playerView atIndex:0];
    
    NSLog(@"player start play %@",_dic[@"playURL"]);
    [self.player play];
}

#pragma mark - PLPlayerDelegate

/// 播放状态变化
- (void)player:(nonnull PLPlayer *)player statusDidChange:(PLPlayerStatus)state {
    NSLog(@"statusDidChange: %@", playStatus[state]);
    QNSigleAlertView *alertView = [[QNSigleAlertView alloc] init];
    if (state == PLPlayerStatusPreparing ||
        state == PLPlayerStatusReady ||
        state == PLPlayerStatusCaching) {

    } else{
        if (state != PLPlayerStateAutoReconnecting) {
            
        }
        if (state == PLPlayerStatusPlaying) {
           
        } else if (state == PLPlayerStatusPaused || state == PLPlayerStatusStopped) {

        } else if (state == PLPlayerStatusOpen) {

        } else if (state == PLPlayerStatusCompleted) {

        } else {
            if (state == PLPlayerStateAutoReconnecting) {
                [alertView showAlertViewTitle:@"播放自动重连中！" bgView:self.view];
            } else if (state == PLPlayerStatusError) {
                [alertView showAlertViewTitle:@"播放出现错误！" bgView:self.view];
            }
        }
    }
}

/// 播放发生错误的回调
- (void)player:(PLPlayer *)player stoppedWithError:(NSError *)error {
    QNSigleAlertView *alertView = [[QNSigleAlertView alloc] init];
    [alertView showAlertViewTitle:@"播放发生了错误！" bgView:self.view];
}

/// 点播已缓冲区域的回调
- (void)player:(nonnull PLPlayer *)player loadedTimeRange:(CMTime)timeRange {
    float durationSeconds = CMTimeGetSeconds(timeRange);
    NSString *string = [NSString stringWithFormat:@"durationSecods(%0.2f)", durationSeconds];
}

/// 即将进入后台播放任务的回调
- (void)playerWillBeginBackgroundTask:(PLPlayer *)player {
//    NSLog(@"begin background device orientation - %ld", [UIDevice currentDevice].orientation);
}

/// 即将结束后台播放状态任务的回调
- (void)playerWillEndBackgroundTask:(PLPlayer *)player {
//    NSLog(@"end background device orientation - %ld", [UIDevice currentDevice].orientation);
}

/// 回调要渲染的帧数据
- (void)player:(PLPlayer *)player willRenderFrame:(CVPixelBufferRef)frame pts:(int64_t)pts sarNumerator:(int)sarNumerator sarDenominator:(int)sarDenominator{
}

/// 回调音频数据
- (AudioBufferList *)player:(PLPlayer *)player willAudioRenderBuffer:(AudioBufferList *)audioBufferList asbd:(AudioStreamBasicDescription)audioStreamDescription pts:(int64_t)pts sampleFormat:(PLPlayerAVSampleFormat)sampleFormat {
    return audioBufferList;
}

/// 回调 SEI 数据
- (void)player:(nonnull PLPlayer *)player SEIData:(nullable NSData *)SEIData ts:(int64_t)ts {
//    NSString *SEIString = [self convertDataToHexStr:SEIData];
//    NSLog(@"SEIData string ------ %@", SEIString);
}

- (void)player:(PLPlayer *)player firstRender:(PLPlayerFirstRenderType)firstRenderType {
    NSString *type = (firstRenderType == PLPlayerFirstRenderTypeVideo ? @"video":@"audio");
}

/// 回调视频流宽高
- (void)player:(PLPlayer *)player width:(int)width height:(int)height {
    NSLog(@"-- width %d  height %d ---", width, height);
}

/// seekTo 完成的回调
- (void)playerSeekToCompleted:(PLPlayer *)player {
    NSLog(@"-- seekTo 完成的回调 ---");
}

- (void)layoutInterfaceView {
    CGFloat statusBarHeight = 20;
    if(QN_iPhoneX || QN_iPhoneXR || QN_iPhoneXSMAX) {
        statusBarHeight = 40;
    }

    _roomLabel = [[UILabel alloc] init];
    _roomLabel.textColor = [UIColor whiteColor];
    _roomLabel.font = QN_FONT_REGULAR(14);
    _roomLabel.textAlignment = NSTextAlignmentCenter;
    _roomLabel.text = self.dic[@"roomName"];
    [self.view addSubview:_roomLabel];
    [_roomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(self.view.mas_top).mas_offset(statusBarHeight);
        make.size.mas_equalTo(CGSizeMake(210, 52));
    }];
    
    self.listButton = [[UIButton alloc] init];
    [_listButton setImage:[UIImage imageNamed:@"icon_Audience"] forState:UIControlStateNormal];
    [self.view addSubview:_listButton];

    [_listButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).mas_offset(-20);
        make.top.mas_equalTo(self.view.mas_top).mas_offset(statusBarHeight);
        make.size.mas_equalTo(CGSizeMake(52, 52));
    }];
    
    _roomNumberLabel = [[UILabel alloc] init];
    _roomNumberLabel.textColor = [UIColor whiteColor];
    _roomNumberLabel.font = QN_FONT_REGULAR(12);
    _roomNumberLabel.textAlignment = NSTextAlignmentLeft;
    _roomNumberLabel.text = @"";
    [self.view addSubview:_roomNumberLabel];
    
    [_roomNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.listButton.mas_right).mas_offset(-5);
        make.bottom.mas_equalTo(self.listButton.mas_bottom).offset(-10);
        make.height.mas_equalTo(22);
    }];
    
    self.exitButton = [[UIButton alloc] init];
    [_exitButton setImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateNormal];
    [self.view addSubview:_exitButton];
    
    CGFloat bottomExtraDistance  = 20;
    if (@available(iOS 11.0, *)) {
        bottomExtraDistance = [self getIPhonexExtraBottomHeight];
    }
    [_exitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).mas_offset(-20);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-bottomExtraDistance);
        make.size.mas_equalTo(CGSizeMake(52, 52));
    }];
    [_exitButton addTarget:self action:@selector(getback) forControlEvents:UIControlEventTouchUpInside];
}

# pragma mark - actions

- (void)getback {
    [self.player stop];
    self.player.delegate = nil;
    self.player = nil;
    
    [_timer invalidate];
    _timer = nil;
    
    [self leaveRoom];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kQNReachabilityChangedNotification object:nil];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)leaveRoom {
    [QNNetworkRequest requestWithUrl:QN_LEAVE_LIVE_ROOM requestType:QNRequestTypePost dic:@{@"userID":self.defaultDic[@"id"], @"roomID":self.dic[@"roomID"]} header:[NSString stringWithFormat:@"Bearer %@", self.defaultDic[@"token"]] success:^(NSDictionary * _Nonnull resultDic) {
        NSLog(@"QN_LEAVE_LIVE_ROOM resultDic --- %@", resultDic);
    } error:^(NSError * _Nonnull error) {
        NSLog(@"QN_LEAVE_LIVE_ROOM error --- %@", error);
    }];
}

- (void)updateAudienceCount {
    [QNNetworkRequest requestWithUrl:QN_LIVE_ROOMID(self.dic[@"roomID"]) requestType:QNRequestTypeGet dic:nil header:[NSString stringWithFormat:@"Bearer %@", self.defaultDic[@"token"]] success:^(NSDictionary * _Nonnull resultDic) {
        NSLog(@"QN_LIVE_ROOMID resultDic --- %@", resultDic);
        
        if ([resultDic.allKeys containsObject:@"audienceNumber"]) {
            NSInteger audienceNumber = [resultDic[@"audienceNumber"] integerValue];
            if (audienceNumber == 0) {
                self.roomNumberLabel.text = @"";
            } else{
                self.roomNumberLabel.text = [NSString stringWithFormat:@"%@", resultDic[@"audienceNumber"]];
            }
        } else {
            if ([resultDic[@"code"] longValue] == 404002) {
                NSString *message = @"房间已关闭，直播结束啦！";
                NSString *title = @"确定";
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:title otherButtonTitles:nil];
                [alertView show];
                [self getback];
            }
        }
    } error:^(NSError * _Nonnull error) {
        NSLog(@"QN_LIVE_ROOMID error --- %@", error);
    }];
}

# pragma mark - IM

- (void)setupIMUI {
    CGFloat bottomExtraDistance  = 20;
    if (@available(iOS 11.0, *)) {
        bottomExtraDistance = [self getIPhonexExtraBottomHeight];
    }
    
    self.model = [[RCCRLiveModel alloc] init];
    self.model.audienceAmount = 0;
    self.model.fansAmount = 0;
    self.model.giftAmount = 0;
    self.model.praiseAmount = 0;
    self.model.attentionAmount = 0;
    self.model.liveMode = RCCRLiveModeAudience;
    self.model.roomId = self.dic[@"roomID"];
    self.model.pubUserId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
    self.chatRoomView = [[RCChatRoomView alloc] initWithFrame:CGRectMake(0,[UIScreen mainScreen].bounds.size.height - (237 +50)  - bottomExtraDistance,[UIScreen mainScreen].bounds.size.width, 237+50) model:self.model];
    self.chatRoomView.delegate = self;
    
    [self.view insertSubview:self.chatRoomView atIndex:1];
    UITapGestureRecognizer *resetBottomTapGesture =[[UITapGestureRecognizer alloc]
                                      initWithTarget:self
                                      action:@selector(resetBottomGesture:)];
             resetBottomTapGesture.delegate = self;
    [self.view addGestureRecognizer:resetBottomTapGesture];
    
    [QNNetworkRequest requestWithUrl:QN_IM_USER_TOKEN requestType:QNRequestTypePost dic:nil header:[NSString stringWithFormat:@"Bearer %@", self.defaultDic[@"token"]] success:^(NSDictionary * _Nonnull resultDic) {
        NSLog(@"QN_IM_USER_TOKEN resultDic --- %@", resultDic);
        if ([resultDic.allKeys containsObject:@"token"]) {
            [self joinChatRoomWithToken:resultDic[@"token"] userName:self.defaultDic[@"nickname"]];
        }
    } error:^(NSError * _Nonnull error) {
        NSLog(@"QN_IM_USER_TOKEN error --- %@", error);
    }];
}

- (float)getIPhonexExtraBottomHeight {
    float height = 20;
    if (@available(iOS 11.0, *)) {
        height = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets].bottom;
    }
    return height;
}

- (void)resetBottomGesture:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.chatRoomView setDefaultBottomViewStatus];
    }
}

/**
 拦截加在整个背景view上的点击手势
 
 @param gestureRecognizer UIGestureRecognizer
 @param touch UITouch
 @return BOOL
 */
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:self.chatRoomView.bottomBtnContentView] || [touch.view isDescendantOfView:self.chatRoomView.giftListView]) {
        return NO;
    }
    return YES;
}

- (void)joinChatRoomWithToken:(NSString *)token userName:(NSString *)userName {
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] connectRongCloudWithToken:token userName:userName success:^(NSString *userId) {
        dispatch_async(dispatch_get_main_queue(), ^{
             [[RCIMClient sharedRCIMClient] joinChatRoom:self.model.roomId messageCount:-1 success:^{
                 RCChatroomWelcome *joinChatroomMessage = [[RCChatroomWelcome alloc]init];
                 [joinChatroomMessage setId:[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].currentUserInfo.userId];
                 [self.chatRoomView sendMessage:joinChatroomMessage pushContent:nil success:nil error:nil];
             } error:^(RCErrorCode status) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.chatRoomView alertErrorWithTitle:@"提示" message:@"加入聊天室失败" ok:@"知道了"];
                 });
             }];
        });
    } error:^(RCConnectErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    } tokenIncorrect:^{
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    }];
}


-(void)didReceiveQuitMessageWithMessageModel:(RCCRMessageModel *)model {
    NSDictionary * creator = self.dic[@"creator"];
    // 主播退出房间
    if ([model.userInfo.userId isEqualToString:creator[@"id"]]) {
        NSString *message = @"房间已关闭，直播结束啦！";
        NSString *title = @"确定";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:title otherButtonTitles:nil];
        [alertView show];
        [self getback];
    }
}

-(void)didReceiveMessageUserBackground:(RCChatroomSignal *)model {
    NSDictionary * creator = self.dic[@"creator"];
    // 主播进入后台
    if ([model.senderUserInfo.userId isEqualToString:creator[@"id"]]) {
        if ([model.signal isEqualToString:SIGNAL_STREAMER_SWITCH_TO_BACKGROUND]) {
            [self.player.playerView addSubview:self.backImage];
        }else if ([model.signal isEqualToString:SIGNAL_STREAMER_BACK_TO_LIVING]){
            [self.backImage removeFromSuperview];
        }
        
    }
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
