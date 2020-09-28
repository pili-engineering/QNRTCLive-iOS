//
//  RCCRSendgiftView.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/11.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "RCCRGiftListView.h"
#import "RCCRgiftCollectionViewCell.h"

static NSString * const giftCollectionViewCellIdentify = @"giftCollectionViewCellIdentify";

@interface RCCRGiftListView ()<UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *separatorLine;

@property (nonatomic, strong) UICollectionView *giftCollectionView;

@property (nonatomic, strong) UIPageControl *pageControl;

//@property (nonatomic, strong) UIView *bottomContentView;

@property (nonatomic, strong) UIView *bottomSeparatorLine;

@property (nonatomic, strong) UIButton *giftNumSelectBtn;

@property (nonatomic, strong) UIPickerView *giftNumPicker;

@property (nonatomic, strong) UILabel *giftNumberLbl;

@property (nonatomic, strong) UIButton *sendGiftBtn;

@property (nonatomic, copy) NSArray<RCCRGiftModel *> *giftArray;

@property (nonatomic, assign) NSUInteger rows;

@property (nonatomic, assign) NSUInteger columns;

@property (nonatomic, assign) NSInteger selectIndex;

@end

@implementation RCCRGiftListView

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self initializedSubViews];
    self.rows = 2;
    self.columns = 4;
    self.selectIndex = -1;
}

- (void)setModelArray:(NSArray<RCCRGiftModel *> *)modelArray {
    self.giftArray = [modelArray copy];
    [_giftCollectionView reloadData];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 8;
}

//  页数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCCRGiftCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:giftCollectionViewCellIdentify forIndexPath:indexPath];
    if (!cell) {
        cell = [[RCCRGiftCollectionViewCell alloc] init];
    }
    NSInteger row = indexPath.row % self.rows;
    NSInteger col = floor(indexPath.row/self.rows);
    NSInteger newIndex = ((int)indexPath.section * self.rows * self.columns) + col + row * self.columns;
    
    RCCRGiftModel *model = [[RCCRGiftModel alloc] init];
    if (newIndex < self.giftArray.count) {
        model = self.giftArray[newIndex];
    } else {
        model.giftName = @"";
        model.giftPrice = 1000;
        model.giftImageName = @"";
    }
    if (newIndex == self.selectIndex) {
        cell.backgroundColor = [UIColor grayColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    [cell setDataModel:model];
    return cell;
}

//  点击礼物
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSInteger row = indexPath.row % self.rows;
    NSInteger col = floor(indexPath.row/self.rows);
    NSInteger newIndex = ((int)indexPath.section * self.rows * self.columns) + col + row * self.columns;
    if (newIndex < self.giftArray.count) {
        self.selectIndex = newIndex;
        [self.giftCollectionView reloadData];
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

#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return 20;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component {

    return [NSString stringWithFormat:@"%ld",(long)row];
}

// 当用户选中UIPickerViewDataSource中指定列和列表项时激发该方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:
(NSInteger)row inComponent:(NSInteger)component {
    [_giftNumberLbl setText:[NSString stringWithFormat:@"%ld",(long)row]];
}

- (void)giftNumSelect:(UIButton *)sender {
    if (self.giftNumPicker.hidden) {
        [_giftNumPicker setHidden:NO];
        [_giftNumPicker setFrame:CGRectMake(self.frame.size.width-220, 40, 60, 160)];
    }
}

- (void)sendGiftBtnClick:(UIButton *)sender {
    //  未选择礼物时
    if (self.selectIndex == -1) {
        return;
    }
    if (!self.giftNumPicker.hidden) {
        [self.giftNumPicker setHidden:YES];
        return;
    }
    RCCRGiftModel *model = [[RCCRGiftModel alloc] init];
    if ([self.delegate respondsToSelector:@selector(sendGift:)]) {
        model = self.giftArray[self.selectIndex];
        model.giftNumber = [self.giftNumberLbl.text integerValue];
        [self.delegate sendGift:model];
    }
}

- (void)initializedSubViews {
    
    [self setBackgroundColor:[UIColor whiteColor]];
    CGFloat width = self.bounds.size.width;
    [self addSubview:self.titleLabel];
    [_titleLabel setFrame:CGRectMake(10, 10, 100, 20)];
    
    [self addSubview:self.separatorLine];
    [_separatorLine setFrame:CGRectMake(0, 39, width, 1)];
    
    [self addSubview:self.giftCollectionView];
    [_giftCollectionView setFrame:CGRectMake(0, 40, width, 160)];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(width/4, 80);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    [_giftCollectionView setCollectionViewLayout:layout animated:NO completion:nil];
    
    [self addSubview:self.bottomSeparatorLine];
    [_bottomSeparatorLine setFrame:CGRectMake(0, 199, width, 1)];
    
    [self addSubview:self.giftNumSelectBtn];
    [_giftNumSelectBtn setFrame:CGRectMake(width-260, 200, 140, 40)];
    [self.giftNumPicker removeFromSuperview];
    self.giftNumPicker = nil;
    [self addSubview:self.giftNumPicker];
    
    [self addSubview:self.giftNumberLbl];
    [_giftNumberLbl setText:@"9"];
    [_giftNumberLbl setFrame:CGRectMake(width-110, 200, 40, 40)];
    
    [self addSubview:self.sendGiftBtn];
    [_sendGiftBtn setFrame:CGRectMake(width-60, 5, 40, 30)];
    [self addSubview:self.pageControl];
    [_pageControl setFrame:CGRectMake((width - 100)/2, 5, 100, 10)];
    [_pageControl setCurrentPageIndicatorTintColor:[UIColor blackColor]];
    [_pageControl setPageIndicatorTintColor:[UIColor grayColor]];
   
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
        [_titleLabel setNumberOfLines:1];
        [_titleLabel setTextColor:[UIColor blackColor]];
        [_titleLabel setText:@"礼物"];
    }
    return  _titleLabel;
}

