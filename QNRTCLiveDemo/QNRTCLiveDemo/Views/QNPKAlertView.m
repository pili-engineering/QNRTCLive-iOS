//
//  QNPKAlertView.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/10.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNPKAlertView.h"

@interface QNPKAlertView()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *refuseButton;
@property (nonatomic, strong) UIButton *acceptButton;

@property (nonatomic, strong) UILabel *contentLabel;


@end

@implementation QNPKAlertView

- (instancetype)initWithFrame:(CGRect)frame request:(BOOL)request content:(NSString *)content{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 6;
        self.clipsToBounds = YES;
        
        CGFloat width = CGRectGetWidth(frame);
        CGFloat height = CGRectGetHeight(frame);
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 41)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = QN_FONT_REGULAR(16.0);
        _titleLabel.textColor = QN_COLOR_RGB(30, 139, 255, 1);
        _titleLabel.text = @"连麦互动";
        [self addSubview:_titleLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 42, width, 0.8)];
        lineView.backgroundColor = QN_COLOR_RGB(151, 151, 151, 1);
        [self addSubview:lineView];
        
        if (request) {
            _refuseButton = [[UIButton alloc] initWithFrame:CGRectMake(30, height - 26 - 38, 86, 32)];
            _refuseButton.titleLabel.font = QN_FONT_REGULAR(16);
            [_refuseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_refuseButton setTitle:@"拒绝 TA" forState:UIControlStateNormal];
            _refuseButton.backgroundColor = QN_COLOR_RGB(30, 139, 255, 1);
            _refuseButton.layer.cornerRadius = 16;
            _refuseButton.clipsToBounds = YES;
            [self addSubview:_refuseButton];
            
            _acceptButton = [[UIButton alloc] initWithFrame:CGRectMake(width - 80 - 30, height - 26 - 38, 86, 32)];
            _acceptButton.titleLabel.font = QN_FONT_REGULAR(16);
            [_acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_acceptButton setTitle:@"开始 PK" forState:UIControlStateNormal];
            _acceptButton.backgroundColor = QN_COLOR_RGB(30, 139, 255, 1);
            _acceptButton.layer.cornerRadius = 16;
            _acceptButton.clipsToBounds = YES;
            [self addSubview:_acceptButton];
            
            _refuseButton.tag = 100;
            [_refuseButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            _acceptButton = [[UIButton alloc] initWithFrame:CGRectMake(width/2 - 88, height - 26 - 32, 176, 32)];
            _acceptButton.titleLabel.font = QN_FONT_REGULAR(16);
            [_acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_acceptButton setTitle:@"好吧 主播好残忍" forState:UIControlStateNormal];
            _acceptButton.backgroundColor = QN_COLOR_RGB(30, 139, 255, 1);
            _acceptButton.layer.cornerRadius = 16;
            _acceptButton.clipsToBounds = YES;
            [_acceptButton addTarget:self action:@selector(hideAlertView) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_acceptButton];
        }
        
        _acceptButton.tag = 101;
        [_acceptButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];

        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 66, width - 60, height - 78 - 46)];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.font = QN_FONT_REGULAR(16.0);
        _contentLabel.textColor = [UIColor blackColor];
        _contentLabel.text = content;
        [self addSubview:_contentLabel];
    }
    return self;
}

- (void)hideAlertView {
    [self removeFromSuperview];
}

- (void)buttonAction:(UIButton *)button {
    NSInteger index = button.tag - 100;
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:didSelectedTitleIndex:)]) {
        [self.delegate alertView:self didSelectedTitleIndex:index];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
