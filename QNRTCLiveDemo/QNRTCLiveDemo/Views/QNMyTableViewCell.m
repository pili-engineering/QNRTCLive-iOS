//
//  QNMyTableViewCell.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/15.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNMyTableViewCell.h"

@implementation QNMyTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        CGFloat width = CGRectGetWidth(self.contentView.frame);

        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 18, 70, 22)];
        self.nameLabel.font = QN_FONT_REGULAR(16);
        self.nameLabel.textColor = QN_COLOR_RGB(30, 41, 42, 1);
        [self.contentView addSubview:_nameLabel];
        
        self.enterButton = [[UIButton alloc] init];
        [self.enterButton setImage:[UIImage imageNamed:@"chevron-left"] forState:UIControlStateNormal];
        [self.contentView addSubview:_enterButton];
        
        [_enterButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).offset(18);
            make.right.mas_equalTo(self.contentView.mas_right).offset(-18);
            make.size.mas_equalTo(CGSizeMake(22, 22));
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = QN_COLOR_RGB(151, 151, 151, 1);
        [self.contentView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-0.5);
            make.left.mas_equalTo(self.contentView.mas_left);
            make.right.mas_equalTo(self.contentView.mas_right);
            make.height.mas_equalTo(0.5);
        }];
        
        self.phoneLabel = [[UILabel alloc] init];
        self.phoneLabel.font = QN_FONT_REGULAR(16);
        self.phoneLabel.textColor = QN_COLOR_RGB(30, 41, 42, 1);
        self.phoneLabel.text = @"400-808-9176";
        [self.contentView addSubview:_phoneLabel];
        [_phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).offset(18);
            make.right.mas_equalTo(self.enterButton.mas_right).offset(-38);
            make.height.mas_equalTo(22);
        }];
        self.phoneLabel.hidden = YES;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
