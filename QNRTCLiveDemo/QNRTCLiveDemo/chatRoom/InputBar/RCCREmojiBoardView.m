//
//  RCCREmojiBoardView.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/11.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "RCCREmojiBoardView.h"
#import "RCCREmojiCollectionCell.h"

static NSString * const emojiCollectionViewCellIdentify = @"emojiCollectionViewCellIdentify";

@interface RCCREmojiBoardView ()<UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

/**
 表情容器的View
 */
@property(nonatomic, strong) UICollectionView *emojiContentView;

/**
 emoji表情数组
 */
@property(nonatomic, strong) NSMutableArray *emojiArray;

//@property(nonatomic, assign) CGFloat totalPage;

@property(nonatomic, strong) UIPageControl *pageControl;

@property(nonatomic, strong) UIView *bottomContentView;

@property(nonatomic, strong) UIButton *emojiBtn;

@property(nonatomic, strong) UIButton *sendBtn;

@property(nonatomic, assign) NSUInteger rows;

@property(nonatomic, assign) NSUInteger columns;

//表情页数
@property(nonatomic, assign) NSUInteger pages;

//@property(nonatomic, strong) NSMutableArray *tabIconArray;//tabIconArray 中包含的表情tab 按钮 比 emojiModelList 多1个，emojiModeList 中不包含emoji字符串表情

/*!
 自定义表情的 Model 数组
 */
//@property(nonatomic, copy) NSMutableArray *emojiModelList;

@end

@implementation RCCREmojiBoardView

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
        NSString *bundlePath = [resourcePath stringByAppendingPathComponent:@"Emoji.plist"];
        self.emojiArray = [[NSMutableArray alloc]initWithContentsOfFile:bundlePath];
        self.rows = 3;
        self.columns = 8;
        self.pages = self.emojiArray.count/23 + ((self.emojiArray.count%23 == 0) ? 0 : 1);
        for (int i = 1; i < self.pages; i++) {
            [self.emojiArray insertObject:@"" atIndex:(i*24 - 1)];
        }
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self initializedSubViews];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
//  每页24个表情
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return 24;
//    if (((_emojiArray.count/23)+(_emojiArray.count%23 == 0 ? 0:1)) != section+1) {
//    }else{
//        //  取最后一页的表情数
//        NSUInteger lastPageEmoji = _emojiArray.count - 23*((_emojiArray.count/23)+(_emojiArray.count%23 == 0 ?0:1) - 1);
//        if (lastPageEmoji % 8 == 0) {
//            if (lastPageEmoji == 8) {
//                return 16;
//            } else {
//                return 24;
//            }
//        } else {
//            return lastPageEmoji/8 + 8;
//        }
//    }
}

//  页数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.pages ? self.pages : (_emojiArray.count/23) + (_emojiArray.count%23 == 0 ? 0:1);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCCREmojiCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:emojiCollectionViewCellIdentify forIndexPath:indexPath];
    if (!cell) {
        cell = [[RCCREmojiCollectionCell alloc] init];
    }
    if (indexPath.row == 23) {
        //  展示删除图案
        [cell setData:nil showDeleteImg:YES];
    } else {
        //  横向排版
        NSInteger row = indexPath.row % self.rows;
        NSInteger col = floor(indexPath.row/self.rows);
        //Calculate the new index in the `NSArray`
        NSInteger newIndex = ((int)indexPath.section * self.rows * self.columns) + col + row * self.columns;
        if (newIndex < _emojiArray.count) {
            [cell setData:_emojiArray[newIndex] showDeleteImg:NO];
        }
        else {
            [cell setData:nil showDeleteImg:NO];
        }
    }
    return cell;
}

//  点击表情
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.delegate respondsToSelector:@selector(didTouchEmojiView:touchedEmoji:)]) {
        
        if (indexPath.row == 23) {
            [self.delegate didTouchEmojiView:self touchedEmoji:nil];
        } else {
            NSInteger row = indexPath.row % self.rows;
            NSInteger col = floor(indexPath.row/self.rows);
            NSInteger newIndex = ((int)indexPath.section * self.rows * self.columns) + col + row * self.columns;
            [self.delegate didTouchEmojiView:self touchedEmoji:_emojiArray[newIndex]];
        }
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}

