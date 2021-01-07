//
//  QNPublicHeader.h
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/7.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#ifndef QNPublicHeader_h
#define QNPublicHeader_h

#ifndef ARRAY_SIZE
    #define ARRAY_SIZE(arr) (sizeof(arr) / sizeof(arr[0]))
#endif

#ifdef DEBUG
    #define NSLog NSLog
#else
    #define NSLog(...);
#endif

// 屏幕宽、高
#define QN_KSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define QN_KSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

// 颜色值
#define QN_COLOR_RGB(a,b,c,d) [UIColor colorWithRed:a/255.0 green:b/255.0 blue:c/255.0 alpha:d]
#define QN_LINE_COLOR QN_COLOR_RGB(198, 198, 198, 1)
#define QN_MAIN_COLOR QN_COLOR_RGB(6.0, 130.0, 255.0, 1)

// 获取系统版本
#define QN_IOS_SYSTEM_STRING [[UIDevice currentDevice] systemVersion]

// 字体 细、中
#define QN_FONT_LIGHT(FontSize) [UIFont fontWithName:@"Avenir-Light" size:FontSize]
#define QN_FONT_MEDIUM(FontSize) [UIFont fontWithName:@"Avenir-Medium" size:FontSize]
#define QN_FONT_REGULAR(FontSize) [UIFont fontWithName:@"PingFangSC-Regular" size:FontSize]

#define QN_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define QN_iPhoneXR ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO)
#define QN_iPhoneXSMAX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)
#define QN_iPhoneP ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
#define QN_iPhone12Min ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1080, 2340), [[UIScreen mainScreen] currentMode].size) : NO)
#define QN_iPhone12Pro ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1170, 2532), [[UIScreen mainScreen] currentMode].size) : NO)
#define QN_iPhone12PMax ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1284, 2778), [[UIScreen mainScreen] currentMode].size) : NO)

#define QN_REQUEST_HOST @"https://qlive-api.qnsdk.com"

// post
#define QN_SEND_CODE(phone) [NSString stringWithFormat:@"%@/v1/send_sms_code?phone_number=%@", QN_REQUEST_HOST, phone]
#define QN_USE_CODE_LOGIN [NSString stringWithFormat:@"%@/v1/login?logintype=smscode", QN_REQUEST_HOST]
#define QN_USER_EXIT [NSString stringWithFormat:@"%@/v1/logout", QN_REQUEST_HOST]

#define QN_ENTER_ROOM [NSString stringWithFormat:@"%@/v1/enter_room", QN_REQUEST_HOST]
#define QN_LEAVE_LIVE_ROOM [NSString stringWithFormat:@"%@/v1/leave_room", QN_REQUEST_HOST]
#define QN_CREATE_ROOM [NSString stringWithFormat:@"%@/v1/rooms", QN_REQUEST_HOST]
#define QN_CLOSE_ROOM [NSString stringWithFormat:@"%@/v1/close_room", QN_REQUEST_HOST]
#define QN_REFRESH_JOIN_ROOM [NSString stringWithFormat:@"%@/v1/refresh_room", QN_REQUEST_HOST]
#define QN_IM_USER_TOKEN [NSString stringWithFormat:@"%@/v1/im_user_token", QN_REQUEST_HOST]

#define QN_FEEDBACK_POST [NSString stringWithFormat:@"%@/v1/feedbacks", QN_REQUEST_HOST]
#define QN_UPLOAD_TOKEN [NSString stringWithFormat:@"%@/v1/upload/token", QN_REQUEST_HOST]

// put
#define QN_UPDATE_PROFILE [NSString stringWithFormat:@"%@/v1/profile", QN_REQUEST_HOST]
#define QN_UPDATE_ROOM_PROFILE(roomId) [NSString stringWithFormat:@"%@/v1/rooms/%@", QN_REQUEST_HOST, roomId]

// get
#define QN_GET_LIVE_ROOMS [NSString stringWithFormat:@"%@/v1/rooms", QN_REQUEST_HOST]
#define QN_GET_PK_ROOMS [NSString stringWithFormat:@"%@/v1/rooms?can_pk=true", QN_REQUEST_HOST]
#define QN_GET_CREATE_ROOM(createId) [NSString stringWithFormat:@"%@/v1/rooms?creator=%@", QN_REQUEST_HOST, createId]
#define QN_LIVE_ROOMID(roomId) [NSString stringWithFormat:@"%@/v1/rooms/%@", QN_REQUEST_HOST, roomId]

#ifdef __OBJC__
// 自定义
#import "QNNetworkRequest.h"
#import "QNRoomUserView.h"
#import "QNSigleAlertView.h"
#import "QNEditAlertView.h"

// 网络状态监听
#import "QNReachability.h"

// QNRTCKit
#import <QNRTCKit/QNRTCKit.h>

// 特效
#import <PLSEffect/PLSEffect.h>

// 三方
#import <Masonry/Masonry.h>
#import <PLPlayerKit/PLPlayerKit.h>
#import <HappyDNS/HappyDNS.h>
#import <MJRefresh/MJRefresh.h>
#import <QiniuSDK.h>
#import <SDWebImage/SDWebImage.h>

#endif

#endif /* QNPublicHeader_h */
