//
//  QNCustomButtonView.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/12/10.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNCustomButtonView.h"

@implementation QNCustomButtonView

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image title:(NSString *)title {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 12;
        self.clipsToBounds = YES;
        
        self.button = [[UIButton alloc] initWithFrame:CGRectMake(60, 20, 40, 40)];
        [self.button setImage:image forState:UIControlStateNormal];
        self.button.adjustsImageWhenHighlighted = NO;
        [self addSubview:_button];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 60, 80, 22)];
        self.titleLabel.text = title;
        self.titleLabel.textColor = QN_COLOR_RGB(30, 139, 255, 1);
        self.titleLabel.font = QN_FONT_REGULAR(15);
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.userInteractionEnabled = YES;
        [self addSubview:_titleLabel];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
