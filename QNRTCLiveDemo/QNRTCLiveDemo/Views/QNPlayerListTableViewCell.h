//
//  QNPlayerListTableViewCell.h
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/11.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNPlayerListTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UILabel *tagLabel;

- (void)setParameterWithDic:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
