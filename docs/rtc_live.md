# 概述
## 场景说明

互动直播解决方案通过将七牛实时音视频、字节跳动美颜滤镜以及融云 IM 融合到一起，提供音视频直播、PK 直播、高级美颜滤镜、房间消息、刷礼物等功能，帮助开发者快速构建秀场直播等相关应用。

## 场景优势

互动直播解决方案提供高清、流畅、低延时的直播 PK 体验，通过七牛实时音视频的服务端合流等功能，提供了直播到 PK 的无缝衔接体验，同时支持自定义帧率、码率等丰富的自定义配置。通过字节跳动高级美颜滤镜的接入，提供了更丰富、更有趣的体验，为直播增添了更多的乐趣。同时接入融云 IM 实现了主播、观众端间的实时消息同步，使二者可以进行更好的沟通。

## 功能列表

| 主要功能 | 功能描述 |
|------- | --------|
| 音视频、PK 直播 | 高清、流畅、低延时的直播场景，直播、PK 无缝切换 |
| 高级美颜滤镜 | 实时的高级美颜滤镜特效，提供更高的可玩性 |
| IM 消息 | 支持主播、观众间的实时消息同步，沟通更顺畅 |

# 场景实现
## 开发准备

### 设备以及系统要求

- 设备要求：iPhone 6 及以上
- 系统要求：iOS 9.0 及以上

### 开发环境

