//
//  QNRoomTypeSelectView.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/12/9.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNRoomTypeSelectView.h"
#import "QNCustomButtonView.h"

@interface QNRoomTypeSelectView()
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) QNCustomButtonView *liveButtonView;
@property (nonatomic, strong) QNCustomButtonView *audioButtonView;
@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation QNRoomTypeSelectView

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        CGFloat width = CGRectGetWidth(frame);
        CGFloat height = CGRectGetHeight(frame);
        
        self.bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.bgImageView.image = [UIImage imageNamed:@"select_bg.png"];
        self.bgImageView.userInteractionEnabled = YES;
        [self addSubview:_bgImageView];
        
        self.liveButtonView = [[QNCustomButtonView alloc] initWithFrame:CGRectMake((width - 160)/2, (height - 300)/2, 160, 102) image:[UIImage imageNamed:@"icon_video"] title:@"连麦直播"];
        self.liveButtonView.button.tag = 101;
        
        UITapGestureRecognizer *liveViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(liveViewTapAction:)];
        [self.liveButtonView addGestureRecognizer:liveViewTap];
        
        [self.liveButtonView.button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgImageView addSubview:_liveButtonView];
        
        self.audioButtonView = [[QNCustomButtonView alloc] initWithFrame:CGRectMake((width - 160)/2, (height - 300)/2 + 170, 160, 102) image:[UIImage imageNamed:@"icon_voice"] title:@"语音互动"];
        self.audioButtonView.button.tag = 102;
        
        UITapGestureRecognizer *audioViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(audioViewTapAction:)];
        [self.audioButtonView addGestureRecognizer:audioViewTap];

        [self.audioButtonView.button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgImageView addSubview:_audioButtonView];

        self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(width - 60, 40, 30, 30)];
        [self.closeButton setImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(closeViewAction) forControlEvents:UIControlEventTouchUpInside];
        [self.bgImageView addSubview:_closeButton];
    }
    return self;
}

- (void)liveViewTapAction:(UITapGestureRecognizer *)tap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(typeSelectView:didSelectedIndex:)]) {
        [self.delegate typeSelectView:self didSelectedIndex:1];
        [self removeFromSuperview];
    }
}

- (void)audioViewTapAction:(UITapGestureRecognizer *)tap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(typeSelectView:didSelectedIndex:)]) {
        [self.delegate typeSelectView:self didSelectedIndex:2];
        [self removeFromSuperview];
    }
}

- (void)buttonAction:(UIButton *)button {
    NSInteger index = button.tag - 100;
    if (self.delegate && [self.delegate respondsToSelector:@selector(typeSelectView:didSelectedIndex:)]) {
        [self.delegate typeSelectView:self didSelectedIndex:index];
        [self removeFromSuperview];
    }
}

- (void)closeViewAction {
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
