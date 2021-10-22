//
//  QNLiveViewController.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/7.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNLiveViewController.h"

// IM
#import "RCChatRoomView.h"
#import "RCChatroomWelcome.h"
#import "RCCRRongCloudIMManager.h"

// UI
#import "QNPKUserListView.h"
#import "QNLiveSettingsView.h"
#import "QNDialogAlertView.h"
#import "RCChatroomUserQuit.h"

// 特效 UI
#import "BEModernStickerPickerView.h"
#import "BEModernEffectPickerView.h"
#import "BETextSliderView.h"

static NSString *roomStatus[] = {
    @"QNRoomStateIdle",
    @"QNRoomStateConnecting",
    @"QNRoomStateConnected",
    @"QNRoomStateReconnecting",
    @"QNRoomStateReconnected"
};

#define QN_BOTTOM_BUTTON_WIDTH 52.0

#define QN_DELAY_MS 5000

static NSString *cameraTag = @"camera";
const static NSTimeInterval kQNLiveWebSocketPingInterval = 5;

@interface QNLiveViewController ()
<
QNRTCEngineDelegate,
UIGestureRecognizerDelegate,
// UI
QNLiveSettingsViewDelegate,
QNPKUserListViewDelegate,
BEModernStickerPickerViewDelegate,
QNEditAlertViewDelegate,
RCChatRoomViewDelegate
>

/// RTC
@property (nonatomic, strong) QNRTCEngine *engine;

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *pkToken;

@property (nonatomic, assign) BOOL isAdmin; // 是否是主播端

@property (nonatomic, strong) QNForwardStreamConfiguration *forwardConfig;
@property (nonatomic, strong) QNMergeStreamConfiguration *mergeConfig;

/**
* 如果您的场景包括合流转推和单路转推的切换，那么需要维护一个 serialNum 的参数，代表流的优先级，
* 使其不断自增来实现 rtmp 流的无缝切换。
*
* QNMergeJob 以及 QNForwardJob 中 publishUrl 的格式为：rtmp://domain/app/stream?serialnum=xxx
*
* 切换流程推荐为：
* 1. 单路转推 -> 创建合流任务（以创建成功的回调为准） -> 停止单路转推
* 2. 合流转推 -> 创建单路转推任务（以创建成功的回调为准） -> 停止合流转推
*
* 注意：
* 1. 两种合流任务，推流地址应该保持一致，只有 serialnum 存在差异
* 2. 在两种推流任务切换的场景下，合流任务务必使用自定义合流任务，并指定推流地址的 serialnum
*/
@property (nonatomic, assign) NSInteger serialNum;

@property (nonatomic, copy) NSString *userId; // jobId
@property (nonatomic, copy) NSString *roomName;
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) NSString *rtcRoom;

@property (nonatomic, copy) NSString *pkRoomId;
@property (nonatomic, copy) NSString *editRoomName;
@property (nonatomic, copy) NSString *pkUserId;
@property (nonatomic, copy) NSString *pkNickName;

@property (nonatomic, strong) NSDictionary *createResultDic;

@property (nonatomic, strong) QNTrackInfo *cameraTrackInfo;
@property (nonatomic, strong) QNTrackInfo *audioTrackInfo;

@property (nonatomic, assign) CGSize videoEncodeSize;
@property (nonatomic, assign) NSInteger bitrate;

@property (nonatomic, assign) BOOL muteVideo;
@property (nonatomic, assign) BOOL muteAudio;
@property (nonatomic, assign) BOOL muteSpeaker;
@property (nonatomic, assign) BOOL torchOn;

// 0 未直播    1 直播     2 PK 直播
@property (nonatomic, assign) NSInteger liveState;
@property (nonatomic, strong) NSMutableArray *layouts;


// UI
@property (nonatomic, strong) UIButton *startForwardButton;

@property (nonatomic, strong) UIView *bottomButtonView;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *togCameraButton;
@property (nonatomic, strong) UIButton *beautyButton;
@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UIButton *stopButton;

@property (nonatomic, strong) NSMutableArray *userViewArray;
@property (nonatomic, strong) UIView *renderBackgroundView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *pkButton;
@property (nonatomic, strong) UIButton *listButton;

@property (nonatomic, strong) UIView *pkBgView;

@property (nonatomic, strong) UIButton *videoButton;
@property (nonatomic, strong) UIButton *microphoneButton;
@property (nonatomic, strong) UIButton *speakerButton;

@property (nonatomic, strong) UIButton *effectButton;
@property (nonatomic, strong) UIButton *stickerButton;

// IM
@property (nonatomic, strong) RCChatRoomView * chatRoomView;
@property (nonatomic, strong) RCCRLiveModel * model;

// 特效
@property (nonatomic, strong) BEModernStickerPickerView *stickerListView;
@property (nonatomic, strong) BEModernEffectPickerView *effectListView;
@property (nonatomic, strong) PLSEffectDataManager *effectDataManager;
@property (nonatomic, strong) PLSEffectManager *effectManager;

// UI
@property (nonatomic, strong) UILabel *roomNameLabel;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UILabel *roomNumberLabel;
@property (nonatomic, strong) QNPKUserListView *pkListView;
@property (nonatomic, strong) QNPKUserListView *listView;
@property (nonatomic, strong) QNDialogAlertView *pkNotifyView;
@property (nonatomic, strong) QNDialogAlertView *resultAlertView;
@property (nonatomic, strong) QNLiveSettingsView *settingsView;
@property (nonatomic, strong) QNEditAlertView *editAlertView;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSDictionary *defaultDic;
@property (nonatomic, strong) QNReachability *reachability;

// IM signal
@property (nonatomic, strong) NSDate *lastSendTime;
@property (nonatomic, strong) NSDate *lastReceiveTime;
@property (nonatomic, strong) dispatch_source_t signalTimer;
@property (nonatomic, assign) NSInteger pongTimeout;
@property (nonatomic, strong) dispatch_queue_t operationQueue;

@property (nonatomic, strong) NSMutableArray *nickNameArray;

@property (nonatomic, strong) QNSigleAlertView *alertContentView;

@end

@implementation QNLiveViewController

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // 离开房间
    [self.engine leaveRoom];
    
    [_timer invalidate];
    _timer = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kQNReachabilityChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
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
        
    self.liveState = 0;
    self.serialNum = 0;
    self.videoEncodeSize = CGSizeMake(720, 1280);
    self.bitrate = 2000 * 1000;
    self.nickNameArray = [NSMutableArray arrayWithArray:@[@{@"userId":self.userId, @"nickname":self.defaultDic[@"nickname"]}]];
    
    self.alertContentView = [[QNSigleAlertView alloc] init];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self layoutInterfaceView];

    self.userViewArray = [[NSMutableArray alloc] init];
    
    self.renderBackgroundView = [[UIView alloc] init];
    [self.view insertSubview:self.renderBackgroundView atIndex:1];
    [self.renderBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
        
    [self initRTCEngine];
    
    [self initForwardConfiguration];
    [self initMergeConfiguration];
    // IM
    [self setupIMUI];
    
    [self setupEffect];
    
    // IM signal
    self.operationQueue = dispatch_queue_create("com.qiniu.qnrtcLive.operation", DISPATCH_QUEUE_SERIAL);

    
    //监听是否重新进入程序程序.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(endBackground)
    name:UIApplicationDidBecomeActiveNotification object:nil];

    //监听是否触发home键挂起程序.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground)
    name:UIApplicationWillResignActiveNotification object:nil];
    
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

