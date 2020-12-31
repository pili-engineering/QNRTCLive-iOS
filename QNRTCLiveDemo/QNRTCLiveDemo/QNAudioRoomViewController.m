//
//  QNAudioRoomViewController.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/12/9.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNAudioRoomViewController.h"

// IM
#import "RCChatRoomView.h"
#import "RCChatroomWelcome.h"
#import "RCCRRongCloudIMManager.h"

// UI
#import "QNAudioUserListView.h"
#import "QNDialogAlertView.h"
#import "RCChatroomUserQuit.h"
#import "QNVoiceCollectionViewCell.h"

#import "QNAudioUserModel.h"

static NSString *roomStatus[] = {
    @"QNRoomStateIdle",
    @"QNRoomStateConnecting",
    @"QNRoomStateConnected",
    @"QNRoomStateReconnecting",
    @"QNRoomStateReconnected"
};

#define QN_BOTTOM_BUTTON_WIDTH 52.0

const static NSTimeInterval kQNLiveWebSocketPingInterval = 5;
static NSString *cellIdentifier = @"AddAudioCollectionViewCell";

@interface QNAudioRoomViewController ()
<
QNRTCEngineDelegate,
UIGestureRecognizerDelegate,
// UI
QNEditAlertViewDelegate,
RCChatRoomViewDelegate,
UICollectionViewDelegate,
UICollectionViewDataSource,
QNDialogAlertViewDelegate
>

/// RTC
@property (nonatomic, strong) QNRTCEngine *engine;
@property (nonatomic, strong) NSString *token;

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *roomName;
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) NSString *createrId;
@property (nonatomic, copy) NSString *createrNickname;

@property (nonatomic, strong) QNTrackInfo *audioTrackInfo;
@property (nonatomic, assign) BOOL muteAudio;
@property (nonatomic, assign) BOOL muteSpeaker;

// 0 未进房间    1 语音直播
@property (nonatomic, assign) NSInteger audioState;
@property (nonatomic, strong) NSMutableArray *audioUserArray;

// UI
@property (nonatomic, copy) NSString *editRoomName;

@property (nonatomic, strong) NSDictionary *createResultDic;

@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UIButton *microphoneButtonView;
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UICollectionView *audioCollectionView;

@property (nonatomic, strong) UIButton *startAudioButton;

@property (nonatomic, strong) UIView *bottomButtonView;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *microphoneButton;
@property (nonatomic, strong) UIButton *speakerButton;
@property (nonatomic, strong) UIButton *stopButton;

@property (nonatomic, strong) NSMutableArray *userViewArray;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *lianmaiButton;
@property (nonatomic, strong) UIButton *listButton;

@property (nonatomic, strong) UILabel *roomNameLabel;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UILabel *roomNumberLabel;
@property (nonatomic, strong) QNAudioUserListView *audioListView;
@property (nonatomic, strong) NSMutableArray *listArray;

@property (nonatomic, strong) QNDialogAlertView *requestView;
@property (nonatomic, strong) QNDialogAlertView *resultAlertView;
@property (nonatomic, strong) QNEditAlertView *editAlertView;

@property (nonatomic, strong) NSDictionary *defaultDic;
@property (nonatomic, strong) QNReachability *reachability;

// IM
@property (nonatomic, strong) RCChatRoomView * chatRoomView;
@property (nonatomic, strong) RCCRLiveModel * model;

// IM signal
@property (nonatomic, strong) NSDate *lastSendTime;
@property (nonatomic, strong) NSDate *lastReceiveTime;
@property (nonatomic, strong) dispatch_source_t signalTimer;
@property (nonatomic, assign) NSInteger pongTimeout;
@property (nonatomic, strong) dispatch_queue_t operationQueue;

// 非主播，当前上麦的位置
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSDictionary *defaultAudioUserDic;

@property (nonatomic, assign) BOOL hasJoin;

@property (nonatomic, strong) QNSigleAlertView *alertContentView;

@end

@implementation QNAudioRoomViewController

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // 离开房间
    [self.engine leaveRoom];
        
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kQNReachabilityChangedNotification object:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kQNReachabilityChangedNotification object:nil];
    
    self.reachability = [QNReachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    
    self.defaultDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"QN_USER_INFOMATION"];
    self.userId = self.defaultDic[@"id"];
    self.roomName = [NSString stringWithFormat:@"%@的房间",self.defaultDic[@"nickname"]];
    
    if (self.isAdmin) {
        [QNNetworkRequest requestWithUrl:QN_GET_CREATE_ROOM(self.userId) requestType:QNRequestTypeGet dic:nil header:[NSString stringWithFormat:@"Bearer %@", self.defaultDic[@"token"]] success:^(NSDictionary * _Nonnull resultDic) {
            NSLog(@"QN_GET_CREATE_ROOM resultDic --- %@", resultDic);
            if (resultDic[@"rooms"] != [NSNull null]) {
                NSArray *array = resultDic[@"rooms"];
                self.roomId = array[0][@"id"];
                self.roomName = array[0][@"name"];

                if (self.roomNameLabel) {
                    self.roomNameLabel.text = self.roomName;
                }
            }
        } error:^(NSError * _Nonnull error) {
            NSLog(@"QN_GET_CREATE_ROOM error --- %@", error);
        }];
    } else{
        self.roomId = _resultDic[@"roomID"];
        self.roomName = _resultDic[@"roomName"];
    }
    
    self.listArray = [NSMutableArray array];
    self.alertContentView = [[QNSigleAlertView alloc] init];

    self.audioState = 0;
    self.audioUserArray = [NSMutableArray array];
    self.defaultAudioUserDic = @{@"position":@"", @"nickname":@"虚位以待", @"avatar":@"icon_add_audio", @"gender":@"", @"roomID":@"", @"reqUserID":@"", @"audioMute":@0};
    for (NSInteger i = 0; i < 8; i++) {
        QNAudioUserModel *model = [QNAudioUserModel configureAudioUserModelWithDic:self.defaultAudioUserDic];
        [self.audioUserArray addObject:model];
    }
    if (!_isAdmin) {
        // 标记观众端未上麦位置
        self.currentIndex = -1;
        self.hasJoin = NO;
        NSArray *array = _resultDic[@"joinedAudiences"];
        for (NSInteger i = 0; i < array.count; i++) {
            NSDictionary *dic = array[i];
            if ([dic[@"id"] isEqualToString:self.userId]) {
                self.hasJoin = YES;
            }
            [self updateAudioUserCollectionDic:dic];
        }
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_audio_bg"]];
    bgImageView.frame = self.view.bounds;
    [self.view addSubview:bgImageView];
    
    [self layoutInterfaceView];

    self.userViewArray = [[NSMutableArray alloc] init];
            
    [self initRTCEngine];
    
    // IM
    [self setupIMUI];
    
    // bottom button
    [self layoutBottomViews];

    // IM signal
    self.operationQueue = dispatch_queue_create("com.qiniu.qnrtcLive.operation", DISPATCH_QUEUE_SERIAL);
    
    if (!_isAdmin) {
        [self.engine joinRoomWithToken:_resultDic[@"rtcRoomToken"]];
    }
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

# pragma mark - QNRTC

- (void)initRTCEngine {
    [QNRTCEngine enableFileLogging];
    
    // 1.初始化 RTC 核心类 QNRTCEngine
    self.engine = [[QNRTCEngine alloc] init];
    // 2.设置 QNRTCEngineDelegate 状态回调的代理
    self.engine.delegate = self;
    // 3.开始采集
    [self.engine startCapture];
}

- (void)publish {
    QNTrackInfo *audioTrack = [[QNTrackInfo alloc] initWithSourceType:QNRTCSourceTypeAudio master:YES];
    // 4.只发布音频 track 可通过 QNTrackInfo 配置
    [self.engine publishTracks:@[audioTrack]];
}

/// QNRTCEngineDelegate
/**
 * SDK 运行过程中发生错误会通过该方法回调，具体错误码的含义可以见 QNTypeDefines.h 文件
 */
- (void)RTCEngine:(QNRTCEngine *)engine didFailWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didFailWithError: %@", error);
        NSString *errorMessage = error.localizedDescription;
        if (error.code == QNRTCErrorReconnectTokenError) {
            errorMessage = @"重新进入房间超时";
        }
        [self showAlertWithMessage:errorMessage title:@"错误" completionHandler:^{
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self dismissViewControllerAnimated:YES completion:^{
                [self getback];
            }];
        }];
    });
}

