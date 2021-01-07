//
//  QNSigleAlertView.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/15.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNSigleAlertView.h"

@interface QNSigleAlertView()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *bgView;

@end

@implementation QNSigleAlertView

- (void)showAlertViewTitle:(NSString *)title bgView:(UIView *)bgView {
    CGRect bounds = [title boundingRectWithSize:CGSizeMake(1000, 28) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:QN_FONT_REGULAR(14.f) forKey:NSFontAttributeName] context:nil];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width + 30, 26)];
    self.titleLabel.center = bgView.center;
    self.titleLabel.backgroundColor = QN_COLOR_RGB(0, 0, 0, 0.8);
    self.titleLabel.layer.cornerRadius = 5;
    self.titleLabel.clipsToBounds = YES;
    self.titleLabel.font = QN_FONT_REGULAR(14.f);
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.text = title;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:_titleLabel];
    
    [self shakeUpShow:_titleLabel];
    [self openTimeByRuntime];
}

# pragma mark - 添加动画

- (void)shakeUpShow:(UIView *)shakeView {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    NSMutableArray *mutableArray = [NSMutableArray array];
    NSValue *value1 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)];
    NSValue *value2 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)];
    NSValue *value3 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)];
    NSValue *value4 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
    [mutableArray addObject:value1];
    [mutableArray addObject:value2];
    [mutableArray addObject:value3];
    [mutableArray addObject:value4];
    animation.duration = 1.5;
    animation.values = [mutableArray copy];
    [shakeView.layer addAnimation:animation forKey:nil];
}

# pragma mark - 开启计时器

- (void)openTimeByRuntime {
    self.timer = [NSTimer timerWithTimeInterval:1.2 target:self selector:@selector(dismissViewAction) userInfo:nil repeats:NO];
    if (self.timer != nil) {
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
}

- (void)dismissViewAction {
    if (_timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:1.4];
    [UIView setAnimationDelegate:self];
    self.titleLabel.hidden = YES;
    [self.titleLabel removeFromSuperview];
    [UIView commitAnimations];
}


- (void)addAlertContent:(NSString *)content bgView:(UIView *)bgView {
    self.bgView = [[UIView alloc] initWithFrame:bgView.bounds];
    self.bgView.backgroundColor = QN_COLOR_RGB(0, 0, 0, 0.6);
    [bgView addSubview:_bgView];

    CGRect bounds = [content boundingRectWithSize:CGSizeMake(1000, 28) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:QN_FONT_REGULAR(14.f) forKey:NSFontAttributeName] context:nil];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width + 50, 56)];
    self.titleLabel.center = self.bgView.center;
    self.titleLabel.backgroundColor = QN_COLOR_RGB(0, 0, 0, 0.8);
    self.titleLabel.layer.cornerRadius = 8;
    self.titleLabel.clipsToBounds = YES;
    self.titleLabel.font = QN_FONT_REGULAR(14.f);
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.text = content;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.bgView addSubview:_titleLabel];
}

- (void)removeAlertContentView {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:1.4];
    [UIView setAnimationDelegate:self];
    self.titleLabel.hidden = YES;
    [self.titleLabel removeFromSuperview];
    self.bgView.hidden = YES;
    [self.bgView removeFromSuperview];
    [UIView commitAnimations];
}


@end
