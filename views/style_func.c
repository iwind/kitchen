//
//  style_func.c
//  Track
//
//  Created by LiuXiangChao on 9/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "style_func.h"

KStylePadding KStylePaddingMake(float top, float right, float bottom, float left) {
    KStylePadding padding;
    padding.top = top;
    padding.right = right;
    padding.bottom = bottom;
    padding.left = left;
    
    return padding;
}

KStyleMargin KStyleMarginMake(float top, float right, float bottom, float left) {
    KStyleMargin margin;
    margin.top = top;
    margin.right = right;
    margin.bottom = bottom;
    margin.left = left;
    
    return margin;
}