/**
 * 房间状态变更的回调。当状态变为 QNRoomStateReconnecting 时，SDK 会为您自动重连，如果希望退出，直接调用 leaveRoom 即可
 */
- (void)RTCEngine:(QNRTCEngine *)engine roomStateDidChange:(QNRoomState)roomState {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"roomStateDidChange: %@", roomStatus[roomState]);
        QNSigleAlertView *alertView = [[QNSigleAlertView alloc] init];
        if (QNRoomStateConnected == roomState) {
            [alertView showAlertViewTitle:@"加入房间成功" bgView:self.view];
            self.roomNumberLabel.text = [NSString stringWithFormat:@"%ld", self.engine.userList.count];
            if (self.isAdmin) {
                [self publish];
            } else{
                if (self.hasJoin) {
                    [self publish];
                }
            }
        } else if (QNRoomStateIdle == roomState) {
        } else if (QNRoomStateReconnecting == roomState) {
            [alertView showAlertViewTitle:@"正在重连..." bgView:self.view];
            self.microphoneButton.enabled = NO;
        } else if (QNRoomStateReconnected == roomState) {
            [alertView showAlertViewTitle:@"重连成功！" bgView:self.view];
            self.microphoneButton.enabled = YES;
        }
    });
}

/**
 * 远端用户重连成功的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didReconnectedRemoteUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didReconnectedRemoteUserId: %@", userId);
        NSString *nickName = @"";
        for (QNAudioUserModel *model in self.audioUserArray) {
            if ([userId isEqualToString:model.reqUserID]) {
                if (model.nickname.length != 0) {
                    nickName = model.nickname;
                }
                if (model.name.length != 0) {
                    nickName = model.name;
                }
            }
        }
        if (nickName.length != 0) {
            QNSigleAlertView *alertView = [[QNSigleAlertView alloc] init];
            [alertView showAlertViewTitle:[NSString stringWithFormat:@"远端用户 %@ 重连成功了", nickName] bgView:self.view];
        }
    });
}

/**
 * 远端用户发生重连的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didReconnectingRemoteUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didReconnectingRemoteUserId: %@", userId);
        NSString *nickName = @"";
        for (QNAudioUserModel *model in self.audioUserArray) {
            if ([userId isEqualToString:model.reqUserID]) {
                if (model.nickname.length != 0) {
                    nickName = model.nickname;
                }
                if (model.name.length != 0) {
                    nickName = model.name;
                }
            }
        }
        if (nickName.length != 0) {
            QNSigleAlertView *alertView = [[QNSigleAlertView alloc] init];
            [alertView showAlertViewTitle:[NSString stringWithFormat:@"远端用户 %@ 发生了重连", nickName] bgView:self.view];
        }
    });
}

/**
 * 调用 publish 发布本地音视频 tracks 后收到的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didPublishLocalTracks:(NSArray<QNTrackInfo *> *)tracks {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didPublishLocalTracks: %@", tracks);
        [self.engine muteAudio:self.muteAudio];
        [self.engine setMuteSpeaker:self.muteSpeaker];

        for (QNTrackInfo *trackInfo in tracks) {
            if (trackInfo.kind == QNTrackKindAudio) {
                self.audioTrackInfo = trackInfo;
            }
        }
        
        if (self.audioState == 0 && self.audioTrackInfo) {
            self.audioState = 1;

            if (self.isAdmin) {
                [self enterIMWithRequestToken];
                
                self.listButton.hidden = NO;
                self.lianmaiButton.hidden = NO;
                self.roomNumberLabel.hidden = NO;
                
                [self roomLabelIsCenter:NO];
                self.backButton.hidden = YES;
                self.editButton.hidden = YES;
            } else{
                self.chatRoomView.bottomBtnContentView.hidden = YES;
                
                for (QNAudioUserModel *model in self.audioUserArray) {
                    if ([model.nickname isEqualToString:self.defaultDic[@"nickname"]] ||
                        [model.name isEqualToString:self.defaultDic[@"nickname"]]) {
                        model.audioMute = @(self.muteAudio);
                    }
                }
                [self.audioCollectionView reloadData];
            }
            self.bottomButtonView.hidden = NO;
            
            NSDictionary *dic = @{@"userId":self.defaultDic[@"id"], @"audioMute": @(self.muteAudio), @"nickname":self.defaultDic[@"nickname"]};
            BOOL contain = NO;
            for (NSInteger i = 0; i < self.listArray.count; i++) {
                NSDictionary *currentDic = self.listArray[i];
                if ([currentDic[@"userId"] isEqualToString:dic[@"userId"]]) {
                    contain = YES;
                }
            }
            if (!contain) {
                if ([self.userId isEqualToString:self.createrId]) {
                    [self.listArray insertObject:dic atIndex:0];
                } else {
                    [self.listArray addObject:dic];
                }
            }
            [self.audioListView updateListArray:self.listArray];
            if (!self.isAdmin) {
                self.audioListView.exitButton.hidden = NO;
            }
        }
    });
}

/**
 * 远端用户加入房间的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didJoinOfRemoteUserId:(NSString *)userId userData:(NSString *)userData {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didJoinOfRemoteUserId: %@ userData: %@", userId, userData);
        self.roomNumberLabel.text = [NSString stringWithFormat:@"%ld", self.engine.userList.count];
    });
}

/**
 * 远端用户发布音/视频的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didPublishTracks:(NSArray<QNTrackInfo *> *)tracks ofRemoteUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didPublishTracks: %@ ofRemoteUserId: %@", tracks, userId);
        for (QNTrackInfo *info in tracks) {
            if (info.kind == QNTrackKindAudio) {
                NSString *nickName = @"";
                for (QNAudioUserModel *model in self.audioUserArray) {
                    if ([model.reqUserID isEqualToString:userId]) {
                        if (model.nickname.length != 0) {
                            nickName = model.nickname;
                        }
                        if (model.name.length != 0) {
                            nickName = model.name;
                        }
                    }
                }
                NSDictionary *receiveDic = @{@"userId":userId, @"audioMute": @(info.muted), @"nickname": nickName};
                BOOL contain = NO;
                for (NSInteger i = 0; i < self.listArray.count; i++) {
                    NSDictionary *currentDic = self.listArray[i];
                    if ([currentDic[@"userId"] isEqualToString:receiveDic[@"userId"]]) {
                        contain = YES;
                    }
                }
                if (!contain) {
                    if ([userId isEqualToString:self.createrId]) {
                        [self.listArray insertObject:receiveDic atIndex:0];
                    } else {
                        [self.listArray addObject:receiveDic];
                    }
                }
                [self.audioListView updateListArray:self.listArray];
                
                [self reloadUser:userId muted:info.muted];
            }
        }
    });
}

/**
 * 调用 subscribe 订阅 userId 成功后收到的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didSubscribeTracks:(NSArray<QNTrackInfo *> *)tracks ofRemoteUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didSubscribeTracks: %@ ofRemoteUserId: %@", tracks, userId);
    });
}

/**
 * 远端用户视频首帧解码后的回调，如果需要渲染，则需要返回一个带 renderView 的 QNVideoRender 对象
 */
