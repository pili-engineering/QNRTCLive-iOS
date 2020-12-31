//
//  QNPKListTableViewCell.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/10.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNPKListTableViewCell.h"

#define QN_X_SPACE 42
#define QN_Y_SPACE 16

@interface QNPKListTableViewCell()
@property (nonatomic, assign) NSInteger state;

@end

@implementation QNPKListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        CGFloat width = CGRectGetWidth(self.contentView.frame);

        self.userLabel = [[UILabel alloc] initWithFrame:CGRectMake(QN_X_SPACE, QN_Y_SPACE, 110, 20)];
        self.userLabel.font = QN_FONT_REGULAR(14);
        self.userLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_userLabel];
        
        self.tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(QN_X_SPACE + 110, QN_Y_SPACE, 36, 20)];
        self.tagLabel.font = QN_FONT_REGULAR(10);
        self.tagLabel.textColor = [UIColor whiteColor];
        self.tagLabel.textAlignment = NSTextAlignmentCenter;
        self.tagLabel.text = @"主播";
        self.tagLabel.backgroundColor = QN_COLOR_RGB(30, 139, 255, 1);
        self.tagLabel.layer.cornerRadius = 4;
        self.tagLabel.clipsToBounds = YES;
        [self.contentView addSubview:_tagLabel];
        
        // pk 列表
        self.pkButton = [[UIButton alloc] initWithFrame:CGRectMake(width - 66, QN_Y_SPACE - 3, 66, 26)];
        [self.pkButton setImage:[UIImage imageNamed:@"icon_PK botton"] forState:UIControlStateNormal];
        [self.contentView addSubview:_pkButton];
        
        // 默认列表状态
        self.state = 0;
    }
    return self;
}

- (void)setUser:(NSString *)user state:(NSInteger)state {
    self.state = state;
    if (state == 0) {
        self.pkButton.hidden = NO;
    } else{
        self.pkButton.hidden = YES;
    }
    self.userLabel.text = user;
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
