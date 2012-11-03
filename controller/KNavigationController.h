//
//  KNavigationController.h
//  testnavigation2
//
//  Created by LiuXiangChao on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KNavigationController : UINavigationController {

}

+ (void) setupInWindow:(UIWindow *) window;
+ (KNavigationController *) defaultController;

@end