- (QNVideoRender *)RTCEngine:(QNRTCEngine *)engine firstVideoDidDecodeOfTrackId:(NSString *)trackId remoteUserId:(NSString *)userId {
    NSLog(@"firstVideoDidDecodeOfTrackId: %@ remoteUserId: %@", trackId, userId);
    return nil;
}

/**
 * 远端用户音频状态变更为 muted 的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didAudioMuted:(BOOL)muted ofTrackId:(NSString *)trackId byRemoteUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didAudioMuted: %d ofTrackId: %@ byRemoteUserId: %@", muted, trackId, userId);
        [self reloadUser:userId muted:muted];
    });
}

/**
 * 远端用户视频状态变更为 muted 的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didVideoMuted:(BOOL)muted ofTrackId:(NSString *)trackId byRemoteUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didVideoMuted: %d ofTrackId: %@ byRemoteUserId: %@", muted, trackId, userId);
    });
}

/**
 * 远端用户视频取消渲染到 renderView 上的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didDetachRenderView:(UIView *)renderView ofTrackId:(NSString *)trackId remoteUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didDetachRenderView: %@ ofTrackId: %@ remoteUserId: %@", renderView, trackId, userId);
    });
}

/**
 * 远端用户取消发布音/视频的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didUnPublishTracks:(NSArray<QNTrackInfo *> *)tracks ofRemoteUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didUnPublishTracks: %@ ofRemoteUserId: %@", tracks, userId);
    });
}

/**
 * 被 userId 踢出的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didKickoutByUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didKickoutByUserId: %@", userId);
    });
}

/**
 * 远端用户离开房间的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didLeaveOfRemoteUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didLeaveOfRemoteUserId: %@", userId);
        self.roomNumberLabel.text = [NSString stringWithFormat:@"%ld", self.engine.userList.count];
        NSString *nickName = @"";
        for (QNAudioUserModel *model in self.audioUserArray) {
            if ([userId isEqualToString:model.reqUserID]) {
                if (model.nickname.length != 0) {
                    nickName = model.nickname;
                }
                if (model.name.length != 0) {
                    nickName = model.name;
                }
            }
        }
        if (nickName.length != 0) {
            QNSigleAlertView *alertView = [[QNSigleAlertView alloc] init];
            [alertView showAlertViewTitle:[NSString stringWithFormat:@"%@ 已离开房间", nickName] bgView:self.view];
        }
    });
}

/**
 * 本地用户离开房间的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didLeaveOfLocalSuccess:(BOOL)success {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didLeaveOfLocalSuccess: %d", success);
    });
}

/**
 * 收到自定义消息的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didReceiveMessage:(QNMessageInfo *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didReceiveMessage: %@", message);
    });
}

/**
 * 麦克风音频元数据的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine microphoneSourceDidGetAudioBuffer:(AudioBuffer *)audioBuffer asbd:(const AudioStreamBasicDescription *)asbd {
    dispatch_async(dispatch_get_main_queue(), ^{

    });
}

/**
 * 摄像头视频元数据的回调，用于滤镜等特效处理，建议在主线程执行
 */
- (void)RTCEngine:(QNRTCEngine *)engine cameraSourceDidGetSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    dispatch_async(dispatch_get_main_queue(), ^{

    });
}

# pragma mark - IM

- (void)setupIMUI {
    CGFloat bottomExtraDistance  = 0;
    if (!self.isAdmin) {
        bottomExtraDistance  = 20;
    }
    if (@available(iOS 11.0, *)) {
        bottomExtraDistance = [self getIPhonexExtraBottomHeight];
    }
    
    self.model = [[RCCRLiveModel alloc] init];
    self.model.audienceAmount = 0;
    self.model.fansAmount = 0;
    self.model.giftAmount = 0;
    self.model.praiseAmount = 0;
    self.model.attentionAmount = 0;
    if (self.isAdmin) {
        self.model.liveMode = RCCRLiveModeHost;
    } else {
        if (self.resultDic) {
            self.model.roomId = self.resultDic[@"roomID"];
            self.model.liveMode = RCCRLiveModeAudience;
        }
    }
    self.model.pubUserId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;

    CGFloat height = QN_KSCREEN_HEIGHT;
    if (height <= 667) {
        height = 187 + 50;
    } else {
        height = 237 + 50;
    }
    self.chatRoomView = [[RCChatRoomView alloc] initWithFrame:CGRectMake(0, QN_KSCREEN_HEIGHT - height  - bottomExtraDistance, QN_KSCREEN_WIDTH, height) model:self.model];
    self.chatRoomView.delegate = self;
    if (self.isAdmin) {
        self.chatRoomView.commentBtn = self.commentButton;
    } else{
        [self enterIMWithRequestToken];
    }

    UITapGestureRecognizer *resetBottomTapGesture =[[UITapGestureRecognizer alloc]
                                      initWithTarget:self
                                      action:@selector(resetBottomGesture:)];
    resetBottomTapGesture.delegate = self;
    [self.view addGestureRecognizer:resetBottomTapGesture];
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
    } else if ([touch.view isDescendantOfView:self.audioCollectionView]) {
        return NO;
    }
    return YES;
}

- (void)joinChatRoomWithToken:(NSString *)token userName:(NSString *)userName avatar:(NSString *)avatar {
    [self.view insertSubview:self.chatRoomView atIndex:3];
    [self.chatRoomView.closeButton addTarget:self action:@selector(getback) forControlEvents:UIControlEventTouchUpInside];

    self.model.roomId = self.roomId;
    
    RCConnectionStatus status = [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] getRongCloudConnectionStatus];
    if (status != ConnectionStatus_Connected) {
        [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] connectRongCloudWithToken:token userName:userName portraitUri:avatar success:^(NSString *userId) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[RCIMClient sharedRCIMClient] joinChatRoom:self.model.roomId messageCount:-1 success:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        RCChatroomWelcome *joinChatroomMessage = [[RCChatroomWelcome alloc]init];
                        [joinChatroomMessage setId:self.userId];
                        [self.chatRoomView sendMessage:joinChatroomMessage pushContent:nil success:^(long messageId) {
                            [self startTimer];
                        } error:^(RCErrorCode nErrorCode, long messageId) {
                            NSLog(@"joinChatroomMessage nErrorCode: %ld messageId: %ld", nErrorCode, messageId);
                        }];
                    });
                } error:^(RCErrorCode status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.chatRoomView alertErrorWithTitle:@"提示" message:@"加入聊天室失败" ok:@"知道了"];
                    });
                }];
            });
        } error:^(RCConnectErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"status --- %ld", status);
            });
        } tokenIncorrect:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"tokenIncorrect");
            });
        }];
    } else {
        [[RCIMClient sharedRCIMClient] joinChatRoom:self.model.roomId messageCount:-1 success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                RCChatroomWelcome *joinChatroomMessage = [[RCChatroomWelcome alloc]init];
                [joinChatroomMessage setId:self.userId];
                [self.chatRoomView sendMessage:joinChatroomMessage pushContent:nil success:^(long messageId) {
                    [self startTimer];
                } error:^(RCErrorCode nErrorCode, long messageId) {
                    NSLog(@"joinChatroomMessage nErrorCode: %ld messageId: %ld", nErrorCode, messageId);
                }];
            });
        } error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.chatRoomView alertErrorWithTitle:@"提示" message:@"加入聊天室失败" ok:@"知道了"];
            });
        }];
    }
}
# pragma mark - views