-(void)endBackground {
    NSLog(@"live end background");
    if (self.engine) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.engine pushCameraTrackWithImage:nil];
        });
    }
}

-(void)enterBackground {
    NSLog(@"live enter background");
    if (self.engine) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.engine pushCameraTrackWithImage:[UIImage imageNamed:@"push_image.png"]];
        });
    }
}

# pragma mark - QNRTC

- (void)initRTCEngine {
    [QNRTCEngine enableFileLogging];
    
    // 1.初始化 RTC 核心类 QNRTCEngine
    self.engine = [[QNRTCEngine alloc] init];
    // 2.设置 QNRTCEngineDelegate 状态回调的代理
    self.engine.delegate = self;
    
    // 3.设置相关配置
    self.engine.sessionPreset = AVCaptureSessionPreset1280x720;
    // 视频帧率
    self.engine.videoFrameRate = 25;;
    // 设置统计信息回调的时间间隔，不设置的话，默认不会回调统计信息
//    self.engine.statisticInterval = 5;
    // 打开 sdk 自带的美颜效果
    [self.engine setBeautifyModeOn:YES];
    self.engine.encodeMirrorFrontFacing = YES;
    
    [self.renderBackgroundView addSubview:self.engine.previewView];
    
    // 4.设置摄像头采集的预览视频位置
    [self.engine.previewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    // 5.启动摄像头采集
    // 注意：记得在 Info.list 中添加摄像头、麦克风的相关权限
    // NSCameraUsageDescription、NSMicrophoneUsageDescription
    [self.engine startCapture];
}

- (void)publish {
    QNTrackInfo *audioTrack = [[QNTrackInfo alloc] initWithSourceType:QNRTCSourceTypeAudio master:YES];
    QNTrackInfo *cameraTrack =  [[QNTrackInfo alloc] initWithSourceType:(QNRTCSourceTypeCamera)
                                                                    tag:cameraTag
                                                                 master:YES
                                                             bitrateBps:self.bitrate
                                                        videoEncodeSize:self.videoEncodeSize];
    // 7.发布音频、视频 track
    // track 可通过 QNTrackInfo 配置
    [self.engine publishTracks:@[audioTrack, cameraTrack]];
}

- (void)initForwardConfiguration {
    self.forwardConfig = [[QNForwardStreamConfiguration alloc] init];
    self.forwardConfig.audioOnly = NO;
}

- (void)initMergeConfiguration {
    self.mergeConfig = [QNMergeStreamConfiguration defaultConfiguration];
    QNBackgroundInfo *bgInfo = [[QNBackgroundInfo alloc] init];
    bgInfo.frame = CGRectMake(0, 0, 720, 1280);
    bgInfo.backgroundUrl = @"http://pili-playback.qnsdk.com/streaming_black_background.png";
    self.mergeConfig.background = bgInfo;
    self.mergeConfig.minBitrateBps = 1000*1000;
    self.mergeConfig.maxBitrateBps = 1000*1000;
    self.mergeConfig.width = 720;
    self.mergeConfig.height = 1280;
    self.mergeConfig.fillMode = QNVideoFillModePreserveAspectRatioAndFill;
    self.layouts = [NSMutableArray array];
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
            self.videoButton.selected = YES;
            self.microphoneButton.selected = YES;
            [self publish];
        } else if (QNRoomStateIdle == roomState) {
            self.videoButton.enabled = NO;
            self.videoButton.selected = NO;
        } else if (QNRoomStateReconnecting == roomState) {
            [alertView showAlertViewTitle:@"正在重连..." bgView:self.view];
            self.videoButton.enabled = NO;
            self.microphoneButton.enabled = NO;
            if (self.liveState == 1) {
                self.liveState = 0;
            }
        } else if (QNRoomStateReconnected == roomState) {
            [alertView showAlertViewTitle:@"重新加入房间成功" bgView:self.view];
            self.videoButton.enabled = YES;
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
        QNSigleAlertView *alertView = [[QNSigleAlertView alloc] init];
        [alertView showAlertViewTitle:@"远端用户重连成功了" bgView:self.view];
    });
}

/**
 * 远端用户发生重连的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didReconnectingRemoteUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didReconnectingRemoteUserId: %@", userId);
        QNSigleAlertView *alertView = [[QNSigleAlertView alloc] init];
        [alertView showAlertViewTitle:@"远端用户发生了重连" bgView:self.view];
    });
}

/**
 * 调用 publish 发布本地音视频 tracks 后收到的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didPublishLocalTracks:(NSArray<QNTrackInfo *> *)tracks {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didPublishLocalTracks: %@", tracks);
        [self.engine muteVideo:self.muteVideo];
        [self.engine muteAudio:self.muteAudio];
        [self.engine setMuteSpeaker:self.muteSpeaker];
        [self.engine setTorchOn:self.torchOn];

        for (QNTrackInfo *trackInfo in tracks) {
            if (trackInfo.kind == QNTrackKindAudio) {
                self.microphoneButton.enabled = YES;
                self.audioTrackInfo = trackInfo;
                continue;
            }
            if (trackInfo.kind == QNTrackKindVideo) {
                self.videoButton.enabled = YES;
                self.cameraTrackInfo = trackInfo;
                continue;
            }
        }
        
        if (self.liveState != 2 && self.audioTrackInfo && self.cameraTrackInfo) {
            self.liveState = 1;
            self.serialNum++;
            self.forwardConfig.publishUrl = [NSString stringWithFormat:@"rtmp://pili-publish.qnsdk.com/sdk-live/%@?serialnum=%@", self.userId, @(self.serialNum)];
            self.forwardConfig.audioTrackInfo = self.audioTrackInfo;
            self.forwardConfig.videoTrackInfo = self.cameraTrackInfo;
            self.forwardConfig.jobId = [NSString stringWithFormat:@"forward-%@", self.userId];;
            [self.engine createForwardJobWithConfiguration:self.forwardConfig];
            if (!self.pkToken) {
                [self enterIMWithRequestToken];
                self.pkToken = nil;
                self.pkRoomId = nil;
                self.listButton.hidden = NO;
                self.pkButton.hidden = NO;
                self.editButton.hidden = YES;
                
                self.timer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(updateAudienceCount) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
            }
        }
        if (self.liveState == 2) {
            for (QNTrackInfo *trackInfo in tracks) {
                if (trackInfo.kind == QNTrackKindAudio) {
                    QNMergeStreamLayout *audioLayout = [[QNMergeStreamLayout alloc] init];
                    audioLayout.trackId = trackInfo.trackId;
                    [self.layouts addObject:audioLayout];
                }
                if (trackInfo.kind == QNTrackKindVideo) {
                    QNMergeStreamLayout *layout = [[QNMergeStreamLayout alloc] init];
                    layout.frame = CGRectMake(0, 222.6, 360, 640);
                    layout.zIndex = 0;
                    layout.trackId = trackInfo.trackId;
                    [self.layouts addObject:layout];
                }
            }
            NSLog(@"self.layouts - local %@", self.layouts);
                        
            if (self.layouts.count > 2) {
                self.serialNum++;
                self.mergeConfig.publishUrl = [NSString stringWithFormat:@"rtmp://pili-publish.qnsdk.com/sdk-live/%@?serialnum=%@", self.userId, @(self.serialNum)];
                self.mergeConfig.jobId = [NSString stringWithFormat:@"merge-%@", self.userId];;
                [self.engine createMergeStreamJobWithConfiguration:self.mergeConfig];
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
    });
}

/**
 * 远端用户发布音/视频的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didPublishTracks:(NSArray<QNTrackInfo *> *)tracks ofRemoteUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didPublishTracks: %@ ofRemoteUserId: %@", tracks, userId);
        if (self.liveState == 2) {
            if (self.isAdmin) {
                self.layouts = [NSMutableArray array];
                QNMergeStreamLayout *audioLayout = [[QNMergeStreamLayout alloc] init];
                audioLayout.trackId = self.audioTrackInfo.trackId;
                [self.layouts addObject:audioLayout];
                
                QNMergeStreamLayout *layout = [[QNMergeStreamLayout alloc] init];
                layout.frame = CGRectMake(0, 222.6, 360, 640);
                layout.zIndex = 0;
                layout.trackId = self.cameraTrackInfo.trackId;
                [self.layouts addObject:layout];
            }

            for (QNTrackInfo *trackInfo in tracks) {
                if (trackInfo.kind == QNTrackKindAudio) {
                    QNMergeStreamLayout *audioLayout = [[QNMergeStreamLayout alloc] init];
                    audioLayout.trackId = trackInfo.trackId;
                    [self.layouts addObject:audioLayout];
                }
                if (trackInfo.kind == QNTrackKindVideo) {
                    QNMergeStreamLayout *layout = [[QNMergeStreamLayout alloc] init];
                    layout.frame = CGRectMake(360, 222.6, 360, 640);
                    layout.zIndex = 0;
                    layout.trackId = trackInfo.trackId;
                    [self.layouts addObject:layout];
                }
            }
            NSLog(@"self.layouts - remote %@", self.layouts);
            
            if (self.layouts.count > 2) {
                self.serialNum++;
                self.mergeConfig.publishUrl = [NSString stringWithFormat:@"rtmp://pili-publish.qnsdk.com/sdk-live/%@?serialnum=%@", self.userId, @(self.serialNum)];
                self.mergeConfig.jobId = [NSString stringWithFormat:@"merge-%@", self.userId];;
                [self.engine createMergeStreamJobWithConfiguration:self.mergeConfig];
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
        for (QNTrackInfo *trackInfo in tracks) {
            QNRoomUserView *userView = [self userViewWithUserId:userId];
            if (!userView) {
                userView = [self createUserViewWithTrackId:trackInfo.trackId userId:userId];
                [self.userViewArray addObject:userView];
                NSLog(@"createRenderViewWithTrackId: %@", trackInfo.trackId);
            }
            if (nil == userView.superview) {
                [self addRenderViewToSuperView:userView];
            }
            
            QNTrackInfo *tempInfo = [userView trackInfoWithTrackId:trackInfo.trackId];
            if (tempInfo) {
                [userView.traks removeObject:tempInfo];
            }
            [userView.traks addObject:trackInfo];
            [userView showCameraView];
        }
    });
}

/**
 * 远端用户视频首帧解码后的回调，如果需要渲染，则需要返回一个带 renderView 的 QNVideoRender 对象
 */
