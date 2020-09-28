//
//  RCCRgiftCollectionViewCell.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/17.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "RCCRGiftCollectionViewCell.h"

@interface RCCRGiftCollectionViewCell ()

@property (nonatomic, strong) UILabel *titleLbl;

@property (nonatomic, strong) UIImageView *giftImg;

@property (nonatomic, strong) UILabel *priceLbl;

@property (nonatomic, strong) UILabel *giftNameLbl;

@end

@implementation RCCRGiftCollectionViewCell

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self initializedSubViews];
}

- (void)setDataModel:(RCCRGiftModel *)model {
//    [_titleLbl setText:[NSString stringWithFormat:@"%ld",(long)model.giftPrice]];
    [_giftImg setImage:[UIImage imageNamed:model.giftImageName]];
//    [_giftNameLbl setText:model.giftName];
}

- (void)initializedSubViews {
    [self addSubview:self.giftImg];
    [_giftImg setFrame:CGRectMake(20, 20, self.frame.size.width - 40, self.frame.size.height - 40)];
    
    [self addSubview:self.giftNameLbl];
    [_giftNameLbl setFrame:CGRectMake((self.frame.size.width - 60)/2, self.frame.size.height - 30, 60, 20)];
}

- (UILabel *)titleLbl {
    if (!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        [_titleLbl setTextAlignment:NSTextAlignmentCenter];
        [_titleLbl setFont:[UIFont systemFontOfSize:12.0f]];
        [_titleLbl setNumberOfLines:1];
        [_titleLbl setTextColor:[UIColor blackColor]];
    }
    return  _titleLbl;
}

- (UIImageView *)giftImg {
    if (!_giftImg) {
        _giftImg = [[UIImageView alloc] init];
    }
    return _giftImg;
}

- (UILabel *)giftNameLbl {
    if (!_giftNameLbl) {
        _giftNameLbl = [[UILabel alloc] init];
        [_giftNameLbl setTextAlignment:NSTextAlignmentLeft];
        [_giftNameLbl setFont:[UIFont systemFontOfSize:12.0f]];
        [_giftNameLbl setNumberOfLines:1];
        [_giftNameLbl setTextColor:[UIColor blackColor]];
    }
    return  _giftNameLbl;
}

@end