- (void)layoutInterfaceView {
    CGFloat statusBarHeight = 20;
    if(QN_iPhoneX || QN_iPhoneXR || QN_iPhoneXSMAX ||
       QN_iPhone12Min || QN_iPhone12Pro || QN_iPhone12PMax) {
        statusBarHeight = 40;
    }
    
    _roomNameLabel = [[UILabel alloc] init];
    _roomNameLabel.textColor = [UIColor whiteColor];
    _roomNameLabel.font = QN_FONT_REGULAR(14);
    _roomNameLabel.textAlignment = NSTextAlignmentCenter;
    _roomNameLabel.text = self.roomName;
    [self.view addSubview:_roomNameLabel];
    
    [self roomLabelIsCenter:self.isAdmin];
    
    _editButton = [[UIButton alloc] init];
    [_editButton setImage:[UIImage imageNamed:@"icon_edit_house"] forState:UIControlStateNormal];
    [self.view addSubview:_editButton];
    [_editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.roomNameLabel.mas_right).offset(8);
        make.centerY.mas_equalTo(self.roomNameLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    [_editButton addTarget:self action:@selector(changeRoomName:) forControlEvents:UIControlEventTouchUpInside];
    
    self.startAudioButton = [[UIButton alloc] init];
    [self.startAudioButton setBackgroundImage:[UIImage imageNamed:@"icon_button_bg"] forState:UIControlStateNormal];
    [self.startAudioButton setTitle:@"开始语音连麦" forState:UIControlStateNormal];
    self.startAudioButton.titleLabel.textColor = [UIColor whiteColor];
    self.startAudioButton.titleLabel.font = QN_FONT_MEDIUM(16);
    self.startAudioButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_startAudioButton];
       
    [_startAudioButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-118);
        make.size.mas_equalTo(CGSizeMake(186, 52));
    }];
    [_startAudioButton addTarget:self action:@selector(startAudioAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.listButton = [[UIButton alloc] init];
    [_listButton setImage:[UIImage imageNamed:@"icon_Audience"] forState:UIControlStateNormal];
    [self.listButton addTarget:self action:@selector(audienceAction:) forControlEvents:UIControlEventTouchUpInside];
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
    
    self.lianmaiButton = [[UIButton alloc] init];
    [_lianmaiButton setImage:[UIImage imageNamed:@"icon_Lianmai"] forState:UIControlStateNormal];
    [self.view addSubview:_lianmaiButton];

    [_lianmaiButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).mas_offset(-72);
        make.top.mas_equalTo(self.view.mas_top).mas_offset(statusBarHeight);
        make.size.mas_equalTo(CGSizeMake(52, 52));
    }];
    [_lianmaiButton addTarget:self action:@selector(enterAudioListView) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.isAdmin) {
        self.listButton.hidden = YES;
        self.lianmaiButton.hidden = YES;
        self.roomNumberLabel.hidden = YES;
    } else{
        _editButton.hidden = YES;
        _startAudioButton.hidden = YES;
    }
    
    if (self.isAdmin) {
        self.backButton = [[UIButton alloc] init];
        [_backButton setImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateNormal];
        [self.view addSubview:_backButton];
              
        [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view.mas_left).mas_offset(20);
            make.top.mas_equalTo(self.view.mas_top).mas_offset(statusBarHeight);
            make.size.mas_equalTo(CGSizeMake(52, 52));
        }];
        [_backButton addTarget:self action:@selector(getback) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.headerImageView = [[UIImageView alloc] init];
    self.headerImageView.backgroundColor = [UIColor whiteColor];
    self.headerImageView.clipsToBounds = YES;
    self.headerImageView.layer.cornerRadius = 36;
    self.headerImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_default_avator.png"]];
    [self.view addSubview:_headerImageView];
    [_headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX).mas_offset(0);
        make.top.mas_equalTo(self.view.mas_top).mas_offset(100);
        make.size.mas_equalTo(CGSizeMake(72, 72));
    }];
    
    self.microphoneButtonView = [[UIButton alloc] init];
    [self.microphoneButtonView setImage:[UIImage imageNamed:@"icon_Voice status"] forState:UIControlStateNormal];
    [self.microphoneButtonView setImage:[UIImage imageNamed:@"icon_Closed wheat state"] forState:UIControlStateSelected];
    [self.headerImageView addSubview:_microphoneButtonView];
    [_microphoneButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headerImageView.mas_left).mas_offset(45);
        make.top.mas_equalTo(self.headerImageView.mas_top).mas_offset(45);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.font = QN_FONT_REGULAR(12);
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.headerImageView.mas_centerX).mas_offset(0);
        make.top.mas_equalTo(self.headerImageView.mas_bottom).mas_offset(5);
        make.size.mas_equalTo(CGSizeMake(100, 28));
    }];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumLineSpacing = 2;
    flowLayout.minimumInteritemSpacing = 2;
    flowLayout.itemSize = CGSizeMake(78, 98);
    self.audioCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 320, 190) collectionViewLayout:flowLayout];
    self.audioCollectionView.backgroundColor = [UIColor clearColor];
    self.audioCollectionView.delegate = self;
    self.audioCollectionView.dataSource = self;
    self.audioCollectionView.scrollEnabled = NO;
    [self.audioCollectionView registerClass:[QNVoiceCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    [self.view addSubview:_audioCollectionView];
    [_audioCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).mas_offset(20);
        make.size.mas_equalTo(CGSizeMake(320, 190));
    }];
    
    [self.view insertSubview:_audioCollectionView atIndex:1];
    
    NSString *imageString = self.defaultDic[@"avatar"];
    NSString *name = self.defaultDic[@"nickname"];
    NSString *createrId = self.defaultDic[@"id"];
    if (!self.isAdmin) {
        imageString = _resultDic[@"creator"][@"avatar"];
        name = _resultDic[@"creator"][@"nickname"];
        createrId = _resultDic[@"creator"][@"id"];
    }
    
    if (imageString.length != 0) {
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:imageString]];
    }
    self.nameLabel.text = name;
    self.createrId = createrId;
    self.createrNickname = name;
    [self readyUIView];
}

- (void)layoutBottomViews {
    self.bottomButtonView = [[UIView alloc] init];
    [self.view addSubview:self.bottomButtonView];
        
    UIButton* buttons[5];
    NSString *selectedImage[] = {
        @"icon_chat",
        @"icon_mic_close",
        @"icon_close_loudspeaker",
        @"icon_close"
    };
    NSString *normalImage[] = {
        @"icon_chat",
        @"icon_Lianmai Interactive",
        @"icon_loudspeaker",
        @"icon_close"
    };
    SEL selectors[] = {
        @selector(commentAction:),
        @selector(microphoneButtonClick:),
        @selector(speakerAction:),
        @selector(leaveAction:),
    };
    
    UIView *preView = nil;
    for (int i = 0; i < ARRAY_SIZE(normalImage); i ++) {
        buttons[i] = [[UIButton alloc] init];
        [buttons[i] setImage:[UIImage imageNamed:selectedImage[i]] forState:(UIControlStateSelected)];
        [buttons[i] setImage:[UIImage imageNamed:normalImage[i]] forState:(UIControlStateNormal)];
        [buttons[i] addTarget:self action:selectors[i] forControlEvents:(UIControlEventTouchUpInside)];
        [self.bottomButtonView addSubview:buttons[i]];
    }
    int index = 0;
    _commentButton = buttons[index ++];
    _microphoneButton = buttons[index ++];
    _speakerButton = buttons[index ++];
    _stopButton = buttons[index ++];

    CGFloat buttonWidth = QN_BOTTOM_BUTTON_WIDTH;
    NSInteger space = (UIScreen.mainScreen.bounds.size.width - buttonWidth * 4)/4;
    
    NSArray *array = [NSArray arrayWithObjects:buttons count:4];
    [array mas_distributeViewsAlongAxis:(MASAxisTypeHorizontal) withFixedItemLength:buttonWidth leadSpacing:space tailSpacing:space];
    [array mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(QN_BOTTOM_BUTTON_WIDTH);
        make.bottom.mas_equalTo(self.bottomButtonView.mas_bottom);
    }];
    preView = buttons[0];
    [self.bottomButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-20);
        make.height.mas_equalTo(QN_BOTTOM_BUTTON_WIDTH);
    }];
    self.bottomButtonView.hidden = YES;
}

