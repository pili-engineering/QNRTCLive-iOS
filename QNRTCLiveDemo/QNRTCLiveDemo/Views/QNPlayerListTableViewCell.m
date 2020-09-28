//
//  QNPlayerListTableViewCell.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/11.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNPlayerListTableViewCell.h"

#define QN_X_SPACE 15
#define QN_Y_SPACE 16

@implementation QNPlayerListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.coverImageView = [[UIImageView alloc] init];
        self.coverImageView.backgroundColor = QN_COLOR_RGB(30, 139, 255, 1);
        self.coverImageView.layer.cornerRadius = 6;
        self.coverImageView.clipsToBounds = YES;
        [self.contentView addSubview:_coverImageView];
        [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView.mas_left).mas_offset(15);
            make.right.mas_equalTo(self.contentView.mas_right).mas_offset(-15);
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
            make.height.mas_equalTo(190);
        }];
        self.coverImageView.image = [UIImage imageNamed:@"img_default_live_cover.png"];
        self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;

        self.tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(QN_X_SPACE, QN_Y_SPACE, 90, 20)];
        self.tagLabel.font = QN_FONT_REGULAR(14);
        self.tagLabel.textColor = [UIColor whiteColor];
        self.tagLabel.textAlignment = NSTextAlignmentCenter;
        self.tagLabel.text = @"单主播直播";
        self.tagLabel.backgroundColor = QN_COLOR_RGB(0, 0, 0, 0.7);
        self.tagLabel.layer.cornerRadius = 6;
        self.tagLabel.clipsToBounds = YES;
        [self.coverImageView addSubview:_tagLabel];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.coverImageView.frame) - 40, CGRectGetWidth(self.coverImageView.frame), 40)];
        bgView.backgroundColor = QN_COLOR_RGB(52, 52, 52, 0.5);
        [self.coverImageView addSubview:bgView];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.coverImageView.mas_left);
            make.right.mas_equalTo(self.coverImageView.mas_right);
            make.bottom.mas_equalTo(self.coverImageView.mas_bottom);
            make.height.mas_equalTo(40);
        }];

        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(QN_X_SPACE, 10, CGRectGetWidth(self.contentView.frame)/2, 20)];
        self.nameLabel.font = QN_FONT_REGULAR(14);
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.text = @"七小牛的直播";
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        [bgView addSubview:_nameLabel];
        
        self.countLabel = [[UILabel alloc] init];
        self.countLabel.font = QN_FONT_REGULAR(14);
        self.countLabel.textColor = [UIColor whiteColor];
        self.countLabel.text = @"观看人数：0";
        self.countLabel.textAlignment = NSTextAlignmentRight;
        [bgView addSubview:_countLabel];
        [_countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(bgView.mas_right).offset(-QN_X_SPACE);
            make.bottom.mas_equalTo(bgView.mas_bottom).offset(-10);
            make.size.mas_equalTo(CGSizeMake(90, 20));
        }];
    }
    return self;
}

- (void)setParameterWithDic:(NSDictionary *)dic {
    self.nameLabel.text = dic[@"name"];
    NSNumber *number = dic[@"audienceNumber"];
    self.countLabel.text = [NSString stringWithFormat:@"观看人数：%@", number];
    if ([dic[@"status"] isEqualToString:@"pk"]) {
        self.tagLabel.text = @"连麦 PK";
    } else{
        self.tagLabel.text = @"单主播直播";
    }
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
