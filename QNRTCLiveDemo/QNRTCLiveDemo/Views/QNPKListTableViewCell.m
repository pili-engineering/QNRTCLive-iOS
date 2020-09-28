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
        
        self.tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(QN_X_SPACE + 120, QN_Y_SPACE, 36, 20)];
        self.tagLabel.font = QN_FONT_REGULAR(10);
        self.tagLabel.textColor = [UIColor whiteColor];
        self.tagLabel.textAlignment = NSTextAlignmentCenter;
        self.tagLabel.text = @"主播";
        self.tagLabel.backgroundColor = QN_COLOR_RGB(30, 139, 255, 1);
        self.tagLabel.layer.cornerRadius = 4;
        self.tagLabel.clipsToBounds = YES;
        [self.contentView addSubview:_tagLabel];
        
        // pk 列表
        self.pkButton = [[UIButton alloc] initWithFrame:CGRectMake(width - 20 - 66, QN_Y_SPACE - 3, 66, 26)];
        [self.pkButton setImage:[UIImage imageNamed:@"icon_PK botton"] forState:UIControlStateNormal];
        [self.contentView addSubview:_pkButton];
        
        
        // 连麦状态
//        self.microphoneButton = [[UIButton alloc] initWithFrame:CGRectMake(width - 100, QN_Y_SPACE - 8, 36, 36)];
//        [self.microphoneButton setImage:[UIImage imageNamed:@"icon_voice"] forState:UIControlStateNormal];
//        [self.microphoneButton setImage:[UIImage imageNamed:@"icon_voice_nor"] forState:UIControlStateSelected];
//        [self.contentView addSubview:_microphoneButton];
//
//        self.videoButton = [[UIButton alloc] initWithFrame:CGRectMake(width - 36 - 20, QN_Y_SPACE - 8, 36, 36)];
//        [self.videoButton setImage:[UIImage imageNamed:@"icon_video"] forState:UIControlStateNormal];
//        [self.videoButton setImage:[UIImage imageNamed:@"icon_video_nor"] forState:UIControlStateSelected];
//        [self.contentView addSubview:_videoButton];
//
        // 默认列表状态
        self.state = 0;
        self.microphoneButton.hidden = YES;
        self.videoButton.hidden = YES;
    }
    return self;
}

- (void)setUser:(NSString *)user state:(NSInteger)state {
    self.state = state;
    if (state == 0) {
        self.pkButton.hidden = NO;
//        self.microphoneButton.hidden = YES;
//        self.videoButton.hidden = YES;
    } else{
        self.pkButton.hidden = YES;
//        self.microphoneButton.hidden = NO;
//        self.videoButton.hidden = NO;
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