- (void)readyUIView {
    if (!self.isAdmin) {
        self.audioListView = [[QNAudioUserListView alloc] initWithFrame:CGRectMake(0, QN_KSCREEN_HEIGHT, QN_KSCREEN_WIDTH, 300) listArray:[NSMutableArray array] state:1];
        [self.audioListView.exitButton addTarget:self action:@selector(stopLianmai:) forControlEvents:UIControlEventTouchUpInside];
        
        self.requestView = [[QNDialogAlertView alloc] initWithFrame:CGRectMake(0, 0, 300, 200) title:@"连麦互动" request:YES content:@"想要上麦玩耍吗" buttonArray:@[@"再想想", @"是的"]];
        self.requestView.center = self.view.center;
        self.requestView.delegate = self;
    } else{
        self.audioListView = [[QNAudioUserListView alloc] initWithFrame:CGRectMake(0, QN_KSCREEN_HEIGHT, QN_KSCREEN_WIDTH, 300) listArray:[NSMutableArray array] state:0];
    }
    
    [self.audioListView setAdminUserId:self.createrId];
    _editAlertView = [[QNEditAlertView alloc] initWithFrame:self.view.bounds person:NO title:@"修改房间名" text:self.roomName];
    _editAlertView.delegate = self;
}

# pragma mark - collection delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.audioUserArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QNVoiceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    QNAudioUserModel *model = self.audioUserArray[indexPath.row];
    NSString *name;
    if (model.nickname && model.nickname.length != 0) {
        name = model.nickname;
    }
    if (model.name && model.name.length != 0) {
        name = model.name;
    }
    NSString *imageString = @"icon_default_avator.png";
    if (model.avatar && model.avatar.length != 0) {
        imageString = model.avatar;
    }
    BOOL muteAudio = NO;
    if (model.audioMute != NULL) {
        muteAudio = [model.audioMute boolValue];
    }
    [cell configurateCollectionViewCell:model.nickname avatar:imageString state:muteAudio];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectItemAtIndexPath ---------");
    if (self.audioState == 1) {
        QNSigleAlertView *alertView = [[QNSigleAlertView alloc] init];
        [alertView showAlertViewTitle:@"您已上麦！" bgView:self.view];
    } else {
        if (!self.isAdmin) {
            [self hideAllUIView];
            self.currentIndex = indexPath.row;
            // 发送上麦请求
            [self.view addSubview:_requestView];
        } else {
            QNSigleAlertView *alertView = [[QNSigleAlertView alloc] init];
            [alertView showAlertViewTitle:@"请先开始语音连麦！" bgView:self.view];
        }
    }
}

# pragma mark - actions

- (void)startAudioAction:(UIButton *)startButton {
    [self.alertContentView addAlertContent:@"开启直播中..." bgView:self.view];
    _startAudioButton.selected = YES;
    self.startAudioButton.hidden = YES;
    [self createAudioRoomAccordingSituation];
}

- (void)audienceAction:(UIButton *)listButton {
    QNSigleAlertView *sigleView = [[QNSigleAlertView alloc]init];
    NSString *number = @"0";
    if (![self.roomNumberLabel.text isEqualToString:@""]) {
        number = self.roomNumberLabel.text;
    }
    NSString * audienceNote = [NSString stringWithFormat:@"当前观看（包括上麦观众）人数: %@人",number];
    [sigleView showAlertViewTitle:audienceNote bgView:self.view];
}


- (void)commentAction:(UIButton *)beautyButton {
    if ([[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] isLogin]) {
        [self.chatRoomView.inputBar setHidden:NO];
        [self.chatRoomView.inputBar  setInputBarStatus:RCCRBottomBarStatusKeyboard];
        self.chatRoomView.isSendDanmaku = NO;
    } else {
        NSLog(@"IM 未登录！");
    }
}

- (void)microphoneButtonClick:(UIButton *)button {
    self.muteAudio = !self.muteAudio;
    button.selected = self.muteAudio;
    [self.engine muteAudio:self.muteAudio];
    [self reloadUser:self.userId muted:self.muteAudio];
}

- (void)speakerAction:(UIButton *)button {
    self.muteSpeaker = !self.muteSpeaker;
    button.selected = self.muteSpeaker;
    [self.engine setMuteSpeaker:self.muteSpeaker];
}

- (void)leaveAction:(UIButton *)stopButton {
    if (!self.isAdmin && self.audioState == 1) {
        [self endJoin:self.roomId reqUserID:self.userId];
    }
    
    [self.chatRoomView removeFromSuperview];
    [self getback];
}

- (void)enterAudioListView {
    [self.audioListView updateListArray:_listArray];
    if (self.audioListView.state == 1) {
        self.audioListView.exitButton.hidden = !self.audioState;
    }
    [self.view addSubview:_audioListView];
    [UIView animateWithDuration:0.2 animations:^{
        self.audioListView.frame = CGRectMake(0, QN_KSCREEN_HEIGHT - 300, QN_KSCREEN_WIDTH, 300);
    }];
}

- (void)changeRoomName:(UIButton *)button {
    if (![self.view.subviews containsObject:_editAlertView]) {
        [self.view addSubview:_editAlertView];
    }
}

- (void)getback {
    self.audioState = 0;
    [self.engine unpublishAudio];
    [self.engine leaveRoom];
    
    RCChatroomUserQuit *quitChatroomMessage = [[RCChatroomUserQuit alloc]init];
    [quitChatroomMessage setId:self.userId];
    [self.chatRoomView sendMessage:quitChatroomMessage pushContent:nil success:^(long messageId) {
        [self stopTimer];
    } error:^(RCErrorCode nErrorCode, long messageId) {
        NSLog(@"quitChatroomMessage nErrorCode: %ld messageId: %ld", nErrorCode, messageId);
    }];

    [self disconnect];
    self.engine = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)stopLianmai:(UIButton *)button {
    [self hideAllUIView];
    if (!self.isAdmin) {
        [self endJoin:self.roomId reqUserID:self.userId];
        [self.engine unpublishAudio];
        [self removeUser:self.userId];
        self.bottomButtonView.hidden = YES;
        self.chatRoomView.bottomBtnContentView.hidden = NO;
    }
}

#pragma mark - QNDialogAlertViewDelegate
- (void)alertView:(QNDialogAlertView *)alertView didSelectedTitleIndex:(NSInteger)titleIndex {
    NSLog(@"alertView - titleIndex: %ld", titleIndex);
    
    if ([alertView isEqual:_requestView]) {
        [_requestView hideAlertView];
        BOOL want;
        if (titleIndex == 1) {
            want = YES;
            if (self.currentIndex >= 0) {
                [self startJoin:self.roomId position:self.currentIndex];
            }
        } else{
            want = NO;
            self.currentIndex = -1;
        }
    } else {
        [alertView hideAlertView];
        BOOL accept;
        if (titleIndex == 1) {
            accept = YES;
            [self updateAudioUserCollectionDic:alertView.requestDic];
        } else{
            accept = NO;
        }
        [self answerJoin:alertView.requestDic[@"roomID"] reqUserID:alertView.requestDic[@"reqUserID"] accept:accept];
    }
}

