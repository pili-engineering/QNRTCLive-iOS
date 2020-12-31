//
//  QNAudioRoomViewController.h
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/12/9.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNAudioRoomViewController : UIViewController
@property (nonatomic, assign) BOOL isAdmin; // 是否是主播端
@property (nonatomic, strong) NSDictionary *resultDic; // 观众进入，携带的信息

@end

NS_ASSUME_NONNULL_END
