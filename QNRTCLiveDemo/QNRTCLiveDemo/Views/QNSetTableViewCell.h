//
//  QNSetTableViewCell.h
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/10.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNSetTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *enableButton;
@property (nonatomic, strong) UILabel *enableLabel;
@property (nonatomic, strong) UIButton *falseButton;
@property (nonatomic, strong) UILabel *falseLabel;

@end

NS_ASSUME_NONNULL_END