//  停止滚动的时候
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat contenOffset = scrollView.contentOffset.x;
    int page = contenOffset/scrollView.frame.size.width + ((int)contenOffset %(int)scrollView.frame.size.width==0?0:1);
    _pageControl.currentPage = page;
}

#pragma mark - action

- (void)sendBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didSendButtonEvent)]) {
        [self.delegate didSendButtonEvent];
    }
}

- (void)emojiBtnClick:(UIButton *)sender {
    NSLog(@"点击了emoji表情选择按钮");
}

#pragma mark - UI
- (void)initializedSubViews {
    [self setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:self.emojiContentView];
    [_emojiContentView setFrame:CGRectMake(0, 0, self.bounds.size.width, 170)];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(32, 32);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    //计算每个分区的左右边距
    float distanceX = (self.bounds.size.width - 8*32)/9;
    float distanceY = (170 - 3*32)/4;
    //设置分区的内容偏移
    layout.sectionInset = UIEdgeInsetsMake(distanceY, distanceX, distanceY, distanceX);
    //设置行列间距
    layout.minimumLineSpacing = distanceX;
    layout.minimumInteritemSpacing = distanceY;

    [_emojiContentView setCollectionViewLayout:layout animated:NO completion:nil];
    
    [self addSubview:self.pageControl];
    [_pageControl setCurrentPageIndicatorTintColor:[UIColor blackColor]];
    [_pageControl setPageIndicatorTintColor:[UIColor grayColor]];
    [_pageControl setFrame:CGRectMake(0, 170, self.bounds.size.width, 10)];
    [_pageControl setNumberOfPages:(self.pages ? self.pages : (_emojiArray.count/23) + (_emojiArray.count%23 == 0 ? 0:1))];
     
    [self addSubview:self.bottomContentView];
    [_bottomContentView setFrame:CGRectMake(0, 180, self.bounds.size.width, 40)];
    
//    [_bottomContentView addSubview:self.emojiBtn];
//    [_emojiBtn setFrame:CGRectMake(10, 0, 40, 40)];
    
    [_bottomContentView addSubview:self.sendBtn];
    [_sendBtn setFrame:CGRectMake(self.bounds.size.width - 50, 0, 50, 40)];
}

- (UICollectionView *)emojiContentView {
    if (!_emojiContentView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _emojiContentView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_emojiContentView setPagingEnabled:YES];
        [_emojiContentView setShowsVerticalScrollIndicator:NO];
        [_emojiContentView setShowsHorizontalScrollIndicator:NO];
        [_emojiContentView setDelegate:self];
        [_emojiContentView setDataSource:self];
        [_emojiContentView registerClass:[RCCREmojiCollectionCell class] forCellWithReuseIdentifier:emojiCollectionViewCellIdentify];
        [_emojiContentView setBackgroundColor:[UIColor whiteColor]];
    }
    return _emojiContentView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
    }
    return  _pageControl;
}
- (UIView *)bottomContentView {
    if (!_bottomContentView) {
        _bottomContentView = [[UIView alloc] init];
        [_bottomContentView setBackgroundColor:[UIColor clearColor]];
    }
    return _bottomContentView;
}

- (UIButton *)emojiBtn {
    if (!_emojiBtn) {
        _emojiBtn = [[UIButton alloc] init];
        [_emojiBtn addTarget:self
                     action:@selector(emojiBtnClick:)
           forControlEvents:UIControlEventTouchUpInside];
        [_emojiBtn setTitle:@"😃" forState:UIControlStateNormal];
    }
    return _emojiBtn;
}

- (UIButton *)sendBtn {
    if (!_sendBtn) {
        _sendBtn = [[UIButton alloc] init];
        [_sendBtn addTarget:self
                      action:@selector(sendBtnClick:)
            forControlEvents:UIControlEventTouchUpInside];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_sendBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    return _sendBtn;
}
@end
