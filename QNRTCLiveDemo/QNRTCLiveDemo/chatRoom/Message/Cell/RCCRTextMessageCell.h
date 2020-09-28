//
//  RCCRTextMessageCell.h
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/22.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "RCCRMessageBaseCell.h"

#define TextMessageFontSize 16

@interface RCCRTextMessageCell : RCCRMessageBaseCell

/*!
 显示消息内容的Label
 */
@property(nonatomic, strong) UILabel *textLabel;

+ (CGSize)getMessageCellSize:(NSString *)content withWidth:(CGFloat)width;

@end
