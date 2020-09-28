//
//  QNSetTableViewCell.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/10.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNSetTableViewCell.h"
#define QN_X_SPACE 42
#define QN_Y_SPACE 16

@implementation QNSetTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        CGFloat width = CGRectGetWidth(self.contentView.frame);

        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(QN_X_SPACE, QN_Y_SPACE, 76, 20)];
        self.nameLabel.font = QN_FONT_REGULAR(14);
        self.nameLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_nameLabel];
        
        CGFloat space = (width - QN_X_SPACE - 76 - 112)/3;
                
        self.enableButton = [[UIButton alloc] initWithFrame:CGRectMake(QN_X_SPACE + 76 + space, QN_Y_SPACE - 3, 26, 26)];
        [self.enableButton setImage:[UIImage imageNamed:@"icon_Set switch_nor"] forState:UIControlStateNormal];
        [self.enableButton setImage:[UIImage imageNamed:@"icon_Set switch_sel"] forState:UIControlStateSelected];
        [self.contentView addSubview:_enableButton];
        
        self.enableLabel = [[UILabel alloc] initWithFrame:CGRectMake(QN_X_SPACE + 76 + space + 26, QN_Y_SPACE, 30, 20)];
        self.enableLabel.font = QN_FONT_REGULAR(14);
        self.enableLabel.textColor = [UIColor blackColor];
        self.enableLabel.text = @"开启";
        [self.contentView addSubview:_enableLabel];
        
        self.falseButton = [[UIButton alloc] initWithFrame:CGRectMake(QN_X_SPACE + 76 + space * 2 + 56, QN_Y_SPACE - 3, 26, 26)];
        [self.falseButton setImage:[UIImage imageNamed:@"icon_Set switch_nor"] forState:UIControlStateNormal];
        [self.falseButton setImage:[UIImage imageNamed:@"icon_Set switch_sel"] forState:UIControlStateSelected];
        [self.contentView addSubview:_falseButton];
        
        self.falseLabel = [[UILabel alloc] initWithFrame:CGRectMake(QN_X_SPACE + 76 + space * 2 + 82, QN_Y_SPACE, 30, 20)];
        self.falseLabel.font = QN_FONT_REGULAR(14);
        self.falseLabel.textColor = [UIColor blackColor];
        self.falseLabel.text = @"关闭";
        [self.contentView addSubview:_falseLabel];
        
        self.enableButton.selected = YES;
        self.falseButton.selected = NO;
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
