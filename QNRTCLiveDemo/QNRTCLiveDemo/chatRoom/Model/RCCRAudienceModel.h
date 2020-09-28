//
//  RCCRAudienceModel.h
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/11.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCCRAudienceModel : NSObject

/**
 userid
 */
@property(nonatomic , copy)NSString *userId;
@property (nonatomic, copy) NSString *audienceName;

@property (nonatomic, copy) NSString *audiencePortrait;

/**
 是否已经邀请过
 */
@property(nonatomic , assign)BOOL invited;



@end
