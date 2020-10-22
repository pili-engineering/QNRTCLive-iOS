//
//  QNCircleView.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/10/9.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNCircleView.h"

#define QNCircleLineWidth 10.0f
#define QNCircleFont [UIFont boldSystemFontOfSize:20.0f]
#define QNCircleColor [UIColor colorWithRed:0/255.0 green:191/255.0 blue:255/255.0 alpha:1]

@interface QNCircleView ()

@property (nonatomic, weak) UILabel *cLabel;

@end

@implementation QNCircleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = QN_LINE_COLOR;
        self.layer.cornerRadius = 6;
        self.layer.borderColor = QN_LINE_COLOR.CGColor;
        self.layer.borderWidth = 1;
        self.clipsToBounds = YES;
        
        //百分比标签
        UILabel *cLabel = [[UILabel alloc] initWithFrame:self.bounds];
        cLabel.font = QNCircleFont;
        cLabel.textColor = QNCircleColor;
        cLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:cLabel];
        self.cLabel = cLabel;
    }
    
    return self;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    
    _cLabel.text = [NSString stringWithFormat:@"%d%%", (int)floor(progress * 100)];
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    //路径
    UIBezierPath *path = [[UIBezierPath alloc] init];
    //线宽
    path.lineWidth = QNCircleLineWidth;
    //颜色
    [QNCircleColor set];
    //拐角
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    //半径
    CGFloat radius = (MIN(rect.size.width, rect.size.height) - QNCircleLineWidth) * 0.5;
    //画弧（参数：中心、半径、起始角度(3点钟方向为0)、结束角度、是否顺时针）
    [path addArcWithCenter:(CGPoint){rect.size.width * 0.5, rect.size.height * 0.5} radius:radius startAngle:M_PI * 1.5 endAngle:M_PI * 1.5 + M_PI * 2 * _progress clockwise:YES];
    //连线
    [path stroke];
}

@end

