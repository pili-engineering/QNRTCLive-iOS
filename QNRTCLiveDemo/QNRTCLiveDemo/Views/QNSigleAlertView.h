//
//  QNSigleAlertView.h
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/15.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QNSigleAlertView : NSObject
- (void)showAlertViewTitle:(NSString *)title bgView:(UIView *)bgView;

- (void)addAlertContent:(NSString *)content bgView:(UIView *)bgView;
- (void)removeAlertContentView;
@end
