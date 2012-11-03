//
//  KViewStyle.h
//  TestTransform
//
//  Created by LiuXiangChao on 9/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "style_func.h"

@interface KViewStyle : NSObject {
@private
    UIView *_view;
}

@property (nonatomic) UIColor *color;
@property (nonatomic) float width;
@property (nonatomic) float height;
@property (nonatomic) float top;
@property (nonatomic) float right;
@property (nonatomic) float bottom;
@property (nonatomic) float left;
@property (nonatomic) KStylePosition position;
@property (nonatomic) float opacity;
@property (nonatomic) KStylePadding padding;
@property (nonatomic) KStyleMargin margin;
@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) UIFont *font;

- (id) initWithView:(UIView *) view;

@end

@interface UIView(Kitchen_CSS) 

- (KViewStyle *) style;
- (NSMutableDictionary *) params;
- (void) append:(UIView *) childView;
- (void) remove;
- (UIView *) parent;
- (NSArray *) children;
- (UIView *) childAtIndex:(int) index;

@end

