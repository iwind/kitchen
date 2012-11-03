//
//  style_func.h
//  Track
//
//  Created by LiuXiangChao on 9/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef KITCHEN_STYLE_FUNC_H
#define KITCHEN_STYLE_FUNC_H

typedef enum {
    KStylePositionAbsolute,
    KStylePositionRelative
} KStylePosition;

typedef struct {
    float top;
    float right;
    float bottom;
    float left;
} KStylePadding;

typedef struct {
    float top;
    float right;
    float bottom;
    float left;
} KStyleMargin;

typedef enum {
    KStyleOverflowAuto,
    KStyleOverflowVisible,
    KStyleOverflowHidden
} KStyleOverflow;

KStylePadding KStylePaddingMake(float top, float right, float bottom, float left);
KStyleMargin KStyleMarginMake(float top, float right, float bottom, float left);


#endif