# pragma mark - QNEditAlertViewDelegate

- (void)editAlertView:(QNEditAlertView *)editAlertView didSelectedTitleIndex:(NSInteger)titleIndex text:(NSString *)text gender:(NSString *)gender {
    NSLog(@"editAlertView - titleIndex: %ld text: %@ gender: %@", titleIndex, text, gender);
    [_editAlertView removeFromSuperview];
    
    if (titleIndex == 1) {
        self.editRoomName = text;
        self.roomNameLabel.text = self.editRoomName;
    } else{
        self.editRoomName = @"";
    }
}

# pragma mark - audio user array manager

- (void)updateAudioUserCollectionDic:(NSDictionary *)dic {
    QNAudioUserModel *model = [QNAudioUserModel configureAudioUserModelWithDic:dic];
    if (model.reqUserID.length == 0 && dic[@"id"]) {
        model.reqUserID = dic[@"id"];
    }
    NSInteger index = [model.position integerValue];
    [self.audioUserArray replaceObjectAtIndex:index withObject:model];
    [self.audioCollectionView reloadData];
}

- (void)reloadUser:(NSString *)userId muted:(BOOL)muted {
    NSMutableDictionary *lastDic = [NSMutableDictionary dictionaryWithDictionary:@{@"userId":userId, @"audioMute": @(muted)}];
    NSString *nickName = @"";
    if ([userId isEqualToString:self.createrId]) {
        self.microphoneButtonView.selected = muted;
        nickName = self.createrNickname;
    } else{
        for (NSInteger i = 0; i < self.audioUserArray.count; i++) {
            QNAudioUserModel *model = self.audioUserArray[i];
            if ([model.reqUserID isEqualToString:userId]) {
                model.audioMute = @(muted);
                if (model.nickname.length != 0) {
                    nickName = model.nickname;
                }
                if (model.name.length != 0) {
                    nickName = model.name;
                }
            }
        }
        [self.audioCollectionView reloadData];
    }

    [lastDic setValue:nickName forKey:@"nickname"];
    NSArray *listArray = [self.listArray copy];
    for (NSInteger i = 0; i < listArray.count; i++) {
        NSDictionary *dic = listArray[i];
        if ([dic[@"userId"] isEqualToString:userId]) {
            [self.listArray replaceObjectAtIndex:i withObject:lastDic];
        }
    }
    [self.audioListView updateListArray:_listArray];
}

- (void)removeUser:(NSString *)userId {
    NSArray *userArray = [self.audioUserArray copy];
    for (QNAudioUserModel *userModel in userArray) {
        if ([userModel.reqUserID isEqualToString:userId]) {
            NSInteger index = [userModel.position integerValue];
            QNAudioUserModel *defaultModel = [QNAudioUserModel configureAudioUserModelWithDic:self.defaultAudioUserDic];
            [self.audioUserArray replaceObjectAtIndex:index withObject:defaultModel];
        }
    }
    [self.audioCollectionView reloadData];

    NSArray *muteArray = [self.listArray copy];
    for (NSDictionary *dic in muteArray) {
        if ([dic[@"userId"] isEqualToString:userId]) {
            [self.listArray removeObject:dic];
        }
    }
    [self.audioListView updateListArray:_listArray];
}

# pragma mark - requests

- (void)createAudioRoomAccordingSituation {
    [QNNetworkRequest requestWithUrl:QN_GET_CREATE_ROOM(self.userId) requestType:QNRequestTypeGet dic:nil header:[NSString stringWithFormat:@"Bearer %@", self.defaultDic[@"token"]] success:^(NSDictionary * _Nonnull resultDic) {
        NSLog(@"QN_GET_CREATE_ROOM resultDic --- %@", resultDic);
        if (resultDic[@"rooms"] != [NSNull null]) {
            NSArray *array = resultDic[@"rooms"];
            NSDictionary *dic = array[0];
            // 存在房间先手动关闭之前的房间
            [self closeAudioRoom:dic[@"id"]];
        } else{
            [self creatAudioRoom];
        }
    } error:^(NSError * _Nonnull error) {
        [self.alertContentView removeAlertContentView];
        NSLog(@"QN_GET_CREATE_ROOM error --- %@", error);
        QNSigleAlertView *sigleView = [[QNSigleAlertView alloc]init];
        [sigleView showAlertViewTitle:[NSString stringWithFormat:@"获取创建列表失败 %ld", (long)error.code] bgView:self.view];
    }];
}

- (void)creatAudioRoom {
    [QNNetworkRequest requestWithUrl:QN_CREATE_ROOM requestType:QNRequestTypePost dic:@{@"userID":self.defaultDic[@"id"], @"roomName":self.roomName, @"roomType":@"voice"} header:[NSString stringWithFormat:@"Bearer %@", self.defaultDic[@"token"]] success:^(NSDictionary * _Nonnull resultDic) {
        NSLog(@"QN_CREATE_ROOM resultDic --- %@", resultDic);
        if ([resultDic.allKeys containsObject:@"rtcRoomToken"]) {
            self.createResultDic = resultDic;
            self.roomName = resultDic[@"roomName"];
            self.token = resultDic[@"rtcRoomToken"];
            self.roomId = resultDic[@"roomID"];
            
            if (self.editRoomName.length != 0) {
                [self editRoomNameChange];
                self.roomNameLabel.text = self.editRoomName;
            } else{
                self.roomNameLabel.text = self.roomName;
            }
            [self.engine joinRoomWithToken:self.token];
            [self.alertContentView removeAlertContentView];
        }
        if ([resultDic.allKeys containsObject:@"code"]) {
            NSInteger code = [resultDic[@"code"] integerValue];
            if (code == 409004) {
                QNSigleAlertView *sigleView = [[QNSigleAlertView alloc]init];
                [sigleView showAlertViewTitle:[NSString stringWithFormat:@"用户正在观看，无法直播 %ld", code] bgView:self.view];
            }
        }
    } error:^(NSError * _Nonnull error) {
        [self.alertContentView removeAlertContentView];
        NSLog(@"QN_CREATE_ROOM error --- %@", error);
        QNSigleAlertView *sigleView = [[QNSigleAlertView alloc]init];
        [sigleView showAlertViewTitle:[NSString stringWithFormat:@"创建直播间失败 %ld", (long)error.code] bgView:self.view];
    }];
}

- (void)refreshJoinRoom {
    [QNNetworkRequest requestWithUrl:QN_REFRESH_JOIN_ROOM requestType:QNRequestTypePost dic:@{@"roomID":self.roomId} header:[NSString stringWithFormat:@"Bearer %@", self.defaultDic[@"token"]] success:^(NSDictionary * _Nonnull resultDic) {
        NSLog(@"QN_REFRESH_JOIN_ROOM resultDic --- %@", resultDic);
        if ([resultDic.allKeys containsObject:@"rtcRoomToken"]) {
            self.createResultDic = resultDic;
            self.roomName = resultDic[@"roomName"];
            self.token = resultDic[@"rtcRoomToken"];
            self.roomId = resultDic[@"roomID"];

            if (self.editRoomName.length != 0) {
                [self editRoomNameChange];
                self.roomNameLabel.text = self.editRoomName;
            } else{
                self.roomNameLabel.text = self.roomName;
            }

            [self.engine joinRoomWithToken:self.token];
        }
    } error:^(NSError * _Nonnull error) {
        NSLog(@"QN_REFRESH_JOIN_ROOM error --- %@", error);
        QNSigleAlertView *sigleView = [[QNSigleAlertView alloc]init];
        [sigleView showAlertViewTitle:[NSString stringWithFormat:@"刷新直播间失败 %ld", (long)error.code] bgView:self.view];
    }];
}