- Xcode 开发工具。App Store [下载地址](https://itunes.apple.com/us/app/xcode/id497799835?ls=1&mt=12)
- 安装 CocoaPods。了解 CocoaPods 使用方法。[官方网站](https://cocoapods.org)

## 直播 PK 模块场景实现
### SDK 下载集成
#### 实时音视频
- [iOS 体验 Demo 以及 SDK 下载地址](https://github.com/pili-engineering/QNRTC-iOS)
- [iOS 接口参考 Demo](https://github.com/pili-engineering/QNRTC-SampleCode-Video-Basic)

#### 导入 SDK

可选择手动导入或 Cocoapods 导入

##### 通过 CocoaPods 导入

[CocoaPods](https://cocoapods.org/) 是针对 Objective-C 的依赖管理工具，它能够将使用类似 QNRTCKit 的第三方库的安装过程变得非常简单和自动化，你能够用下面的命令来安装它：

```bash
$ sudo gem install cocoapods
```

###### Podfile

为了使用 CoacoaPods 集成 QNRTCKit 到你的 Xcode 工程当中，你需要编写你的 `Podfile`

```ruby
target 'TargetName' do
pod 'QNRTCKit'
end
```

- 默认为真机版
- 若需要使用模拟器 + 真机版，则改用如下配置

```
pod "QNRTCKit", :podspec => 'https://raw.githubusercontent.com/pili-engineering/QNRTC-iOS/master/QNRTCKit-universal.podspec'
```

**注意：鉴于目前上架 App Store 时只支持动态库真机版本，请在 App 上架前更换至真机版本**

然后，运行如下的命令：

```bash
$ pod install
```

##### 手动导入

[点击这里下载](https://github.com/pili-engineering/QNRTC-iOS/tree/master/Pod)相应版本的 SDK，将下载好的动态库文件 QNRTCKit.framework 导入到你的 Xcode 工程当中。

QNRTCKit.framework 目录下的具体内容列举如下：

| 文件名称               | 功能    | 大小    |       备注           |
| --------------------- | -----  | -----  | -------------------  |
| QNRTCKit | SDK | 22.5MB | 必须依赖               |
| Headers | framework暴露的所有头文件 | 81KB | 必须依赖  |
| Info.plist | .framework 包含的项目配置信息 | 728字节 | 必须依赖  |
| Modules | 模块相关文件夹 | 97字节 | 必须依赖 |

动态库 QNRTCKit.framework 链接到工程中的方式，见下图所示：

![](https://odum9helk.qnssl.com/FgMxhPJnx_-7cx-Dr2kseDfE3OKE)

在需要使用的类中，引入后使用

```Objective-C
#import <QNRTCKit/QNRTCKit.h>
```

#### 添加相关权限

我们需要在 Info.plist 文件中添加相应权限的说明，否则程序在 iOS 10 及以上系统会出现崩溃。需要添加如下权限：

- 麦克风权限：Privacy - Microphone Usage Description 是否允许 App 使用麦克风
- 相机权限：Privacy - Camera Usage Description 是否允许 App 使用相机

**SDK 集成完成后便可以使用七牛实时音视频 SDK 进行直播、PK 场景的实现了，具体使用步骤请参考下文**

### SDK 基础使用
为了实现直播 PK 功能场景，需要您务必先了解七牛实时音视频 SDK 的基础使用，包括`roomToken 的生成`，`加入房间`，`采集`，`发布`，`订阅` 等过程。

> **roomToken 生成过程** 可参考[七牛实时音视频云接入指南](https://doc.qnsdk.com/rtn/docs/rtn_startup)，下面将主要介绍加入房间等基本操作。

#### 初始化

首先，在 在 `ViewController.m` 中添加 engine 属性

```Objective-C
@property (nonatomic, strong) QNRTCEngine *engine;
```

创建连麦 `engine ` 对象

``` Objective-C
self.engine = [[QNRTCEngine alloc] init];
self.engine.delegate = self;
```
QNRTCEngineDelegate 包含了音视频通话过程中的所有重要的回调，需要遵守代理并实现相应的回调方法以获得回调。

#### 添加摄像头预览视图

将预览视图添加为当前视图的子视图

```Objective-C
[self.view insertSubview:self.engine.previewView atIndex:0];
```

#### 开始采集

开启采集后才能看到摄像头预览

```Objective-C
[self.engine startCapture];
```

#### 创建 Track

Track 是 v2.x.x 版本中推出的新概念，如果您对 Track 概念不太了解，请查看 SDK 概述中的[概念介绍](https://doc.qnsdk.com/rtn/ios/docs/preparation#4)。

本文主要介绍互动直播场景的搭建，所以我们创建一条视频 Track 和一条音频 Track，并将它们设置为 master 轨道，代码如下：

```Objective-C
QNTrackInfo *audioTrack = [[QNTrackInfo alloc] initWithSourceType:QNRTCSourceTypeAudio master:YES];

QNTrackInfo *cameraTrack =  [[QNTrackInfo alloc] initWithSourceType:(QNRTCSourceTypeCamera) tag:cameraTag master:YES bitrateBps:self.bitrate videoEncodeSize:self.videoEncodeSize];                                                     
```

#### 加入房间

调用以下接口加入房间：

```Objective-C
- (void)joinRoomWithToken:(NSString *)token;
```

加入房间成功后会触发如下回调：

```Objective-C
- (void)RTCEngine:(QNRTCEngine *)engine roomStateDidChange:(QNRoomState)roomState
``` 
状态会从 QNRoomStateConnecting 变为 QNRoomStateConnected。此时即可进行发布、订阅等操作。

在进入音视频通话房间之后，用户可以根据业务场景的需求在适当的时间调用离开房间的接口退出连麦，详情请见[房间管理](https://doc.qnsdk.com/rtn/ios/docs/room_management#1)。

#### 发布本地 Tracks

成功加入房间后，即可在如下回调中：

```Objective-C
- (void)RTCEngine:(QNRTCEngine *)engine roomStateDidChange:(QNRoomState)roomState
```
调用以下代码进行本地 Track 的发布：

```Objective-C
- (void)RTCEngine:(QNRTCEngine *)engine roomStateDidChange:(QNRoomState)roomState {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (QNRoomStateConnected == roomState) {
            [self.engine publishTracks:@[self.audioTrack, self.cameraTrack]];
        } 
    });
}
```

发布成功后，本地会收到如下回调：

```Objective-C
- (void)RTCEngine:(QNRTCEngine *)engine didPublishLocalTracks:(NSArray<QNTrackInfo *> *)tracks;
```

远端用户会收到如下回调：

```Objective-C
- (void)RTCEngine:(QNRTCEngine *)engine didPublishTracks:(NSArray<QNTrackInfo *> *)tracks ofRemoteUserId:(NSString *)userId;
```

另外，SDK 提供了如下几个接口：

```Objective-C
- (void)publish;
- (void)publishAudio;
- (void)publishVideo;
```

可利用这些接口快速发布作为 master 的音视频/视频/音频 Track，无需自行创建及管理 Track。

#### 订阅远端 Tracks

SDK 默认会进行自动订阅，订阅成功后将会收到如下回调：

```Objective-C
- (void)RTCEngine:(QNRTCEngine *)engine didSubscribeTracks:(NSArray<QNTrackInfo *> *)tracks ofRemoteUserId:(NSString *)userId;
```
 
在此回调内则可进行对 Track 的渲染窗口设置的操作：

```Objective-C
- (void)RTCEngine:(QNRTCEngine *)engine didSubscribeTracks:(NSArray<QNTrackInfo *> *)tracks ofRemoteUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
    	QNVideoRender *render = [[QNVideoRender alloc] init];
    	QNVideoView *videoView = [[QNVideoView alloc]initWithFrame: CGRectMake(360, 320, 360, 480)];
    	[self.view addSubview:videoView];
    	render.renderView = videoView;
    	return render;
   });
}
```

在成功订阅之后，用户可以根据业务场景的需求在适当的时间调用取消订阅的接口取消订阅相应的 Track，详情请见[发布与订阅](https://doc.qnsdk.com/rtn/ios/docs/publish_subscribe)

#### 单路转推任务

单路转推任务是指服务端对单独的一路音视频流进行转推的工作，主要适用于不包含连麦的`秀场直播`、`连麦中需要将某一路流单独转推落存储`等场景。详细使用接口可参考[单路转推](https://doc.qnsdk.com/rtn/ios/docs/live_solution#1_0)。

#### 合流转推任务

多路流合流直播场景，主要适用于`连麦互动直播`、`PK 直播`以及`单主播需要两路以上视频合流转推`等场景。简单来说，就是对连麦各方的视频画面进行合流，然后转推。详细使用接口可参考[服务端合流](https://doc.qnsdk.com/rtn/ios/docs/merge_stream)。

#### 离开房间

当音视频通话结束，调用以下代码离开房间：

```Objective-C
[self.engine leaveRoom];
```

#### 销毁

在整个 `ViewController` 销毁时，用户需要调用以下代码对资源进行释放，一般此操作建议在 `ViewController` 生命周期的 `- (void)dealloc;` 中进行，示例代码如下：

```Objective-C
- (void)dealloc {
    self.engine.delegate = nil;
    self.engine = nil;
}
```

> 七牛实时音视频 SDK 提供了丰富灵活的拓展接口，更多接口配置可参考[iOS 开发手册](https://doc.qnsdk.com/rtn/ios)

## 直播 PK 模块
### 直播场景

直播场景，即单主播直播的场景，仅将一路音视频流直接转推到直播服务器。适用于秀场直播、电商直播等场景。

场景示意图如下：

![单路流直播](http://docs.qnsdk.com/forward_job.jpg)

为了实现上述场景，您可以参考如下实现方式：

#### 创建单路转推任务

QNForwardStreamConfiguration 用于配置单路转推的相关信息，包括推流地址、参与合流的音视频轨，详细的接口设置可参考 [QNForwardStreamConfiguration](https://doc.qnsdk.com/rtn/ios/docs/api_qnforwardstreamconfiguration)。

创建转推任务的示例代码如下：

```Objective-C
// 创建单路转推任务配置对象
QNForwardStreamConfiguration *forwardConfig = [[QNForwardStreamConfiguration alloc] init];
// 创建 JobId
forwardConfig.jobId = self.roomName;
// 设置推流地址
forwardConfig.publishUrl = [NSString stringWithFormat:@"%@%@?serialnum=%@", self.publishHeader, self.roomName, @(self.serialNum)];
// 设置单路流中的音频轨，仅支持一路音频的设置，重复设置会被覆盖
forwardConfig.audioTrackInfo = self.audioTrackInfo;
// 设置单路流中的视频轨，仅支持一路视频的设置，重复设置会被覆盖
forwardConfig.videoTrackInfo = self.cameraTrackInfo;
// 创建单路流转推任务
[self.engine createForwardJobWithConfiguration:forwardConfig];
```

单路转推任务创建成功后，会触发如下回调接口：

```Objective-C
/**
 * 创建单路转推成功的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didCreateForwardJobWithJobId:(NSString *)jobId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"创建单路转推成功的回调 -- %@", jobId);
    });
}
```
创建成功即开启了单路流转推，可以通过相应的播放链接拉取直播流进行观看

**注意：**

**1. QNForwardStreamConfiguration 仅支持配置一路视频轨和一路音频轨，重复设置会被覆盖**

**2. 单路转推的场景下，请务必保证配置 `QNTrackInfo` 为固定分辨率，即 `setMaintainResolutionEnabled` 为 YES，否则会出现不可预期的问题！！！**

#### 停止单路转推任务

可以通过如下方式实现单路转推任务的停止：

```Objective-C
[self.engine stopForwardJobWithJobId:self.jobId];
```

### PK 场景
主播连麦 PK 场景指的是主播在直播时，可以对另外一个直播间的主播发起 PK 挑战，一旦挑战被接受，两个直播间的主播就会加入到同一个房间，并开始进行连麦互动。

与常规 1v1 连麦场景不同的是，PK 场景下直播界面会一分为二，每位主播各自的粉丝观看链接不会改变，但是可以同时看到两位主播的画面。

**为了更浅显易懂的让您了解从直播到 PK 场景切换的实现方式，我们预先设置如下背景：**

1. 主播 A、主播 B 在各自房间进行直播
2. 主播 A 对主播 B 发起直播请求，主播 B 接受主播 A 的 PK 请求并进行处理
3. 主播 B 在同意主播 A 的 PK 请求后，切换推流任务为合流转推任务
4. 主播 A 收到主播 B 同意 PK 的请求后，离开自己房间并加入到主播 B 的房间开启合流转推任务进行 PK
4. PK 结束后，主播 A 需要离开主播 B 的直播间并回到自己的直播间进行直播，两位主播需要切换推流任务为单路转推任务

基于上述背景，您可以参考如下实现方式：

#### 直播场景切换到 PK 场景

在上述背景中，每一个主播在单独直播的时候都会维护一个 `QNForwardStreamConfiguration` 任务实例，在主播切换到 PK 场景时，主播 A 和主播 B 的实现逻辑如下：

##### 主播 A
主播 A 在接收到主播 B 同意 PK 的请求之后，按照如下步骤进行操作：

- 停止本地维护的 QNForwardJob

```Objective-C
[self.engine stopForwardJobWithJobId:self.roomId];
```

- 离开自己的房间，并在成功离开房间的回调里面加入主播 B 的房间：

```Objective-C
// 离开自己的房间
[self.engine leaveRoom];

// 加入主播 B 的目标房间
[self.engine joinRoomWithToken:self.pkToken];
```

- 在成功加入主播 B 的房间后，创建并开启合流转推任务（**注意：单路转推任务和合流转推任务的推流地址不能改变**）

```Objective-C
// 在加入房间并发布成功之后，创建合流转推任务
// 根据是否是被邀请者实现本地/远端发布成功
/**
 * 调用 publish 发布本地音视频 tracks 后收到的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didPublishLocalTracks:(NSArray<QNTrackInfo *> *)tracks {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didPublishLocalTracks: %@", tracks);
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
        if (self.liveState == 2) {
            for (QNTrackInfo *trackInfo in tracks) {
                if (trackInfo.kind == QNTrackKindAudio) {
                    QNMergeStreamLayout *audioLayout = [[QNMergeStreamLayout alloc] init];
                    audioLayout.trackId = trackInfo.trackId;
                    [self.layouts addObject:audioLayout];
                }
                if (trackInfo.kind == QNTrackKindVideo) {
                    QNMergeStreamLayout *layout = [[QNMergeStreamLayout alloc] init];
                    layout.frame = CGRectMake(0, 320, 360, 640);
                    layout.zIndex = 0;
                    layout.trackId = trackInfo.trackId;
                    [self.layouts addObject:layout];
                }
            }
            NSLog(@"self.layouts - local %@", self.layouts);
                        
            if (self.layouts.count > 2) {
                self.serialNum++;
                self.mergeConfig.publishUrl = [NSString stringWithFormat:@"rtmp://pili-publish.qnsdk.com/sdk-live/%@?serialnum=%@", self.jobId, @(self.serialNum)];
                self.mergeConfig.jobId = self.jobId;
                [self.engine createMergeStreamJobWithConfiguration:self.mergeConfig];
            }
        }
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
                layout.frame = CGRectMake(0, 320, 360, 640);
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
                    layout.frame = CGRectMake(360, 320, 360, 640);
                    layout.zIndex = 0;
                    layout.trackId = trackInfo.trackId;
                    [self.layouts addObject:layout];
                }
            }
            NSLog(@"self.layouts - remote %@", self.layouts);
            
            if (self.layouts.count > 2) {
                self.serialNum++;
                self.mergeConfig.publishUrl = [NSString stringWithFormat:@"rtmp://pili-publish.qnsdk.com/sdk-live/%@?serialnum=%@", self.jobId, @(self.serialNum)];
                self.mergeConfig.jobId = self.jobId;
                [self.engine createMergeStreamJobWithConfiguration:self.mergeConfig];
            }
        }
    });
}

/**
 * 创建合流成功的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didCreateMergeStreamWithJobId:(NSString *)jobId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"创建合流成功的回调 -- %@", jobId);
        [self.engine setMergeStreamLayouts:self.layouts jobId:jobId];
        NSLog(@"didCreateMergeStreamWithJobId layouts -- %@", self.layouts);
    });
}
```

**经过上述步骤，主播 A 即可加入到主播 B 的直播间并进行互动 PK 了。其中，更详细的合流配置选项，可参考[合流配置](https://doc.qnsdk.com/rtn/ios/docs/merge_stream)文档**

##### 主播 B
主播 B 在同意主播 A 的 PK 请求后，由于主播 B 无需切换房间，所以步骤会先谷底简单些，具体步骤如下：

- 停止单路转推任务
- 创建合流转推任务
- 在适当的时机配置自己和主播 A 的合流布局进行合流直播

**经过上述操作，两端即可成功进入 PK 直播场景进行互动直播了**

#### PK 场景切换到直播场景

当主播 A 或者主播 B 有一端想要停止 PK 时，实现逻辑如下：

##### 主播 A
主播 A 退出 PK 时，首先要通知主播 B 自己要结束 PK，然后可按照如下步骤切换回单独的直播场景

- 停止合流转推任务

```Objective-C
[self.engine stopMergeStreamWithJobId:self.roomId];
```

- 离开主播 B 的房间，并加入到自己原有的房间

```Objective-C
// 离开主播 B 的房间
[self.engine leaveRoom];

// 更新本地 UI 为单直播场景，并重新加入原有的房间
[self.engine joinRoomWithToken:self.token];
```

- 成功回到自己房间之后，重新发布音视频 Track，并创建单路转推任务（**注意：单路转推任务和合流转推任务的推流地址不能改变**）

```Objective-C
// 发布音视频 Tracks
/**
 * 房间状态变更的回调。当状态变为 QNRoomStateReconnecting 时，SDK 会为您自动重连，如果希望退出，直接调用 leaveRoom 即可
 */
- (void)RTCEngine:(QNRTCEngine *)engine roomStateDidChange:(QNRoomState)roomState {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"roomStateDidChange: %@", roomStatus[roomState]);
        if (QNRoomStateConnected == roomState) {
            [self publish];
        }
    });
}

/**
 * 调用 publish 发布本地音视频 tracks 后收到的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didPublishLocalTracks:(NSArray<QNTrackInfo *> *)tracks {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didPublishLocalTracks: %@", tracks);
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
        
        if (self.liveState == 0 && self.audioTrackInfo && self.cameraTrackInfo) {
            self.liveState = 1;
            self.serialNum++;
            self.forwardConfig.publishUrl = [NSString stringWithFormat:@"rtmp://pili-publish.qnsdk.com/sdk-live/%@?serialnum=%@", self.jobId, @(self.serialNum)];
            self.forwardConfig.audioTrackInfo = self.audioTrackInfo;
            self.forwardConfig.videoTrackInfo = self.cameraTrackInfo;
            self.forwardConfig.jobId = self.jobId;
            [self.engine createForwardJobWithConfiguration:self.forwardConfig];
            if (!self.pkToken) {
                [self enterIMWithRequestToken];
                self.pkToken = nil;
                self.pkRoomId = nil;
                [self roomLabelIsCenter:NO];
                self.listButton.hidden = NO;
                self.pkButton.hidden = NO;
                self.roomNumberLabel.hidden = NO;
                self.editButton.hidden = YES;
                
                self.timer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(updateAudienceCount) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
            }
        }
    });
}
```

**经过上述步骤，主播 A 即可成功回到自己房间进行单主播直播了**

##### 主播 B
主播 B 退出 PK 时，由于并没有切换房间，所以步骤会相对简单些：

- 通知主播 A 要退出 PK 直播
- 创建单路转推任务
- 在单路转推任务创建成功后，停止合流转推任务

**经过上述步骤，主播 B 即可成功回到自己房间进行单主播直播了**

> **上述步骤是以伪代码的形式描述如何进行 PK 场景的直播，更详细的处理逻辑可参考 [QNRTCLive-iOS](https://github.com/pili-engineering/QNRTCLive-iOS)**

## 美颜模块
### SDK 下载集成
#### 下载和导入 SDK

请下载以下列表中包含的 jar 与 so ,并将其导入到项目中。

| 文件名称                              | 功能              | 大小     | 备注  |
| ----------------------------------- | ----------------- | ------- | ----- |
| PLSEffect.framework  | 特效插件 SDK 库     | 440KB    | 必须依赖 |
| libeffect-sdk.a | 高级特效插件核心库   | 99.4MB   | 必须依赖 |
| include 文件夹 | 高级特效插件接口层   | 70KB    | 必须依赖 |

#### 添加特效素材
购买的资源不同，相应的资源文件大小和特效数量也不同，下面以 demo 的资源包举例：   

| 文件名称                         | 文件类型                | 大小     | 备注                                                    |
| ------------------------------ | ---------------------- | ------- | ------------------------------------------------------- |
| LicenseBag.bundle              | 授权文件                | 1KB  | 该包内应包含有一个与包名所对应的授权文件，文件名内包含了所绑定的包名和授权的起止日期 |
| ComposeMakeup.bundle           | 高级美颜、美型、美妆素材   | 4.3MB   | 包含二十余款美颜、美型特效                                   |
| FilterResource.bundle          | 高级滤镜素材             | 12.3MB  | 包含 48 款滤镜                                            |
| StickerResource.bundle         | 动态贴纸素材             | 39.9MBB  | 包含 20 款动态贴纸                                        |
| ModelResource.bundle           | 模型文件                | 6.6MB   | 用于人脸识别、手势识别                                      |

- 如用户需要更多款式的美颜、美型、滤镜、动态贴纸素材，可在特效君 APP 上选择，联系七牛商务咨询进行购买。  
- **鉴权文件是有到期时间的，如果时间过期，需要替换 LicenseBag.bundle 文件为新申请的鉴权文件。所以需要在授权文件过期前，替换目标工程中的 LicenseBag.bundle 文件（建议支持 LicenseBag.bundle 的云端下发功能，此功能需要您自行实现）。**

#### 资源的配置处理

为了方便的获取特效的信息列表，首先应该对字节跳动的资源进行配置处理，分别为高级美颜、微整形、美妆、美体素材（ComposeMakeup.bundle）、高级滤镜素材（FilterResource.bundle）和动态贴纸素材（StickerResource.bundle）配置 config.json 文件与 icons 文件夹。

此项配置是为了后面可以通过调用类似于如下方法：

```Objective-C
- (NSArray<PLSEffectModel *> *)fetchEffectListWithType:(PLSEffectType)type;
```

可快速获取特效信息，投放入 `PLSEffectModel`来生成视图，也是为了可以通过云端下发特效文件和配置文件的方式在不更新 APP 的情况下更新特效资源。

由于资源配置的过程较为繁琐，我们为您提供了一个**处理脚本**，您只需将字节提供的 resource 和 icons 文件夹拷入脚本同级目录，在脚本所在目录下运行脚本即可，具体的使用方式请参见上级目录的 [ResourceTools](https://github.com/pili-engineering/QNRTC-ByteDance-iOS/tree/master/Document/ResourceTools) 文件夹，运行脚本成功后您可更改对应素材文件下的 config.json 文件来修改特效图标、特效名称、特效初始强度甚至特效所在类别等信息。

### 快速开始
#### 把资源从 assets 拷贝到手机本地目录

由于配置好的资源默认由 AssetManager 管理，存储于 apk 中，在安装后并不会解压到手机本地，无法取得绝对路径，所以为了更好的管理资源，需要把资源从 apk 拷贝到手机本地目录下。这里可以参考 demo 中的 LoadResourcesActivity 和 LoadResourcesTask 类。

#### 在程序中加载和使用资源
初始化 `PLSEffectDataManager` 以及 `PLSEffectManager`

```Objective-C
NSString *rootPath = [[NSBundle mainBundle] resourcePath];
PLSEffectConfiguration *effectConfiguration = [PLSEffectConfiguration new];
effectConfiguration.modelFileDirPath = [NSString pathWithComponents:@[rootPath, @"ModelResource.bundle"]];
effectConfiguration.licenseFilePath = [NSString pathWithComponents:@[rootPath, @"LicenseBag.bundle", @"xxxx.xxxx_v3.9.0.licbag"]];
_effectDataManager = [[PLSEffectDataManager alloc] initWithRootPath:rootPath];
    
self.effectManager = [PLSEffectManager sharedWith:[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] configuration:effectConfiguration];
```
`PLSEffectDataManager` 是提供特效相关接口的核心类，您可以通过它获取特效资源信息列表：

```Objective-C
//获取所有滤镜、贴纸信息
- (NSArray<PLSEffectModel *> *)fetchEffectListWithType:(PLSEffectType)type;
//获取所有美型信息
- (NSArray<PLSMakeUpComponentModel *> *)fetchMakeUpComponentsWithType:(PLSMakeUpComponentType)type;
//获取所有美妆信息
- (PLSMakeupModel *)fetchMakeUpWithType:(PLSMakeUpType)type;
``` 
需要说明的是，获取美妆信息的接口有所不同，因为美妆资源是二级列表，其结构如下：

```
├── 美妆模块
│   └── 口红
│       ├── 复古红
│       ├── 少女粉
│       ├── 西柚色
│       ├── 西瓜红
│       └── ***
│   └── 染发
│       ├── 暗蓝
│       ├── 墨绿
│       ├── 深棕
│       └── ***
│   └── 腮红
│       ├── 微醺
│       ├── 日常
│       ├── 蜜桃
│       └── ***
│   └── ***
```

```Objective-C
- (PLSMakeupModel *)fetchMakeUpWithType:(PLSMakeUpType)type;
```
以上接口返回的是一个`PLSMakeupModel`，可调用`model.effectList`来取得该类别的具体特效列表。

#### 特效处理

特效处理是我们的核心步骤，建议参考 demo 中的`QNLiveViewController`类。特效添加的原理是通过摄像机采集视频的回调函数得到每一帧视频的数据，然后把该数据送到 `PLSEffectManager` 中去做特效处理，最后把处理完成的纹理再传入实时音视频 SDK 中。

我们需要通过 QNRTCEngine 的摄像头数据回调接口：

```Objective-C
- (void)RTCEngine:(QNRTCEngine *)engine cameraSourceDidGetSampleBuffer:(CMSampleBufferRef)sampleBuffer;
``` 

来添加摄像机采集回调接口，进行特效处理，如下：

```Objective-C
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
```

#### 设置特效

特效的设置或更新是通过 `PLSEffectManager` 的一系列方法实现的，需要特别注意的是，设置或更新特效的方法需要在 OpenGL 线程中调用。

```Objective-C
// 设置美颜、微整形、美妆、美体等特效
- (BOOL)updateMakeupComponents:(NSArray<PLSMakeUpComponentModel *> *)components;
// 更新美颜、微整形、美妆、美体特效的强度
- (BOOL)updateMakeupComponentIntensity:(float)intensity withComponent:(PLSMakeUpComponentModel *)component;
// 设置滤镜特效
- (BOOL)updateFilter:(PLSEffectModel *)filter;
// 更新滤镜特效强度
- (BOOL)updateFilterIntensity:(float)intensity;
// 设置动态贴纸特效
- (BOOL)updateSticker:(PLSEffectModel *)sticker;
```
**凡是与特效相关的操作，包括设置、更新、处理等皆需要在渲染线程 (OpenGL 线程) 中调用**

```Objective-C
// 确定不再使用特效可以使用此方法释放特效资源
+ (void)releaseManager;
```

**如需了解具体的接口设计，可查看[此文档](https://github.com/pili-engineering/QNRTC-ByteDance-iOS/blob/master/Document/QNRTCKit-ByteDance.md)**


## IM 模块

直播互动解决方案的 IM 模块主要使用了融云 IM 的 IMLib SDK。在方案中内置了融云 IM 聊天室所使用的 AppKey 和服务器地址，如果您需要接入到您自己的配置，您需要做以下操作。  

1. [注册融云开发者](https://developer.rongcloud.cn/signup/?utm_source=demogithub&utm_term=demosign)，创建应用后获取 APPKey。
2. 部署 [SealLive-Server](https://github.com/rongcloud/demo-chatroom/tree/v2.0/app-server)，此 Demo 中的 App 服务器使用融云 SealLive 的 Server。(TODO 后续等我们的服务器开源之后，需要替换成我们自己的服务器。)
3. 服务部署完毕之后，请分别将源码中的 `APP_KEY`,`APPSERVER` 改为您自己的  
参见源码中文件  `QNRTCLiveDemo/QNAppDelegate.m`

### 功能模块介绍
融云 IM 聊天室相关代码目录是在 QNRTCLiveDemo/chatRoom 包中，由 RCChatRoomView、 View、 Utilities、 Model、 Message、 Manager、 InputBar、 Danmaku 等模块组成

* **RCChatRoomView:** IM 管理显示 view
* **Danmaku:** 弹幕展示相关内容。
* **Message：**  进入直播间、点赞等自定义消息信令。
* **Manager：** IM 管理类
* **Model：**  礼物信息、角色信息、房间信息等数据模型。
* **InputBar：** 输入栏相关内容。
* **Utilities：** 通用的一些工具类。
* **View** IM 礼物 View 显示类

### 使用到的融云产品
* **即时通讯 IMLib SDK**  可详细查看 [IMLib SDK 开发指南](https://www.rongcloud.cn/docs/ios.html)

# 服务常见错误码

| 错误码 | 描述 |
| -------- | -------- | -------- |
| 401003 | token 错误，通常出现于账号重复登录 |
| 404002 | 房间不存在 |
| 10001 | 消息不属于已知类型，无法解析 |
| 10002 | 信令认证用的 token 错误 |
| 10003 | 没有权限（观众发起请求等情况） |
| 10011 | 信令房间不存在 |
| 10012 | 房间正在 PK 连麦直播中，不能发起 PK |
| 10013 | 房间未在 PK 中，不能结束 PK |