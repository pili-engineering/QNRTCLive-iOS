//
//  QNPKListTableViewCell.h
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/10.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNPKListTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *userLabel;
@property (nonatomic, strong) UILabel *tagLabel;

@property (nonatomic, strong) UIButton *pkButton;

@property (nonatomic, strong) UIButton *microphoneButton;
@property (nonatomic, strong) UIButton *videoButton;

- (void)setUser:(NSString *)user state:(NSInteger)state;
@end

NS_ASSUME_NONNULL_END