- (void)closeAudioRoom:(NSString *)roomId {
    [QNNetworkRequest requestWithUrl:QN_CLOSE_ROOM requestType:QNRequestTypePost dic:@{@"userID":self.defaultDic[@"id"], @"roomID":roomId} header:[NSString stringWithFormat:@"Bearer %@", self.defaultDic[@"token"]] success:^(NSDictionary * _Nonnull resultDic) {
        [self creatAudioRoom];
        NSLog(@"QN_CLOSE_ROOM resultDic --- %@", resultDic);
    } error:^(NSError * _Nonnull error) {
        NSLog(@"QN_CLOSE_ROOM error --- %@", error);
        QNSigleAlertView *sigleView = [[QNSigleAlertView alloc]init];
        [sigleView showAlertViewTitle:[NSString stringWithFormat:@"关闭上个直播间失败 %ld", (long)error.code] bgView:self.view];
    }];
}

- (void)editRoomNameChange {
    [QNNetworkRequest requestWithUrl:QN_UPDATE_ROOM_PROFILE(self.roomId) requestType:QNRequestTypePut dic:@{@"roomName":self.editRoomName} header:[NSString stringWithFormat:@"Bearer %@", self.defaultDic[@"token"]] success:^(NSDictionary * _Nonnull resultDic) {
        NSLog(@"QN_UPDATE_ROOM_PROFILE resultDic --- %@", resultDic);
    } error:^(NSError * _Nonnull error) {
        NSLog(@"QN_UPDATE_ROOM_PROFILE error --- %@", error);
        QNSigleAlertView *sigleView = [[QNSigleAlertView alloc]init];
        [sigleView showAlertViewTitle:[NSString stringWithFormat:@"编辑直播间房间名失败 %ld", (long)error.code] bgView:self.view];
    }];
}

- (void)enterIMWithRequestToken {
    NSString *imageString = self.defaultDic[@"avatar"];
    if ([imageString length] == 0) {
        imageString = @"icon_default_avator.png";
    }
    NSString *imToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"QN_USER_IM_TOKEN"];
    if (imToken.length == 0) {
        [QNNetworkRequest requestWithUrl:QN_IM_USER_TOKEN requestType:QNRequestTypePost dic:nil header:[NSString stringWithFormat:@"Bearer %@", self.defaultDic[@"token"]] success:^(NSDictionary * _Nonnull resultDic) {
            NSLog(@"audio view QN_IM_USER_TOKEN resultDic --- %@", resultDic);
            if ([resultDic.allKeys containsObject:@"token"]) {
                [[NSUserDefaults standardUserDefaults] setObject:resultDic[@"token"] forKey:@"QN_USER_IM_TOKEN"];
                [self joinChatRoomWithToken:imToken userName:self.defaultDic[@"nickname"] avatar:imageString];
            }
        } error:^(NSError * _Nonnull error) {
            NSLog(@"audio view QN_IM_USER_TOKEN error --- %@", error);
            QNSigleAlertView *sigleView = [[QNSigleAlertView alloc]init];
            [sigleView showAlertViewTitle:[NSString stringWithFormat:@"获取 IM token 失败 %ld", (long)error.code] bgView:self.view];
        }];
    } else {
        [self joinChatRoomWithToken:imToken userName:self.defaultDic[@"nickname"] avatar:imageString];
    }
}

# pragma mark - others

- (void)roomLabelIsCenter:(BOOL)isCenter {
    CGFloat statusBarHeight = 20;
    if(QN_iPhoneX || QN_iPhoneXR || QN_iPhoneXSMAX ||
       QN_iPhone12Min || QN_iPhone12Pro || QN_iPhone12PMax) {
        statusBarHeight = 40;
    }

    if (isCenter) {
        [_roomNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.top.mas_equalTo(self.view.mas_top).mas_offset(statusBarHeight);
            make.height.mas_equalTo(52);
        }];
        _roomNameLabel.textAlignment = NSTextAlignmentRight;
    } else{
        [_roomNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view.mas_left).offset(20);
            make.top.mas_equalTo(self.view.mas_top).mas_offset(statusBarHeight);
            make.height.mas_equalTo(52);
        }];
        _roomNameLabel.textAlignment = NSTextAlignmentLeft;
    }
}

