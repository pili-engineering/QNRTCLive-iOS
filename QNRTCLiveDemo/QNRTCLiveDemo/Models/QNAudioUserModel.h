//
//  QNAudioUserModel.h
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/12/11.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNAudioUserModel : NSObject

@property (nonatomic, strong) NSNumber *position;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *roomid;
@property (nonatomic, copy) NSString *reqUserID;
@property (nonatomic, strong) NSNumber *audioMute;

+ (QNAudioUserModel *)configureAudioUserModelWithDic:(NSDictionary *)dic;
+ (NSMutableArray *)configureAudioUserModelWithArray:(NSArray *)array;
@end

NS_ASSUME_NONNULL_END