- (QNVideoRender *)RTCEngine:(QNRTCEngine *)engine firstVideoDidDecodeOfTrackId:(NSString *)trackId remoteUserId:(NSString *)userId {
    NSLog(@"firstVideoDidDecodeOfTrackId: %@ remoteUserId: %@", trackId, userId);

    QNRoomUserView *userView = [self userViewWithUserId:userId];
    userView.contentMode = UIViewContentModeScaleAspectFit;
    QNVideoRender *render = [[QNVideoRender alloc] init];
    render.renderView = userView.cameraView;
    return render;
}

/**
 * 远端用户音频状态变更为 muted 的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didAudioMuted:(BOOL)muted ofTrackId:(NSString *)trackId byRemoteUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didAudioMuted: %d ofTrackId: %@ byRemoteUserId: %@", muted, trackId, userId);
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
        QNRoomUserView *userView = [self userViewWithUserId:userId];
        if (userView) {
            [self removeRenderViewFromSuperView:userView];
        }
    });
}

/**
 * 远端用户取消发布音/视频的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didUnPublishTracks:(NSArray<QNTrackInfo *> *)tracks ofRemoteUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didUnPublishTracks: %@ ofRemoteUserId: %@", tracks, userId);
        for (QNTrackInfo *trackInfo in tracks) {
            QNRoomUserView *userView = [self userViewWithUserId:userId];
            QNTrackInfo *tempInfo = [userView trackInfoWithTrackId:trackInfo.trackId];
            if (tempInfo) {
                [userView.traks removeObject:tempInfo];
                
                if (0 == userView.traks.count) {
                    [self removeRenderViewFromSuperView:userView];
                }
            }
        }
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
        [self hideAllUIView];
        if (self.isAdmin) {
            [self endPK:self.roomId];
        } else{
            [self endPK:self.pkRoomId];
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
 * 创建单路转推成功的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didCreateForwardJobWithJobId:(NSString *)jobId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"创建单路转推成功的回调 -- %@", jobId);
        self.backButton.hidden = YES;
        [self roomLabelIsCenter:NO];
        self.roomNumberLabel.hidden = NO;
        
        self.commentButton.hidden = NO;
        self.stopButton.hidden = NO;
        [self exchangeButtonViewsStyle:NO];
    });
}

/**
 * 创建合流成功的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didCreateMergeStreamWithJobId:(NSString *)jobId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"创建合流成功的回调 -- %@", jobId);
        [self exchangeButtonViewsStyle:YES];
        if (self.layouts.count > 4) {
            NSLog(@"setMergeStreamLayouts layouts 异常！！！");
        }
        [self.engine setMergeStreamLayouts:self.layouts jobId:jobId];
        NSLog(@"didCreateMergeStreamWithJobId layouts -- %@", self.layouts);
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
    if (self.effectManager) {
        // CMSampleBufferRef 转 CVPixelBufferRef 并获取 CMSampleTimingInfo
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CMSampleTimingInfo timingInfo;
        CMSampleBufferGetSampleTimingInfo(sampleBuffer, 0, &timingInfo);
                     
        double timestamp = timingInfo.presentationTimeStamp.value/timingInfo.presentationTimeStamp.timescale;
        [self.effectManager processBuffer:pixelBuffer withTimestamp:timestamp videoOrientation:self.engine.videoOrientation deviceOrientation:self.engine.videoOrientation];
    }
}

# pragma mark - IM

- (void)setupIMUI {
    CGFloat bottomExtraDistance  = 0;
    if (@available(iOS 11.0, *)) {
        bottomExtraDistance = [self getIPhonexExtraBottomHeight];
    }
    
    self.model = [[RCCRLiveModel alloc] init];
    self.model.audienceAmount = 0;
    self.model.fansAmount = 0;
    self.model.giftAmount = 0;
    self.model.praiseAmount = 0;
    self.model.attentionAmount = 0;
    self.model.liveMode = RCCRLiveModeHost;
    self.model.pubUserId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
    
    self.chatRoomView = [[RCChatRoomView alloc] initWithFrame:CGRectMake(0, QN_KSCREEN_HEIGHT - (237 +50)  - bottomExtraDistance, QN_KSCREEN_WIDTH, 237+50) model:self.model];
    self.chatRoomView.delegate = self;
    self.chatRoomView.commentBtn = self.commentButton;
}

- (float)getIPhonexExtraBottomHeight {
    float height = 0;
    if (@available(iOS 11.0, *)) {
        height = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets].bottom;
    }
    return height;
}

- (void)resetBottomGesture:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.chatRoomView setDefaultBottomViewStatus];
        [self.view removeGestureRecognizer:gestureRecognizer];
    }
}

//共存  A手势或者B手势 代理方法里shouldRecognizeSimultaneouslyWithGestureRecognizer   有一个是返回YES，就能共存
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)joinChatRoomWithToken:(NSString *)token userName:(NSString *)userName avatar:(NSString *)avatar {
    [self.view insertSubview:self.chatRoomView atIndex:2];
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

# pragma mark - effects

- (void)setupEffect {
    // PLSEffect
    NSString *rootPath = [[NSBundle mainBundle] resourcePath];
    PLSEffectConfiguration *effectConfiguration = [PLSEffectConfiguration new];
    effectConfiguration.modelFileDirPath = [NSString pathWithComponents:@[rootPath, @"ModelResource.bundle"]];
    effectConfiguration.licenseFilePath = [NSString pathWithComponents:@[rootPath, @"LicenseBag.bundle", @"qiniu_20210310_20221011_com.qbox.QNRTCLiveDemo_3.9.0.licbag"]];
    _effectDataManager = [[PLSEffectDataManager alloc] initWithRootPath:rootPath];
    
    self.effectManager = [PLSEffectManager sharedWith:[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] configuration:effectConfiguration];
    self.effectListView.effectManager = self.effectManager;
    
    self.effectListView.dataManager = _effectDataManager;
    [self.effectListView loadData];
    
    self.effectButton = [[UIButton alloc] init];
    [self.effectButton setImage:[UIImage imageNamed:@"icon_effect_niu"] forState:(UIControlStateNormal)];
    [self.effectButton setBackgroundColor:QN_COLOR_RGB(0,0,0,0.3)];
    [self.effectButton setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
    self.effectButton.layer.cornerRadius = 20;
    self.effectButton.clipsToBounds = YES;
    [self.effectButton addTarget:self action:@selector(effectButtonDidClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:_effectButton];
    [self.effectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view).offset(-12);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.top.mas_equalTo(self.view.mas_centerY);
    }];
    
    self.stickerButton = [[UIButton alloc] init];
    [self.stickerButton setImage:[UIImage imageNamed:@"icon_sticker_niu"] forState:(UIControlStateNormal)];
    [self.stickerButton setBackgroundColor:QN_COLOR_RGB(0,0,0,0.3)];
    [self.stickerButton setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
    self.stickerButton.layer.cornerRadius = 20;
    self.stickerButton.clipsToBounds = YES;
    [self.stickerButton addTarget:self action:@selector(stickerButtonDidClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:_stickerButton];
    [self.stickerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view).offset(-12);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.top.mas_equalTo(self.effectButton).offset(60);
    }];
}

- (BEModernStickerPickerView *)stickerListView {
    if (!_stickerListView) {
        CGRect frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 200);
        _stickerListView = [[BEModernStickerPickerView alloc] initWithFrame:frame];
        _stickerListView.layer.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.8].CGColor;
        _stickerListView.delegate = self;
        PLSEffectModel *clear = [[PLSEffectModel alloc] init];
        clear.displayName = @"无";
        clear.iconImage = [UIImage imageNamed:@"iconCloseButtonNormal"];
        NSMutableArray *stickers = [[NSMutableArray alloc] initWithObjects:clear, nil];
        [stickers addObjectsFromArray:[_effectDataManager fetchEffectListWithType:PLSEffectTypeSticker]];
        [_stickerListView refreshWithStickers:stickers];
    }
    return _stickerListView;
}

- (BEModernEffectPickerView *)effectListView {
    if (!_effectListView) {
        _effectListView = [[BEModernEffectPickerView alloc] initWithFrame:(CGRect)CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 220)];
    }
    return _effectListView;
}

- (void)effectButtonDidClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self showEffectView];
    } else {
        [self hideEffectView];
    }
}

- (void)stickerButtonDidClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self showStickerView];
    } else {
        [self hideStickerView];
    }
}

- (void)showEffectView {
    if (self.stickerButton.selected) {
        self.stickerButton.selected = NO;
        [self.stickerButton setBackgroundColor:QN_COLOR_RGB(0,0,0,0.3)];
        [UIView animateWithDuration:0.25 animations:^{
            self.stickerListView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 220);
        } completion:^(BOOL finished) {
            [self.stickerListView removeFromSuperview];
        }];
    }
    [self.view insertSubview:self.effectListView aboveSubview:self.view.subviews.lastObject];
    [self.effectButton setBackgroundColor:[UIColor whiteColor]];
    [UIView animateWithDuration:0.25 animations:^{
        self.effectListView.frame = CGRectMake(0, self.view.frame.size.height - 200, self.view.frame.size.width, 200);
    } completion:nil];
}

- (void)hideEffectView {
    self.effectButton.selected = NO;
    [self.effectButton setBackgroundColor:QN_COLOR_RGB(0,0,0,0.3)];
    [UIView animateWithDuration:0.25 animations:^{
        self.effectListView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 200);
    } completion:^(BOOL finished) {
        [self.effectListView removeFromSuperview];
    }];
}

- (void)showStickerView {
    if (self.effectButton.selected) {
        self.effectButton.selected = NO;
        [self.effectButton setBackgroundColor:QN_COLOR_RGB(0,0,0,0.3)];
        [UIView animateWithDuration:0.25 animations:^{
            self.effectListView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 200);
        } completion:^(BOOL finished) {
            [self.effectListView removeFromSuperview];
        }];
    }
    [self.view insertSubview:self.stickerListView aboveSubview:self.view.subviews.lastObject];
    [self.stickerButton setBackgroundColor:[UIColor whiteColor]];
    [UIView animateWithDuration:0.25 animations:^{
        self.stickerListView.frame = CGRectMake(0, self.view.frame.size.height - 220, self.view.frame.size.width, 220);
    } completion:nil];
}

- (void)hideStickerView {
    self.stickerButton.selected = NO;
    [self.stickerButton setBackgroundColor:QN_COLOR_RGB(0,0,0,0.3)];
    [UIView animateWithDuration:0.25 animations:^{
        self.stickerListView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 220);
    } completion:^(BOOL finished) {
        [self.stickerListView removeFromSuperview];
    }];
}

#pragma mark - effect picker delegate

- (void)stickerPicker:(BEModernStickerPickerView *)pickerView didSelectSticker:(PLSEffectModel *)sticker {
    [self.effectManager updateSticker:sticker];
}

# pragma mark - views

- (void)layoutInterfaceView {
    [self layoutBottomViews];
    
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
    [self roomLabelIsCenter:YES];
    
    _editButton = [[UIButton alloc] init];
    [_editButton setImage:[UIImage imageNamed:@"icon_edit_house"] forState:UIControlStateNormal];
    [self.view addSubview:_editButton];
    [_editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.roomNameLabel.mas_right).offset(8);
        make.centerY.mas_equalTo(self.roomNameLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    [_editButton addTarget:self action:@selector(changeRoomName:) forControlEvents:UIControlEventTouchUpInside];
    
    self.startForwardButton = [[UIButton alloc] init];
    [self.startForwardButton setImage:[UIImage imageNamed:@"live_Start live"] forState:UIControlStateNormal];
    [self.view addSubview:_startForwardButton];
       
    [_startForwardButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.bottom.mas_equalTo(self.bottomButtonView.mas_top).mas_offset(-46);
        make.size.mas_equalTo(CGSizeMake(186, 52));
    }];
    [_startForwardButton addTarget:self action:@selector(startLiveAction:) forControlEvents:UIControlEventTouchUpInside];
    
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
    
    self.pkButton = [[UIButton alloc] init];
    [_pkButton setImage:[UIImage imageNamed:@"icon_pk1"] forState:UIControlStateNormal];
    [self.view addSubview:_pkButton];

    [_pkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).mas_offset(-72);
        make.top.mas_equalTo(self.view.mas_top).mas_offset(statusBarHeight);
        make.size.mas_equalTo(CGSizeMake(52, 52));
    }];
    [_pkButton addTarget:self action:@selector(enterPKView) forControlEvents:UIControlEventTouchUpInside];
    
    self.listButton.hidden = YES;
    self.pkButton.hidden = YES;
    self.roomNumberLabel.hidden = YES;
    
    self.backButton = [[UIButton alloc] init];
    [_backButton setImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateNormal];
    [self.view addSubview:_backButton];
          
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).mas_offset(20);
        make.top.mas_equalTo(self.view.mas_top).mas_offset(statusBarHeight);
        make.size.mas_equalTo(CGSizeMake(52, 52));
    }];
    [_backButton addTarget:self action:@selector(getback) forControlEvents:UIControlEventTouchUpInside];
    
    _pkBgView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:_pkBgView atIndex:0];
    
    UIImageView *redImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Pink gradient background"]];
    [_pkBgView addSubview:redImageView];
    [redImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.view);
        make.width.mas_equalTo(QN_KSCREEN_WIDTH/2);
    }];
    
    UIImageView *blueImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Blue gradient background"]];
    [_pkBgView addSubview:blueImageView];
    [blueImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(self.view);
        make.width.mas_equalTo(QN_KSCREEN_WIDTH/2);
    }];
    
    _pkBgView.hidden = YES;

    [self readyUIView];
}

- (void)layoutBottomViews {
    self.bottomButtonView = [[UIView alloc] init];
    [self.view addSubview:self.bottomButtonView];
    
    UIButton* buttons[5];
    NSString *selectedImage[] = {
        @"icon_chat",
        @"icon_recers",
        @"icon_Beauty",
        @"icon_set up",
        @"icon_small close"
    };
    NSString *normalImage[] = {
        @"icon_chat",
        @"icon_recers",
        @"icon_Beauty",
        @"icon_set up",
        @"icon_small close"
    };
    SEL selectors[] = {
        @selector(commentAction:),
        @selector(toggleButtonClick:),
        @selector(beautyButtonClick:),
        @selector(settingsAction:),
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
    _togCameraButton = buttons[index ++];
    _beautyButton = buttons[index ++];
    _settingsButton = buttons[index ++];
    _stopButton = buttons[index ++];

    _beautyButton.selected = YES; // 默认打开美颜
    
    _commentButton.hidden = YES;
    _stopButton.hidden = YES;
    
    CGFloat buttonWidth = QN_BOTTOM_BUTTON_WIDTH;
    NSInteger space = (UIScreen.mainScreen.bounds.size.width - buttonWidth * 5)/4;
    
    NSArray *array = [NSArray arrayWithObjects:buttons count:5];
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
}

- (void)readyUIView {
    self.pkListView = [[QNPKUserListView alloc] initWithFrame:CGRectMake(0, QN_KSCREEN_HEIGHT, QN_KSCREEN_WIDTH, 300) listArray:[NSMutableArray array] state:0];
    self.pkListView.delegate = self;
    [self.view addSubview:_pkListView];
    
    self.listView = [[QNPKUserListView alloc] initWithFrame:CGRectMake(0, QN_KSCREEN_HEIGHT, QN_KSCREEN_WIDTH, 300) listArray:[NSMutableArray array] state:1];
    self.listView.delegate = self;
    [self.listView.exitButton addTarget:self action:@selector(stopPKState:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_listView];
        
    self.settingsView = [[QNLiveSettingsView alloc] initWithFrame:CGRectMake(0, QN_KSCREEN_HEIGHT, QN_KSCREEN_WIDTH, 320) listArray:[NSMutableArray arrayWithArray:@[@"摄像头开关", @"麦克风开关", @"扬声器开关", @"闪光灯开关"]]];
    self.settingsView.delegate = self;
    [self.view addSubview:_settingsView];
    
    _editAlertView = [[QNEditAlertView alloc] initWithFrame:self.view.bounds person:NO title:@"修改房间名" text:self.roomName];
    _editAlertView.delegate = self;
}

- (void)exchangeButtonViewsStyle:(BOOL)isPK {
    NSArray *buttonArray = @[_commentButton, _togCameraButton, _beautyButton, _settingsButton, _stopButton];
    NSArray *iconArray;
    if (isPK) {
        iconArray = @[
            @"icon_chat_pk",
            @"icon_recers_pk",
            @"icon_Beauty_pk",
            @"icon_set up_pk",
            @"icon_small close_pk"
        ];
    } else {
        iconArray = @[
            @"icon_chat",
            @"icon_recers",
            @"icon_Beauty",
            @"icon_set up",
            @"icon_small close"
        ];
    }
    for (int i = 0; i < buttonArray.count; i ++) {
        UIButton *button = buttonArray[i];
        [button setImage:[UIImage imageNamed:iconArray[i]] forState:(UIControlStateSelected)];
        [button setImage:[UIImage imageNamed:iconArray[i]] forState:(UIControlStateNormal)];
    }
}

# pragma mark - actions

- (void)startLiveAction:(UIButton *)startButton {
    [self.alertContentView addAlertContent:@"开启直播中..." bgView:self.view];
    _startForwardButton.selected = YES;
    self.startForwardButton.hidden = YES;
    [self createLiveRoomAccordingSituation];
}

- (void)audienceAction:(UIButton *)listButton {
    QNSigleAlertView *sigleView = [[QNSigleAlertView alloc]init];
    NSString *number = @"0";
    if (![self.roomNumberLabel.text isEqualToString:@""]) {
        number = self.roomNumberLabel.text;
    }
    NSString * audienceNote = [NSString stringWithFormat:@"当前观看人数: %@",number];
    [sigleView showAlertViewTitle:audienceNote bgView:self.view];
}


- (void)commentAction:(UIButton *)beautyButton {
    if ([[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] isLogin]) {
        UITapGestureRecognizer *resetBottomTapGesture =[[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(resetBottomGesture:)];
        resetBottomTapGesture.delegate = self;
        [self.view addGestureRecognizer:resetBottomTapGesture];
        [self.chatRoomView.inputBar setHidden:NO];
        [self.chatRoomView.inputBar  setInputBarStatus:RCCRBottomBarStatusKeyboard];
        self.chatRoomView.isSendDanmaku = NO;
    } else {
        NSLog(@"IM 未登录！");
    }
}

- (void)beautyButtonClick:(UIButton *)beautyButton {
    beautyButton.selected = !beautyButton.selected;
    [self.engine setBeautifyModeOn:beautyButton.selected];
}

- (void)toggleButtonClick:(UIButton *)button {
    // 切换摄像头（前置/后置）
    [self.engine toggleCamera];
    if (self.engine.captureDevicePosition == AVCaptureDevicePositionFront) {
        [self.settingsView updateCameraBack:NO];
    } else{
        [self.settingsView updateCameraBack:YES];
    }
}

- (void)settingsAction:(UIButton *)settingsButton {
    [UIView animateWithDuration:0.2 animations:^{
        self.settingsView.frame = CGRectMake(0, QN_KSCREEN_HEIGHT - 320, QN_KSCREEN_WIDTH, 320);
    }];
}

- (void)leaveAction:(UIButton *)stopButton {
    if (self.liveState == 1) {
        [self.engine stopForwardJobWithJobId:[NSString stringWithFormat:@"forward-%@", self.userId]];
    }
    if (self.liveState == 2) {
        [self.engine stopMergeStreamWithJobId:[NSString stringWithFormat:@"merge-%@", self.userId]];
    }
    [self.engine leaveRoom];
    
    RCChatroomUserQuit *quitChatroomMessage = [[RCChatroomUserQuit alloc]init];
            [quitChatroomMessage setId:self.userId];
    [self.chatRoomView sendMessage:quitChatroomMessage pushContent:nil success:nil error:nil];

    [self.chatRoomView removeFromSuperview];
    [self getback];
}

- (void)enterPKView {
    // 显示可 pk 列表
    [self showListView];
}

- (void)showListView {
    if (self.liveState == 1) {
        if (self.pkListView.frame.origin.y == QN_KSCREEN_HEIGHT) {
            [QNNetworkRequest requestWithUrl:QN_GET_PK_ROOMS requestType:QNRequestTypeGet dic:nil header:[NSString stringWithFormat:@"Bearer %@", self.defaultDic[@"token"]] success:^(NSDictionary * _Nonnull resultDic) {
                NSLog(@"QN_GET_PK_ROOMS resultDic --- %@", resultDic);
                if ([resultDic.allKeys containsObject:@"rooms"] && [resultDic[@"rooms"] isKindOfClass:[NSArray class]]) {
                    [self.pkListView updateListArray:resultDic[@"rooms"]];
                    [UIView animateWithDuration:0.2 animations:^{
                        self.pkListView.frame = CGRectMake(0, QN_KSCREEN_HEIGHT - 300, QN_KSCREEN_WIDTH, 300);
                    }];
                } else {
                    if ([resultDic.allKeys containsObject:@"code"]) {
                        QNSigleAlertView *sigleView = [[QNSigleAlertView alloc]init];
                        [sigleView showAlertViewTitle:@"获取可 PK 列表发生异常！" bgView:self.view];
                    }
                }
            } error:^(NSError * _Nonnull error) {
                NSLog(@"QN_GET_PK_ROOMS error --- %@", error);
                QNSigleAlertView *sigleView = [[QNSigleAlertView alloc]init];
                [sigleView showAlertViewTitle:[NSString stringWithFormat:@"获取可 PK 列表失败 %ld", (long)error.code] bgView:self.view];
            }];
        }
    }
    if (self.liveState == 2) {
        NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:self.nickNameArray];
        [self.listView updateListArray:[NSMutableArray arrayWithArray:[mutableArray copy]]];
        [UIView animateWithDuration:0.2 animations:^{
            self.listView.frame = CGRectMake(0, QN_KSCREEN_HEIGHT - 300, QN_KSCREEN_WIDTH, 300);
        }];
    }
}

- (void)changeRoomName:(UIButton *)button {
    if (![self.view.subviews containsObject:_editAlertView]) {
        [self.view addSubview:_editAlertView];
    }
}

- (void)getback {
    if (self.liveState == 2 || self.liveState == 1) {
        self.liveState = 0;
        [self.engine leaveRoom];
        [self sendDictionary:nil withCommandType:@"disconnect"];
    }
    self.engine = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)stopPKState:(UIButton *)button {
    [self hideAllUIView];
    if (self.isAdmin) {
        NSLog(@"stopPKState: %@", self.roomId);
        [self endPK:self.roomId];
    } else{
        NSLog(@"stopPKState: %@", self.pkRoomId);
        [self endPK:self.pkRoomId];
    }
}

#pragma mark - QNDialogAlertViewDelegate
- (void)alertView:(QNDialogAlertView *)alertView didSelectedTitleIndex:(NSInteger)titleIndex {
    NSLog(@"alertView - titleIndex: %ld", titleIndex);

    if ([alertView isEqual:_pkNotifyView]) {
        [_pkNotifyView hideAlertView];
        BOOL accept;
        if (titleIndex == 1) {
            self.liveState = 2;
            self.pkBgView.hidden = NO;
            accept = YES;
            if (alertView.userId.length != 0 && alertView.nickName.length != 0) {
                [self.nickNameArray addObject:@{@"userId":alertView.userId,@"nickname":alertView.nickName}];
            }
        } else{
            self.liveState = 1;
            accept = NO;
        }
        [self replyPK:_pkNotifyView.roomId accept:accept];
        [self.engine stopForwardJobWithJobId:[NSString stringWithFormat:@"forward-%@", self.userId] delayMillisecond:QN_DELAY_MS];
        self.pkButton.selected = YES;
    }
}

# pragma mark - QNPKUserListViewDelegate
- (void)listView:(QNPKUserListView *)listView didSelectedIndex:(NSInteger)titleIndex {
    NSLog(@"listView - titleIndex: %ld", titleIndex);
    [self hideAllUIView];
    
    if ([listView isEqual:_pkListView]) {
        NSDictionary *dic = _pkListView.listArray[titleIndex];
        self.pkUserId = dic[@"creator"][@"id"];
        self.pkNickName = dic[@"creator"][@"nickname"];
        [self startPK:dic[@"id"]];
    }
}

# pragma mark - QNLiveSettingsViewDelegate

- (void)settingsView:(QNLiveSettingsView *)settingsView didSelectedIndex:(NSInteger)titleIndex enable:(BOOL)enable {
    NSLog(@"settingsView - titleIndex: %ld enable: %d", titleIndex, enable);
    if (titleIndex == 0) {
        self.muteVideo = !enable;
        [self.engine muteVideo:!enable];
    }
    if (titleIndex == 1) {
        self.muteAudio = !enable;
        [self.engine muteAudio:!enable];
    }
    if (titleIndex == 2) {
        self.muteSpeaker = !enable;
        [self.engine setMuteSpeaker:!enable];
    }
    if (titleIndex == 3) {
        self.torchOn = enable;
        [self.engine setTorchOn:enable];
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

# pragma mark - requests

- (void)createLiveRoomAccordingSituation {
    [QNNetworkRequest requestWithUrl:QN_GET_CREATE_ROOM(self.userId) requestType:QNRequestTypeGet dic:nil header:[NSString stringWithFormat:@"Bearer %@", self.defaultDic[@"token"]] success:^(NSDictionary * _Nonnull resultDic) {
        NSLog(@"QN_GET_CREATE_ROOM resultDic --- %@", resultDic);
        if (resultDic[@"rooms"] != [NSNull null]) {
            NSArray *array = resultDic[@"rooms"];
            NSDictionary *dic = array[0];
            // 存在房间先手动关闭之前的房间
            [self closeLiveRoom:dic[@"id"]];
        } else{
            [self creatLiveRoom];
        }
    } error:^(NSError * _Nonnull error) {
        [self.alertContentView removeAlertContentView];
        NSLog(@"QN_GET_CREATE_ROOM error --- %@", error);
        QNSigleAlertView *sigleView = [[QNSigleAlertView alloc]init];
        [sigleView showAlertViewTitle:[NSString stringWithFormat:@"获取创建列表失败 %ld", (long)error.code] bgView:self.view];
    }];
}

- (void)creatLiveRoom {
    [QNNetworkRequest requestWithUrl:QN_CREATE_ROOM requestType:QNRequestTypePost dic:@{@"userID":self.defaultDic[@"id"], @"roomName":self.roomName, @"roomType":@"pk"} header:[NSString stringWithFormat:@"Bearer %@", self.defaultDic[@"token"]] success:^(NSDictionary * _Nonnull resultDic) {
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

- (void)closeLiveRoom:(NSString *)roomId {
    [QNNetworkRequest requestWithUrl:QN_CLOSE_ROOM requestType:QNRequestTypePost dic:@{@"userID":self.defaultDic[@"id"], @"roomID":roomId} header:[NSString stringWithFormat:@"Bearer %@", self.defaultDic[@"token"]] success:^(NSDictionary * _Nonnull resultDic) {
        [self creatLiveRoom];
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
            NSLog(@"live view QN_IM_USER_TOKEN resultDic --- %@", resultDic);
            if ([resultDic.allKeys containsObject:@"token"]) {
                [[NSUserDefaults standardUserDefaults] setObject:resultDic[@"token"] forKey:@"QN_USER_IM_TOKEN"];
                [self joinChatRoomWithToken:imToken userName:self.defaultDic[@"nickname"] avatar:imageString];
            }
        } error:^(NSError * _Nonnull error) {
            NSLog(@"live view QN_IM_USER_TOKEN error --- %@", error);
            QNSigleAlertView *sigleView = [[QNSigleAlertView alloc]init];
            [sigleView showAlertViewTitle:[NSString stringWithFormat:@"获取 IM token 失败 %ld", (long)error.code] bgView:self.view];
        }];
    } else {
        [self joinChatRoomWithToken:imToken userName:self.defaultDic[@"nickname"] avatar:imageString];
    }
}

- (void)updateAudienceCount {
    if (self.liveState == 1) {
        [QNNetworkRequest requestWithUrl:QN_GET_PK_ROOMS requestType:QNRequestTypeGet dic:nil header:[NSString stringWithFormat:@"Bearer %@", self.defaultDic[@"token"]] success:^(NSDictionary * _Nonnull resultDic) {
            NSLog(@"QN_GET_PK_ROOMS resultDic --- %@", resultDic);
            if ([resultDic.allKeys containsObject:@"rooms"] && [resultDic[@"rooms"] isKindOfClass:[NSArray class]]) {
                [self.pkListView updateListArray:resultDic[@"rooms"]];
            } else {
                if ([resultDic.allKeys containsObject:@"code"]) {
                    QNSigleAlertView *sigleView = [[QNSigleAlertView alloc]init];
                    [sigleView showAlertViewTitle:@"获取可 PK 列表发生异常！" bgView:self.view];
                }
            }
        } error:^(NSError * _Nonnull error) {
            NSLog(@"QN_GET_PK_ROOMS error --- %@", error);
        }];
    }
    [QNNetworkRequest requestWithUrl:QN_LIVE_ROOMID(self.roomId) requestType:QNRequestTypeGet dic:nil header:[NSString stringWithFormat:@"Bearer %@", self.defaultDic[@"token"]] success:^(NSDictionary * _Nonnull resultDic) {
        NSLog(@"QN_LIVE_ROOMID resultDic --- %@", resultDic);
        if ([resultDic.allKeys containsObject:@"audienceNumber"]) {
            self.roomNumberLabel.text = [NSString stringWithFormat:@"%@", resultDic[@"audienceNumber"]];
        }
    } error:^(NSError * _Nonnull error) {
        NSLog(@"QN_LIVE_ROOMID error --- %@", error);
    }];
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
        self.pkListView.frame = CGRectMake(0, QN_KSCREEN_HEIGHT, QN_KSCREEN_WIDTH, 300);
        self.listView.frame = CGRectMake(0, QN_KSCREEN_HEIGHT, QN_KSCREEN_WIDTH, 300);
        self.settingsView.frame = CGRectMake(0, QN_KSCREEN_HEIGHT, QN_KSCREEN_WIDTH, 320);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    for (UITouch * touch in touches) {
        if (![touch.view isEqual:self.effectListView] &&
            ![touch.view isEqual:self.stickerListView] &&
            ![touch.view.class isEqual:[BETextSliderView class]]) {
            [self hideEffectView];
            [self hideStickerView];
        }
    }
    [self hideAllUIView];
}

- (QNRoomUserView *)userViewWithUserId:(NSString *)userId {
    @synchronized(self.userViewArray) {
        for (QNRoomUserView *userView in self.userViewArray) {
            if ([userView.userId isEqualToString:userId]) {
                return userView;
            }
        }
    }
    return nil;
}

- (void)resetRenderViews {
    @synchronized (self) {
        
        NSArray *allRenderView = self.renderBackgroundView.subviews;
        if (1 == allRenderView.count) {
            [allRenderView[0] mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.renderBackgroundView);
            }];
        } else if (2 == allRenderView.count) {
            [allRenderView[0] mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.renderBackgroundView.mas_left);
                make.top.mas_equalTo(QN_KSCREEN_HEIGHT*4/23);
                make.width.mas_equalTo(QN_KSCREEN_WIDTH/2);
                make.height.mas_equalTo(QN_KSCREEN_WIDTH/9*8);
            }];
            
            [allRenderView[1] mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.renderBackgroundView.mas_right);
                make.top.mas_equalTo(QN_KSCREEN_HEIGHT*4/23);
                make.width.mas_equalTo(QN_KSCREEN_WIDTH/2);
                make.height.mas_equalTo(QN_KSCREEN_WIDTH/9*8);
            }];
            [self.renderBackgroundView bringSubviewToFront:allRenderView[1]];
        }
    }
}

- (QNRoomUserView *)createUserViewWithTrackId:(NSString *)trackId userId:(NSString *)userId {
    QNRoomUserView *userView = [[QNRoomUserView alloc] init];
    userView.userId = userId;
    userView.trackId = trackId;
    return userView;
}

- (void)addRenderViewToSuperView:(QNRoomUserView *)renderView {
    @synchronized(self.renderBackgroundView) {
        if (![[self.renderBackgroundView subviews] containsObject:renderView]) {
            [self.renderBackgroundView addSubview:renderView];
            
            [self resetRenderViews];
        }
    }
}

- (void)removeRenderViewFromSuperView:(QNRoomUserView *)renderView {
    @synchronized(self.renderBackgroundView) {
        if ([[self.renderBackgroundView subviews] containsObject:renderView]) {
            [renderView removeFromSuperview];
            
            [self resetRenderViews];
        }
    }
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

- (void)startPK:(NSString *)pkRoomID {
    NSLog(@"startPK: %@", pkRoomID);
    dispatch_async(self.operationQueue, ^{
        NSDictionary *dic = @{@"pkRoomID": pkRoomID,
                              @"rpcID": @"1"};
        [self sendDictionary:dic withCommandType:@"start-pk"];
    });
}

- (void)replyPK:(NSString *)pkRoomID accept:(BOOL)accept {
    NSLog(@"replyPK: %@ accept: %d", pkRoomID, accept);
    dispatch_async(self.operationQueue, ^{
        NSDictionary *dic = @{@"reqRoomID": pkRoomID,
                              @"rpcID": @"3",
                              @"accept":@(accept)};
        [self sendDictionary:dic withCommandType:@"answer-pk"];
    });
}

- (void)endPK:(NSString *)pkRoomID {
    NSLog(@"endPK: %@", pkRoomID);
    dispatch_async(self.operationQueue, ^{
        NSDictionary *dic = @{@"pkRoomID": pkRoomID,
                              @"rpcID": @"7"};
        [self sendDictionary:dic withCommandType:@"end-pk"];
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
        
    if ([type isEqualToString:@"start-pk-res"]) {
        NSLog(@"didReceiveStartPKResponse - dic %@", dic);
        if ([dic.allKeys containsObject:@"code"]) {
            NSInteger code = [dic[@"code"] integerValue];
            if (code == 10012) {
                QNSigleAlertView *alertView = [[QNSigleAlertView alloc] init];
                [alertView showAlertViewTitle:@"主播已收到其他人的 pk 请求！" bgView:self.view];
            }
        }
    }
    
    if ([type isEqualToString:@"on-pk-offer"]) {
        self.pkNotifyView = [[QNDialogAlertView alloc] initWithFrame:CGRectMake(0, 0, 300, 200) title:@"连麦互动" request:YES content: [NSString stringWithFormat:@"%@请求与你 PK", dic[@"nickname"]] buttonArray:@[@"拒绝 TA", @"开始 PK"]];
        self.pkNotifyView.center = self.view.center;
        self.pkNotifyView.roomId = dic[@"roomID"];
        self.pkNotifyView.userId = dic[@"userID"];
        self.pkNotifyView.nickName = dic[@"nickname"];
        self.pkNotifyView.delegate = self;
        [self.view addSubview:_pkNotifyView];
        
        self.isAdmin = YES;
    }
    
    if ([type isEqualToString:@"answer-pk-res"]) {
        NSLog(@"didReceiveAnswerPKResponse - dic %@", dic);
    }
    
    if ([type isEqualToString:@"on-pk-answer"]) {
        NSLog(@"didReceiveOnPKAnswer - dic %@", dic);
        BOOL accept = [dic[@"accepted"] boolValue];
        if (!accept) {
            self.pkUserId = @"";
            self.pkNickName = @"";

            self.resultAlertView = [[QNDialogAlertView alloc] initWithFrame:CGRectMake(0, 0, 300, 200) title:@"连麦互动" request:NO content:@"主播拒绝了你的 PK 请求" buttonArray:@[@" 好吧 主播好残忍 "]];
            self.liveState = 1;
            self.resultAlertView.center = self.view.center;
            [self.view addSubview:_resultAlertView];
        } else{
            self.isAdmin = NO;
            self.layouts = [NSMutableArray array];
            if (self.pkUserId.length != 0 && self.pkNickName.length != 0) {
                [self.nickNameArray addObject:@{@"userId":self.pkUserId, @"nickname":self.pkNickName}];
            }
            // PK 请求被接受
            [self.engine stopForwardJobWithJobId:self.roomId];
            self.liveState = 2;
            self.pkButton.selected = YES;
            [self.engine leaveRoom];
            self.pkToken = dic[@"rtcRoomToken"];
            self.pkRoomId = dic[@"rtcRoom"];
            // 进入 PK 主播间
            [self.engine joinRoomWithToken:self.pkToken];
            self.pkBgView.hidden = NO;
        }
    }
    
    if ([type isEqualToString:@"end-pk-res"]) {
        NSLog(@"didReceiveEndPKResponse - dic %@", dic);
        self.liveState = 1;
        if (self.isAdmin) {
            NSLog(@"didReceiveEndPKResponse - self.isAdmin");
            NSArray *array = [NSArray arrayWithArray:self.nickNameArray];
            for (NSDictionary *dic in array) {
                if (![dic.allValues containsObject:self.userId]) {
                    [self.nickNameArray removeObject:dic];
                }
            }

            [self.engine stopMergeStreamWithJobId:self.roomId delayMillisecond:QN_DELAY_MS];
            self.serialNum++;
            self.forwardConfig.publishUrl = [NSString stringWithFormat:@"rtmp://pili-publish.qnsdk.com/sdk-live/%@?serialnum=%@", self.userId, @(self.serialNum)];
            self.forwardConfig.audioTrackInfo = self.audioTrackInfo;
            self.forwardConfig.videoTrackInfo = self.cameraTrackInfo;
            self.forwardConfig.jobId = [NSString stringWithFormat:@"forward-%@", self.userId];
            [self.engine createForwardJobWithConfiguration:self.forwardConfig];
        } else{
            NSArray *array = [NSArray arrayWithArray:self.nickNameArray];
            for (NSDictionary *dic in array) {
                if (![dic.allValues containsObject:self.pkUserId]) {
                    [self.nickNameArray removeObject:dic];
                }
            }
            [self.engine stopMergeStreamWithJobId:self.roomId];
            [self.engine leaveRoom];
            [self refreshJoinRoom];
        }
    }
    
    if ([type isEqualToString:@"on-pk-end"]) {
        NSLog(@"didReceiveOnPKEnd - dic %@", dic);
        self.liveState = 1;
        if (self.isAdmin) {
            NSLog(@"didReceiveOnPKEnd - self.isAdmin");
            NSArray *array = [NSArray arrayWithArray:self.nickNameArray];
            for (NSDictionary *dic in array) {
                if (![dic.allValues containsObject:self.userId]) {
                    [self.nickNameArray removeObject:dic];
                }
            }

            [self.engine stopMergeStreamWithJobId:self.roomId delayMillisecond:QN_DELAY_MS];
            self.serialNum++;
            self.forwardConfig.publishUrl = [NSString stringWithFormat:@"rtmp://pili-publish.qnsdk.com/sdk-live/%@?serialnum=%@", self.userId, @(self.serialNum)];
            self.forwardConfig.audioTrackInfo = self.audioTrackInfo;
            self.forwardConfig.videoTrackInfo = self.cameraTrackInfo;
            self.forwardConfig.jobId = [NSString stringWithFormat:@"forward-%@", self.userId];;
            [self.engine createForwardJobWithConfiguration:self.forwardConfig];
        } else{
            NSArray *array = [NSArray arrayWithArray:self.nickNameArray];
            for (NSDictionary *dic in array) {
                if (![dic.allValues containsObject:self.pkUserId]) {
                    [self.nickNameArray removeObject:dic];
                }
            }
            [self.engine stopMergeStreamWithJobId:self.roomId];
            [self.engine leaveRoom];
            [self refreshJoinRoom];
        }
    }
    
    if ([type isEqualToString:@"on-pk-timeout"]) {
        NSLog(@"didReceivePKTimeout - dic %@", dic);
        if (self.isAdmin) {
            if ([self.view.subviews containsObject:self.pkNotifyView]) {
                [self.pkNotifyView hideAlertView];
            }
        } else {
            self.pkUserId = @"";
            self.pkNickName = @"";
        }
        self.resultAlertView = [[QNDialogAlertView alloc] initWithFrame:CGRectMake(0, 0, 300, 200) title:@"连麦互动" request:NO content:@"PK 请求已超时！" buttonArray:@[@" 我知道了 "]];
        self.resultAlertView.center = self.view.center;
        [self.view addSubview:_resultAlertView];
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

@end