- (UIView *)separatorLine {
    if (!_separatorLine) {
        _separatorLine = [[UIView alloc] init];
        [_separatorLine setBackgroundColor:[UIColor blackColor]];
    }
    return _separatorLine;
}

- (UICollectionView *)giftCollectionView {
    if (!_giftCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _giftCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_giftCollectionView setPagingEnabled:YES];
        [_giftCollectionView setShowsVerticalScrollIndicator:NO];
        [_giftCollectionView setShowsHorizontalScrollIndicator:NO];
        [_giftCollectionView setDelegate:self];
        [_giftCollectionView setDataSource:self];
        [_giftCollectionView registerClass:[RCCRGiftCollectionViewCell class] forCellWithReuseIdentifier:giftCollectionViewCellIdentify];
        [_giftCollectionView setBackgroundColor:[UIColor whiteColor]];
    }
    return _giftCollectionView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
    }
    return  _pageControl;
}

- (UIView *)bottomSeparatorLine {
    if (!_bottomSeparatorLine) {
        _bottomSeparatorLine = [[UIView alloc] init];
        [_bottomSeparatorLine setBackgroundColor:[UIColor blackColor]];
    }
    return _bottomSeparatorLine;
}

- (UIButton *)giftNumSelectBtn {
    if (!_giftNumSelectBtn) {
        _giftNumSelectBtn = [[UIButton alloc] init];
        [_giftNumSelectBtn addTarget:self
                         action:@selector(giftNumSelect:)
               forControlEvents:UIControlEventTouchUpInside];
        [_giftNumSelectBtn setTitle:@"礼物数选择" forState:UIControlStateNormal];
        [_giftNumSelectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _giftNumSelectBtn;
}

- (UIPickerView *)giftNumPicker {
    if (!_giftNumPicker) {
        _giftNumPicker = [[UIPickerView alloc] init];
        [_giftNumPicker setHidden:YES];
        [_giftNumPicker setDelegate:self];
        [_giftNumPicker setDataSource:self];
    }
    return _giftNumPicker;
}

- (UILabel *)giftNumberLbl {
    if (!_giftNumberLbl) {
        _giftNumberLbl = [[UILabel alloc] init];
        [_giftNumberLbl setTextAlignment:NSTextAlignmentCenter];
        [_giftNumberLbl setFont:[UIFont systemFontOfSize:18.0f]];
        [_giftNumberLbl setNumberOfLines:1];
        [_giftNumberLbl setTextColor:[UIColor blackColor]];
        [_giftNumberLbl setText:@"9"];
    }
    return  _giftNumberLbl;
}

- (UIButton *)sendGiftBtn {
    if (!_sendGiftBtn) {
        _sendGiftBtn = [[UIButton alloc] init];
        [_sendGiftBtn addTarget:self
                     action:@selector(sendGiftBtnClick:)
           forControlEvents:UIControlEventTouchUpInside];
        [_sendGiftBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_sendGiftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _sendGiftBtn;
}
- (void)change:(id)sender {
    
}
@end
