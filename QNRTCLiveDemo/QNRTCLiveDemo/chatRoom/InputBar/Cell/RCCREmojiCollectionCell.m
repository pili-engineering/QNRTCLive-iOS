//
//  RCCREmojiCollectionCell.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/16.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "RCCREmojiCollectionCell.h"

@interface RCCREmojiCollectionCell ()

@property (nonatomic, strong) UILabel *emojiLabel;

@property (nonatomic, strong) UIImageView *deleteImg;

@end

@implementation RCCREmojiCollectionCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.emojiLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [self.contentView addSubview:self.emojiLabel];
        [self.emojiLabel setTextAlignment:NSTextAlignmentCenter];
        [self.emojiLabel setFont:[UIFont systemFontOfSize:25]];
        self.deleteImg = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 20, 20)];
        [self.deleteImg setImage:[UIImage imageNamed:@"deleteImg"]];
        [self.deleteImg setUserInteractionEnabled:YES];
        [self.contentView addSubview:self.deleteImg];
    }
    return self;
}

- (void)setData:(NSString *)emojiStr showDeleteImg:(BOOL)show {
    if (!show) {
        if (emojiStr == nil) {
            [self.emojiLabel setText:@""];
        } else {
            [self.emojiLabel setText:emojiStr];
        }
        [self.deleteImg setHidden:YES];
        [self.emojiLabel setHidden:NO];
    } else {
        [self.deleteImg setHidden:NO];
        [self.emojiLabel setHidden:YES];
    }
}

@end
