//
//  QNAddCollectionViewCell.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/10/12.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNAddCollectionViewCell.h"

@implementation QNAddCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.imageView = [[UIImageView alloc]initWithFrame:self.contentView.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_imageView];
        
        self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(68, 0, 22, 22)];
        [self.deleteButton setImage:[UIImage imageNamed:@"close_icon"] forState:UIControlStateNormal];
        [self.contentView addSubview:_deleteButton];
        
    }
    return self;
}

@end
