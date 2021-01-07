//
//  RCCRTextMessageCell.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/22.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "RCCRTextMessageCell.h"
#import <RongIMLib/RongIMLib.h>
#import "RCChatroomWelcome.h"
#import "RCChatroomUserQuit.h"
#import "RCChatroomLike.h"
#import "RCChatroomStart.h"
#import "RCChatroomEnd.h"
#import "RCChatroomNotification.h"
#import "RCCRRongCloudIMManager.h"
#import "RCChatroomSignal.h"

#define RCCRText_HEXCOLOR(rgbValue)                                                                                             \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0                                               \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0                                                  \
blue:((float)(rgbValue & 0xFF)) / 255.0                                                           \
alpha:1.0]

@interface RCCRTextMessageCell ()

@end

@implementation RCCRTextMessageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initializedSubViews];
    }
    return self;
}

- (void)initializedSubViews {
    [self addSubview:self.textLabel];
    [_textLabel setFrame:CGRectMake(10, 0, self.bounds.size.width - 10, self.bounds.size.height)];
}

- (void)setDataModel:(RCCRMessageModel *)model {
    [super setDataModel:model];
    [self updateUI:model];
}

- (void)updateUI:(RCCRMessageModel *)model {
    if ([model.content isMemberOfClass:[RCChatroomWelcome class]]) {
        RCUserInfo *userInfo = model.userInfo;
        NSString *userName = [userInfo.name stringByAppendingString:@""];
        NSString *localizedMessage = @"进入直播间";
        NSString *str =[NSString stringWithFormat:@"%@%@",userName,localizedMessage];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
        
        [attributedString addAttribute:NSForegroundColorAttributeName value:(RCCRText_HEXCOLOR(0x3ce1ff)) range:[str rangeOfString:userName]];
        [attributedString addAttribute:NSForegroundColorAttributeName value:(RCCRText_HEXCOLOR(0xffffff)) range:[str rangeOfString:localizedMessage]];
        [self.textLabel setAttributedText:attributedString.copy];
        return;
    } else if ([model.content isMemberOfClass:[RCChatroomUserQuit class]]) {
        RCUserInfo *userInfo = model.userInfo;
        NSString *userName = [userInfo.name stringByAppendingString:@""];
        NSString *localizedMessage = @"退出直播间";
        NSString *str =[NSString stringWithFormat:@"%@%@",userName,localizedMessage];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
        
        [attributedString addAttribute:NSForegroundColorAttributeName value:(RCCRText_HEXCOLOR(0x3ce1ff)) range:[str rangeOfString:userName]];
        [attributedString addAttribute:NSForegroundColorAttributeName value:(RCCRText_HEXCOLOR(0xffffff)) range:[str rangeOfString:localizedMessage]];
        [self.textLabel setAttributedText:attributedString.copy];
        return;
    } else if ([model.content isMemberOfClass:[RCChatroomLike class]]) {
        RCChatroomLike *likeMessage = (RCChatroomLike *)model.content;
        RCUserInfo *userInfo = model.userInfo;
        NSString *userName = [userInfo.name stringByAppendingString:@" "];
        NSString *localizedMessage = [NSString stringWithFormat:@"给主播点了%d个赞",likeMessage.counts];
        NSString *str =[NSString stringWithFormat:@"%@%@",userName,localizedMessage];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
        
        [attributedString addAttribute:NSForegroundColorAttributeName value:(RCCRText_HEXCOLOR(0x3ce1ff)) range:[str rangeOfString:userName]];
        [attributedString addAttribute:NSForegroundColorAttributeName value:(RCCRText_HEXCOLOR(0xffb83c)) range:[str rangeOfString:localizedMessage]];
        [self.textLabel setAttributedText:attributedString.copy];
        return;
    } else if ([model.content isMemberOfClass:[RCTextMessage class]]) {
        RCTextMessage *textMessage = (RCTextMessage *)self.model.content;
        if (self.model.senderUserId) {
            NSString *localizedMessage = textMessage.content;
            RCUserInfo *userInfo = model.userInfo;
            NSString *userName = [userInfo.name stringByAppendingString:@"："];
            NSString *str =[NSString stringWithFormat:@"%@%@",userName,localizedMessage];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
            
            [attributedString addAttribute:NSForegroundColorAttributeName value:(RCCRText_HEXCOLOR(0x3ce1ff)) range:[str rangeOfString:userName]];
            [attributedString addAttribute:NSForegroundColorAttributeName value:(RCCRText_HEXCOLOR(0xffb83c)) range:[str rangeOfString:localizedMessage]];
            [self.textLabel setAttributedText:attributedString.copy];
        
        }
    } else if ([model.content isMemberOfClass:[RCChatroomStart class]]) {
        RCChatroomStart *startMessage = (RCChatroomStart *)self.model.content;
        NSString *notice = @"系统通知";
        NSString *time = [self timeWithTimeInterval:startMessage.time];
        NSString *content = @"开始视频直播";
        NSString *str = [NSString stringWithFormat:@"%@ %@ %@",notice,time,content];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
        [attributedString addAttribute:NSForegroundColorAttributeName value:(RCCRText_HEXCOLOR(0x3ce1ff)) range:[str rangeOfString:time]];
        [attributedString addAttribute:NSForegroundColorAttributeName value:(RCCRText_HEXCOLOR(0xffffff)) range:[str rangeOfString:notice]];
        [attributedString addAttribute:NSForegroundColorAttributeName value:(RCCRText_HEXCOLOR(0xffffff)) range:[str rangeOfString:content]];
        [self.textLabel setAttributedText:attributedString.copy];
        return;
    } else if ([model.content isMemberOfClass:[RCChatroomEnd class]]) {
        RCChatroomEnd *endMessage = (RCChatroomEnd *)self.model.content;
        NSString *notice = @"系统通知";
        NSString *duration = [NSString stringWithFormat:@"%d 分钟",endMessage.duration];
        NSString *content = @"本次直播已结束，直播时长 ";
        NSString *str = [NSString stringWithFormat:@"%@ %@ %@",notice, content, duration];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
        [attributedString addAttribute:NSForegroundColorAttributeName value:(RCCRText_HEXCOLOR(0x3ce1ff)) range:[str rangeOfString:duration]];
        [attributedString addAttribute:NSForegroundColorAttributeName value:(RCCRText_HEXCOLOR(0xffffff)) range:[str rangeOfString:notice]];
        [attributedString addAttribute:NSForegroundColorAttributeName value:(RCCRText_HEXCOLOR(0xffffff)) range:[str rangeOfString:content]];
        [self.textLabel setAttributedText:attributedString.copy];
        return;
    }else if ([model.content isMemberOfClass:[RCChatroomNotification class]]) {
        RCChatroomNotification *notificationMessage = (RCChatroomNotification *)self.model.content;
        NSString *str  = notificationMessage.content;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
        
        [attributedString addAttribute:NSForegroundColorAttributeName value:(RCCRText_HEXCOLOR(0xff0000)) range:[str rangeOfString:str]];
        [self.textLabel setAttributedText:attributedString.copy];
        return;
    }
}

+ (CGSize)getMessageCellSize:(NSString *)content withWidth:(CGFloat)width{
    CGSize textSize = CGSizeZero;
    textSize.height = textSize.height + 17;
    return textSize;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        [_textLabel setTextAlignment: NSTextAlignmentLeft];
        [_textLabel setTintColor:[UIColor whiteColor]];
        [_textLabel setNumberOfLines:0];
        [_textLabel setFont:[UIFont systemFontOfSize:15]];
    }
    return _textLabel;
}

- (NSString *)timeWithTimeInterval:(long)timeInterval
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
    
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeInterval/ 1000.0];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}

@end
