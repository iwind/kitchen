//
//  KViewStyle.m
//  TestTransform
//
//  Created by LiuXiangChao on 9/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KViewStyle.h"
#import "kitchen.h"

@implementation KViewStyle

@synthesize color = _color, 
    width = _width, 
    height = _height, 
    top = _top, 
    right = _right, 
    bottom = _bottom, 
    left = _left, 
    position = _position, 
    opacity = _opacity, 
    padding = _padding, 
    margin = _margin,
    backgroundColor = _backgroundColor,
    font = _font;

- (id) initWithView:(UIView *) view {
    if (self = [super init]) {
        _view = view;
        _position = KStylePositionRelative;
        _padding = KStylePaddingMake(0.0, 0.0, 0.0, 0.0);
        _margin = KStyleMarginMake(0.0, 0.0, 0.0, 0.0);
    }
    return self;
}

- (void) setColor:(UIColor *) color {
    _color = color;
    if ([_view isKindOfClass:[UILabel class]]) {
        [(UILabel *)_view setTextColor:color];
    }
    else if ([_view isKindOfClass:[UIButton class]]) {
        [(UIButton *)_view setTitleColor:color forState:UIControlStateNormal];
    }
}

- (void) setWidth:(float) width {
    _width = width;
    [_view setSize:CGSizeMake(_width, _view.frame.size.height)];
}

- (void) setHeight:(float) height {
    _height = height;
    [_view setSize:CGSizeMake(_view.frame.size.width, _height)];
}

- (void) setTop:(float) top {
    _top = top;
    [_view setPosition:CGPointMake(_view.frame.origin.x, _top)];
}

- (void) setRight:(float) right {
    _right = right;
    if (_position == KStylePositionAbsolute) {
        [_view setPosition:CGPointMake(_view.parent.frame.size.width - _view.frame.size.width - _right, _view.frame.origin.y)];
    }
}

- (void) setBottom:(float) bottom {
    _bottom = bottom;
    [_view setPosition:CGPointMake(_view.frame.origin.x, _view.parent.frame.size.height - _view.frame.size.height - _bottom)];
}

- (void) setLeft:(float) left {
    _left = left;
    if (_position == KStylePositionAbsolute) {
        [_view setPosition:CGPointMake(_left, _view.frame.origin.y)];
    }
}

- (void) setPosition:(KStylePosition) position {
    _position = position;
}

- (void) setOpacity:(float) opacity {
    _opacity = opacity;
    _view.layer.opacity = opacity;
}

- (void) setPadding:(KStylePadding)padding {
    _padding = padding;
}

- (void) setMargin:(KStyleMargin)margin {
    _margin = margin;
}

- (void) setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    _view.backgroundColor = backgroundColor;
}

- (void) setFont:(UIFont *)font {
    _font = font;
    if ([_view isKindOfClass:[UILabel class]]) {
        [(UILabel *)_view setFont:font];
    }
    else if ([_view isKindOfClass:[UIButton class]]) {
        [(UIButton *)_view titleLabel].font = font;
    }
}

- (void) dealloc {
    
}

@end

@implementation UIView(Kitchen_CSS)

static void *KitchenKViewStyleKey;
static void *KitchenKViewStyleParams;

- (KViewStyle *) style {
    id style = objc_getAssociatedObject(self, &KitchenKViewStyleKey);
    if (style == nil) {
        style = [[KViewStyle alloc] initWithView:self];
        objc_setAssociatedObject(self, &KitchenKViewStyleKey, style, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return style;
}

- (NSMutableDictionary *) params {
    id params = objc_getAssociatedObject(self, &KitchenKViewStyleParams);
    if (params == nil) {
        params = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, &KitchenKViewStyleParams, params, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return params;
}

- (void) append:(UIView *) childView {
    float x = 0.0;
    float y = childView.frame.origin.y;
    
    if (self.subviews.count > 0) {
        UIView *lastView = [self.subviews lastObject];
        x += lastView.frame.origin.x + lastView.frame.size.width;
        x += lastView.style.padding.left + lastView.style.padding.right + lastView.style.margin.left + lastView.style.margin.right;
    }
    x += childView.style.padding.left + childView.style.margin.left;
    [childView setPosition:CGPointMake(x, y)];
    
    [self addSubview:childView];
}

- (void) remove {
    UIView *parentView = self.superview;
    [self removeFromSuperview];
    
    //调整余下子元素的尺寸
    float x = 0.0;
    for (UIView *subview in parentView.subviews) {
        if (subview.style.position == KStylePositionRelative) {
            [subview setPosition:CGPointMake(x + subview.style.padding.left + subview.style.margin.left, subview.frame.origin.y)];
            
            x += subview.frame.size.width;
            x += subview.style.padding.left + subview.style.padding.right + subview.style.margin.left + subview.style.margin.right;
        }
    }
}
        
- (UIView *) parent {
    return self.superview;
}

- (NSArray *) children {
    return self.subviews;
}

- (UIView *) childAtIndex:(int) index {
    return [self.subviews objectAtIndex:index];
}

@end