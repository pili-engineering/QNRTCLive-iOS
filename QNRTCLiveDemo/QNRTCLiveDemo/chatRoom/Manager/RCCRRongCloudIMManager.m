//
//  RCCRRongCloudIMManager.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/9.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "RCCRRongCloudIMManager.h"
#import "RCCRLiveHttpManager.h"
#import "RCChatroomStart.h"
#import "RCChatroomLike.h"
#import "RCChatroomUserQuit.h"
#import "RCChatroomNotification.h"
#import "RCChatroomEnd.h"
#import "RCChatroomWelcome.h"
#import "RCChatroomGift.h"
#import "RCChatroomBarrage.h"
#import "RCChatroomSignal.h"

#define kDeviceUUID [[[UIDevice currentDevice] identifierForVendor] UUIDString]
NSString *const RCCRKitDispatchMessageNotification = @"RCCRKitDispatchMessageNotification";

NSString *const RCCRConnectChangeNotification = @"RCCRConnectChangeNotification";

@interface RCCRRongCloudIMManager () <RCConnectionStatusChangeDelegate, RCIMClientReceiveMessageDelegate>

@property (nonatomic, copy) NSString *appKey;

@end

static RCCRRongCloudIMManager *__rongUIKit = nil;

dispatch_queue_t __RCDLive_ConversationList_refresh_queue = NULL;

@implementation RCCRRongCloudIMManager

+ (instancetype)sharedRCCRRongCloudIMManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (__rongUIKit == nil) {
            __rongUIKit = [[RCCRRongCloudIMManager alloc] init];
            __RCDLive_ConversationList_refresh_queue = dispatch_queue_create("com.rongcloud.refreshConversationList", NULL);
        }
    });
    return __rongUIKit;
}

- (void)initRongCloud:(NSString *)appKey{
    if ([self.appKey isEqual:appKey]) {
        NSLog(@"Warning:请不要重复调用Init！！！");
        return;
    }
    self.appKey = appKey;
    [[RCIMClient sharedRCIMClient] initWithAppKey:appKey];
    // listen receive message
    [[RCIMClient sharedRCIMClient] setReceiveMessageDelegate:self object:nil];
    [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:self];
    //注册自定义消息
    [self registerRongCloudMessageType:[RCChatroomWelcome class]];
    [self registerRongCloudMessageType:[RCChatroomGift class]];
    [self registerRongCloudMessageType:[RCChatroomLike class]];
    [self registerRongCloudMessageType:[RCChatroomBarrage class]];
    [self registerRongCloudMessageType:[RCChatroomUserQuit class]];
    [self registerRongCloudMessageType:[RCChatroomStart class]];
    [self registerRongCloudMessageType:[RCChatroomEnd class]];
    [self registerRongCloudMessageType:[RCChatroomNotification class]];
    [self registerRongCloudMessageType:[RCChatroomSignal class]];
}

- (void)onConnectionStatusChanged:(RCConnectionStatus)status {

    NSDictionary *user = @{ @"status" : @(status) };
    [[NSNotificationCenter defaultCenter] postNotificationName:RCCRConnectChangeNotification
                                                        object:nil
                                                      userInfo:user];
}

- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object {
    
    NSDictionary *dic_left = @{ @"left" : @(nLeft) };
    // dispatch message
    [[NSNotificationCenter defaultCenter] postNotificationName:RCCRKitDispatchMessageNotification
                                                        object:message
                                                      userInfo:dic_left];
}