- (void)hideAllUIView {
    [UIView animateWithDuration:0.2 animations:^{
        self.audioListView.frame = CGRectMake(0, QN_KSCREEN_HEIGHT, QN_KSCREEN_WIDTH, 300);
    } completion:^(BOOL finished) {
        if (finished) {
            [self.audioListView removeFromSuperview];
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [self hideAllUIView];
}

- (void)showAlertWithMessage:(NSString *)message title:(NSString *)title completionHandler:(void (^)(void))handler {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (handler) {
            handler();
        }
    }]];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark IM-socket

- (void)startJoin:(NSString *)roomID position:(NSInteger)position{
    NSLog(@"startJoin: %@ position: %ld", roomID, position);
    dispatch_async(self.operationQueue, ^{
        NSDictionary *dic = @{@"roomID": roomID,
                              @"position": @(position)};
        [self sendDictionary:dic withCommandType:@"start-join"];
    });
}

- (void)answerJoin:(NSString *)roomID reqUserID:(NSString *)reqUserID accept:(BOOL)accept {
    NSLog(@"answerJoin: %@ reqUserID: %@ accept: %d", roomID, reqUserID, accept);
    dispatch_async(self.operationQueue, ^{
        NSDictionary *dic = @{@"roomID": roomID,
                              @"reqUserID": reqUserID,
                              @"accept":@(accept)};
        [self sendDictionary:dic withCommandType:@"answer-join"];
    });
}

- (void)endJoin:(NSString *)roomID reqUserID:(NSString *)reqUserID {
    NSLog(@"endJoin: %@", roomID);
    self.currentIndex = -1;
    self.audioState = 0;
    dispatch_async(self.operationQueue, ^{
        NSDictionary *dic = @{@"roomID": roomID,
                              @"reqUserID": reqUserID};
        [self sendDictionary:dic withCommandType:@"end-join"];
    });
}

- (void)disconnect {
    NSLog(@"disconnect");
    dispatch_async(self.operationQueue, ^{
        NSDictionary *dic = @{@"rpcID": @3};
        [self sendDictionary:dic withCommandType:@"disconnect"];
    });
}

- (void)didReceiveIMSignalMessage:(RCTextMessage *)message {
    NSLog(@"content - %@", message.content);
    if (![message.content isKindOfClass:[NSString class]]) {
        NSLog(@"invaild message: %@", message);
        return;
    }

    NSRange range = [message.content rangeOfString:@"="];
    if (range.location == NSNotFound) {
        NSLog(@"invalid res message, can't find '='");
        return;
    }

    NSString *type = [message.content substringToIndex:range.location];
    NSLog(@"type - %@", type);
    NSString *body = [message.content substringFromIndex:range.location + 1];
    NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        NSLog(@"convert body: %@ to NSData failed", body);
        return;
    }

    NSError *error = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        NSLog(@"convert data NSDictionary failed, error: %@", error);
        return;
    }
    
    self.lastReceiveTime = [NSDate date];
    
    if ([type isEqualToString:@"ping"]) {
        dispatch_async(self.operationQueue, ^{
            [self sendDictionary:nil withCommandType:@"pong"];
        });
    }
        
    if ([type isEqualToString:@"on-join-request"]) {
        /*
        {"roomID":"room-12345678",
        "reqUserID":"user-1234",
        "nickname":"粉丝001",
        "gender":"female",
        "avatar":"qlive-files.example.com/1.jpg",
        "position":1}
         */
        NSLog(@"didReceiveStartJoinRequest - dic %@", dic);

        if (self.isAdmin) {
            [self hideAllUIView];
            QNDialogAlertView *notifyView = [[QNDialogAlertView alloc] initWithFrame:CGRectMake(0, 0, 300, 200) title:@"连麦互动" request:YES content: [NSString stringWithFormat:@"%@ 请求上麦", dic[@"nickname"]] buttonArray:@[@"拒绝 TA", @"同意"]];
            notifyView.center = self.view.center;
            notifyView.roomId = dic[@"roomID"];
            notifyView.delegate = self;
            notifyView.requestDic = [NSDictionary dictionaryWithDictionary:dic];
            [self.view addSubview:notifyView];
        }
    }
    
    if ([type isEqualToString:@"on-join-answer"]) {
        /*
        {"roomID":"room-12345678",
        "reqUserID":"user1234",
        "accept":true,
        "position":0}
         */
        NSLog(@"didReceiveOnJoinAnswer - dic %@", dic);
        if (!self.isAdmin) {
            if ([dic.allKeys containsObject:@"error"]) {
                NSInteger code = [dic[@"10016"] integerValue];
                if (code == 10016) {
                    QNSigleAlertView *alertView = [[QNSigleAlertView alloc] init];
                    [alertView showAlertViewTitle:@"上麦位置已被占用！" bgView:self.view];
                }
            }
            if (![dic[@"accept"] boolValue]) {
                [self hideAllUIView];
                self.resultAlertView = [[QNDialogAlertView alloc] initWithFrame:CGRectMake(0, 0, 300, 200) title:@"连麦互动" request:NO content:@"您的上麦请求被拒绝 o(╥﹏╥)o" buttonArray:@[@" 好吧 主播好残忍 "]];
                self.audioState = 0;
                self.resultAlertView.center = self.view.center;
                [self.view addSubview:_resultAlertView];
                self.currentIndex = -1;
            } else {
                self.muteAudio = NO;
                self.muteSpeaker = NO;
                self.microphoneButton.selected = NO;
                self.speakerButton.selected = NO;

                [self.engine publishAudio];
                NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
                [mutableDic setValue:dic[@"roomID"] forKey:@"roomID"];
                [mutableDic setValue:dic[@"reqUserID"] forKey:@"reqUserID"];
                [mutableDic setValue:self.defaultDic[@"gender"] forKey:@"gender"];
                [mutableDic setValue:self.defaultDic[@"nickname"] forKey:@"nickname"];
                [mutableDic setValue:self.defaultDic[@"avatar"] forKey:@"avatar"];
                [mutableDic setValue:dic[@"position"] forKey:@"position"];
                [self updateAudioUserCollectionDic:mutableDic];
            }
        }
    }
    
    if ([type isEqualToString:@"on-audience-join"]) {
        /*
        {"roomID":"room-12345678",
        "reqUserID":"user1234",
        "position":1,
        "gender":"female",
        "nickname":"粉丝001",
        "avatar":"qlive-files.qnsdk.com/1.jpg"}
         */
        NSLog(@"didReceiveAudienceJoin - dic %@", dic);
        if (!self.isAdmin) {
            [self updateAudioUserCollectionDic:dic];
        }
    }
    
    if ([type isEqualToString:@"on-join-end"]) {
        /*
         当出现以下情况时，连麦结束，应通知房内其他参与者：

         观众主动结束，通知主播与其他观众
         观众下线，同上
         
        {"roomID":"room-12345678",
        "reqUserID":"user1234",
        "position":1,
        "gender":"female",
        "nickname":"粉丝001",
        "avatar":"qlive-files.qnsdk.com/1.jpg"}
         */
        NSLog(@"didReceiveOnJoinEnd - dic %@", dic);
        // 对应 UI 移除该用户
        [self removeUser:dic[@"reqUserID"]];
    }
    
    if ([type isEqualToString:@"on-join-timeout"]) {
        NSLog(@"didReceiveOnJoinTimeout - dic %@", dic);
        /*
        {"roomID":"room-12345678",
        "reqUserID":"user1234"}
         */
        [self hideAllUIView];
        for (UIView *view in self.view.subviews) {
            if ([view.class isEqual:[QNDialogAlertView class]]) {
                QNDialogAlertView *alertView = view;
                if ([alertView.requestDic[@"reqUserID"] isEqualToString:dic[@"reqUserID"]]) {
                    [alertView hideAlertView];
                }
            }
        }
        self.resultAlertView = [[QNDialogAlertView alloc] initWithFrame:CGRectMake(0, 0, 300, 200) title:@"连麦互动" request:NO content:@"上麦请求已超时 !" buttonArray:@[@" 我知道了 "]];
        self.resultAlertView.center = self.view.center;
        [self.view addSubview:_resultAlertView];
    }
    
    if ([type isEqualToString:@"on-room-close"]) {
        // 通知观众房间关闭
        if (!self.isAdmin) {
            QNSigleAlertView *alertView = [[QNSigleAlertView alloc] init];
            if (self.audioState == 1) {
                [alertView showAlertViewTitle:@"房间已关闭，感谢参与！" bgView:self.view];
            } else {
                [alertView showAlertViewTitle:@"房间已关闭，感谢观看！" bgView:self.view];
            }

            [self getback];
        }
    }
}

- (void)sendDictionary:(NSDictionary *)dic withCommandType:(NSString *)type {
    NSString *dicString = @"{}";
    if (dic) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
        if (error) {
            return;
        }
        dicString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (!dicString) {
            return;
        }
    }
    NSString *sendString = [NSString stringWithFormat:@"%@=%@", type, dicString];
    [self sendIMSignalString:sendString];
}

- (void)sendIMSignalString:(NSString *)string {
    NSLog(@"sendIMSignal: %@ userId: %@", string, self.userId);
    RCChatroomWelcome *chatroomMessage = [[RCChatroomWelcome alloc]init];
    [chatroomMessage setId:self.userId];
    [self.chatRoomView sendMessage:string pushContent:nil targetId:@"qlive-system" success:^(long messageId) {
        NSLog(@"messageId:%ld", messageId);
    } error:^(RCErrorCode nErrorCode, long messageId) {
        NSLog(@"nErrorCode: %ld messageId: %ld", nErrorCode, messageId);
    }];
}

- (void)startTimer {
    NSLog(@"startTimer");

    if (self.signalTimer) {
        return;
    }
    self.signalTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.operationQueue);
    dispatch_source_set_timer(self.signalTimer, DISPATCH_TIME_NOW, 0.8 * NSEC_PER_SEC, 0.3 * NSEC_PER_SEC);
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(self.signalTimer, ^{
        if (weakSelf.lastReceiveTime) {
            NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:weakSelf.lastReceiveTime];
            if (interval > self.pongTimeout) {
                [weakSelf stopTimer];
                return;
            }
        }

        if (weakSelf.lastSendTime) {
            NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:weakSelf.lastSendTime];
            if (interval > kQNLiveWebSocketPingInterval) {
                [self sendDictionary:nil withCommandType:@"ping"];
                NSLog(@"sendPing");
                weakSelf.lastSendTime = [NSDate date];
            }
        } else {
            [self sendDictionary:nil withCommandType:@"ping"];
            NSLog(@"sendPing");
            weakSelf.lastSendTime = [NSDate date];
        }
    });
    dispatch_resume(self.signalTimer);
}

- (void)stopTimer {
    NSLog(@"stopTimer");

    if (self.signalTimer) {
        dispatch_cancel(self.signalTimer);
        self.signalTimer = nil;
    }

    self.lastReceiveTime = nil;
    self.lastSendTime = nil;
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
