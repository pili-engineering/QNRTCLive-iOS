//
//  RCCRGiftNumberLabel.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/29.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "RCCRGiftNumberLabel.h"

@implementation RCCRGiftNumberLabel

- (void)drawTextInRect:(CGRect)rect {
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(c, self.outLineWidth);
    
    CGContextSetLineJoin(c, kCGLineJoinRound);
    
    CGContextSetTextDrawingMode(c, kCGTextStroke);
    
    self.textColor = self.outLinetextColor;
    
    [super drawTextInRect:rect];
    
    self.textColor = self.labelTextColor;
    
    CGContextSetTextDrawingMode(c, kCGTextFill);
    
    [super drawTextInRect:rect];
    
}

@end