- (void)registerRongCloudMessageType:(Class)messageClass {
    [[RCIMClient sharedRCIMClient] registerMessageType:messageClass];
}
-(void)connectWithUserId:(NSString *)userId userName:(NSString *)userName portraitUri:(NSString *)portraitUri success:(void (^)(NSString *userId))successBlock
         error:(void (^)(RCConnectErrorCode status))errorBlock
          tokenIncorrect:(void (^)(void))tokenIncorrectBlock{
    RCConnectionStatus status = [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] getRongCloudConnectionStatus];
    if (status != ConnectionStatus_Connected) {
        if (!userId || userId.length <= 0) {
            userId = kDeviceUUID;
        }
        [[RCCRLiveHttpManager sharedManager] fetchTokenWithUserId:userId username:userName portraitUri:@"" completion:^(BOOL isSucccess, NSString * _Nullable token) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!isSucccess) {
                    NSLog(@"获取token失败");
                    if (errorBlock) {
                        errorBlock(0);
                    }
                } else{
                    RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:userId name:userName portrait:portraitUri];
                    //                    [self connectIM:token userInfo:userInfo];
                    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] connectRongCloudWithToken:token userName:userName portraitUri:portraitUri success:^(NSString *userId) {
                        if (![userInfo.userId isEqualToString:userId]) {
                            NSLog(@"id不一致");
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // 登录成功
                            [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] setCurrentUserInfo:userInfo];
                            [RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].isLogin = YES;
                            if (successBlock) {
                                successBlock(userId);
                            }
                            NSLog(@"连接成功");
                        });
                    } error:^(RCConnectErrorCode status) {
                        NSLog(@"连接失败， error code：%ld",(long)status);
                        NSLog(@"userId = %@, token = %@",userInfo.userId, token);
                        if (errorBlock) {
                            errorBlock(status);
                        }
                    } tokenIncorrect:^{
                        NSLog(@"连接失败，token无效");
                        if (tokenIncorrectBlock) {
                            tokenIncorrectBlock();
                        }
                    }];
                }
            });
            
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"已经连接");
            RCUserInfo *userinfo = [RCIMClient sharedRCIMClient].currentUserInfo;
            userinfo.name = userName;
            userinfo.portraitUri = portraitUri;
            [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] setCurrentUserInfo:userinfo];
            [RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].isLogin = YES;
            if (successBlock) {
                successBlock(userId);
            }
        });
    }
}

- (void)connectRongCloudWithToken:(NSString *)token
                         userName:(NSString *)userName
                      portraitUri:(NSString *)portraitUri
                          success:(void (^)(NSString *userId))successBlock
                            error:(void (^)(RCConnectErrorCode status))errorBlock
                   tokenIncorrect:(void (^)(void))tokenIncorrectBlock {
    
    
[[RCIMClient sharedRCIMClient] connectWithToken:token
       success:^(NSString *userId) {
    // 登录成功
    RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:userId name:userName portrait:portraitUri];
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] setCurrentUserInfo:userInfo];
    [RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].isLogin = YES;
           if (successBlock!=nil) {
               successBlock(userId);
           }
       }
         error:^(RCConnectErrorCode status) {
             if(errorBlock!=nil)
                 errorBlock(status);
         }
tokenIncorrect:^() {
    tokenIncorrectBlock();
}];

}

- (void)disconnectRongCloud{
    [[RCIMClient sharedRCIMClient] setReceiveMessageDelegate:nil object:nil];
    [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:nil];
    [[RCIMClient sharedRCIMClient] disconnect];
}

- (void)disconnectRongCloud:(BOOL)isReceivePush {
    [[RCIMClient sharedRCIMClient] setReceiveMessageDelegate:nil object:nil];
    [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:nil];
    [[RCIMClient sharedRCIMClient] disconnect:isReceivePush];
}

- (void)logoutRongCloud {
//    [[RCIMClient sharedRCIMClient] setReceiveMessageDelegate:nil object:nil];
//    [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:nil];
    [[RCIMClient sharedRCIMClient] logout];
}

- (RCMessage *)sendMessage:(RCConversationType)conversationType
                  targetId:(NSString *)targetId
                   content:(RCMessageContent *)content
               pushContent:(NSString *)pushContent
                  pushData:(NSString *)pushData
                   success:(void (^)(long messageId))successBlock
                     error:(void (^)(RCErrorCode nErrorCode,
                                     long messageId))errorBlock {
    content.senderUserInfo = [RCIMClient sharedRCIMClient].currentUserInfo;
    RCMessage *rcMessage = [[RCIMClient sharedRCIMClient]
                            sendMessage:conversationType
                            targetId:targetId
                            content:content
                            pushContent:pushContent
                            pushData:pushData
                            success:^(long messageId) {
                                NSLog(@"发送成功");
                                successBlock(messageId);
                            } error:^(RCErrorCode nErrorCode, long messageId) {
                                NSLog(@"发送失败 errorcode : %ld",(long)nErrorCode);
                                errorBlock(nErrorCode,messageId);
                            }];
    return rcMessage;
}

- (RCConnectionStatus)getRongCloudConnectionStatus {
    return [[RCIMClient sharedRCIMClient] getConnectionStatus];
}

- (void)setCurrentUserInfo:(RCUserInfo *)currentUserInfo {
    
    [[RCIMClient sharedRCIMClient] setCurrentUserInfo:currentUserInfo];
}

- (RCUserInfo *)currentUserInfo {
    return [[RCIMClient sharedRCIMClient] currentUserInfo];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
