//
//  QNCustomButtonView.h
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/12/10.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNCustomButtonView : UIView
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *titleLabel;

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image title:(NSString *)title;
@end

NS_ASSUME_NONNULL_END
