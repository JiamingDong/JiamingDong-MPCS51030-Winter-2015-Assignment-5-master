//
//  linePrinter.h
//  Assignment5
//
//  Created by dongjiaming on 15/2/5.
//  Copyright (c) 2015年 The University of Chicago, Department of Computer Science. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface linePrinter : UIView

@property CGFloat startX;
@property CGFloat startY;
@property CGFloat endX;
@property CGFloat endY;
- (id)initWithFrameCustomed:(CGRect)frame :(CGFloat)startX : (CGFloat)startY : (CGFloat)endX : (CGFloat)endY;
@end
