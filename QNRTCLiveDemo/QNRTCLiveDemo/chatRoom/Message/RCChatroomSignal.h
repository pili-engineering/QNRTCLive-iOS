//
//  RCChatroomSignal.h
//  QNRTCLiveDemo
//
//  Created by 何云旗 on 2020/9/25.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCChatroomSignal : RCMessageContent

@property(nonatomic, copy) NSString *signal;

@property(nonatomic, copy) NSString *id;

@property(nonatomic, copy) NSString *extra;

@end

NS_ASSUME_NONNULL_END
