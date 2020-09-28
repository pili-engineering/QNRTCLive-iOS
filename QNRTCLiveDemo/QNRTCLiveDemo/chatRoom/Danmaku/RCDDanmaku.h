//
//  RCDDanmaku.h
//  DanMuDemo
//
//  Created by Sin on 16/9/26.
//  Copyright © 2016年 Sin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>

typedef enum : NSInteger {
    RCDDanmakuPositionNone = 0,//从右往左
    RCDDanmakuPositionCenterTop,//中间靠上
    RCDDanmakuPositionCenterBottom//中间靠下
} RCDDanmakuPosition;//弹幕动画位置

@interface RCDDanmaku : NSObject

/**
 *  弹幕内容
 */
@property(nonatomic, copy) NSAttributedString* contentStr;

/**
 *  弹幕类型(弹幕所在位置)
 */
@property(nonatomic, assign) RCDDanmakuPosition position;

/**
 如果需要展示用户头像，你可以给次model赋值，默认展示用户头像
 */
@property(nonatomic, strong) RCUserInfo *model;

@end
