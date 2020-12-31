//
//  QNVoiceCollectionViewCell.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/12/10.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNVoiceCollectionViewCell.h"

@implementation QNVoiceCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_add_audio"]];
        self.headerImageView.frame = CGRectMake(10, 10, 58, 58);
        self.headerImageView.clipsToBounds = YES;
        self.headerImageView.layer.cornerRadius = 29;
        [self.contentView addSubview:_headerImageView];
        
        self.microphoneButtonView = [[UIButton alloc] initWithFrame:CGRectMake(36, 36, 12, 12)];
        [self.microphoneButtonView setImage:[UIImage imageNamed:@"icon_Voice status"] forState:UIControlStateNormal];
        [self.microphoneButtonView setImage:[UIImage imageNamed:@"icon_Closed wheat state"] forState:UIControlStateSelected];
        [self.headerImageView addSubview:_microphoneButtonView];
        self.microphoneButtonView.hidden = YES;
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 73, 76, 15)];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = QN_FONT_REGULAR(10);
        self.titleLabel.text = @"虚位以待";
        self.titleLabel.lineBreakMode= NSLineBreakByTruncatingMiddle;
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

- (void)configurateCollectionViewCell:(NSString *)name avatar:(NSString *)avatar state:(BOOL)state {
    if ([avatar hasPrefix:@"http"]) {
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:avatar]];

        self.titleLabel.textColor = [UIColor whiteColor];
        self.microphoneButtonView.hidden = NO;
        self.microphoneButtonView.selected = state;
    } else {
        if ([avatar isEqual:@"icon_add_audio"]) {
            self.headerImageView.image = [UIImage imageNamed:avatar];
            self.titleLabel.textColor = QN_COLOR_RGB(131, 131, 131, 1);
            self.microphoneButtonView.hidden = YES;
        } else {
            self.headerImageView.image = [UIImage imageNamed:avatar];
            self.titleLabel.textColor = [UIColor whiteColor];
            self.microphoneButtonView.hidden = NO;
            self.microphoneButtonView.selected = state;
        }
    }
    self.titleLabel.text = name;
}
@end
