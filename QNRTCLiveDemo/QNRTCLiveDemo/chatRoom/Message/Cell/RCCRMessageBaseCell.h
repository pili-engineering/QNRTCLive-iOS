//
//  RCCRMessageBaseCell.h
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/10.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCCRMessageModel.h"

@interface RCCRMessageBaseCell : UICollectionViewCell

/**
 消息Cell的数据模型
 */
@property(strong, nonatomic) RCCRMessageModel *model;

/**
 设置当前消息Cell的数据模型
 
 @param model 消息Cell的数据模型
 */
- (void)setDataModel:(RCCRMessageModel *)model;

@end
