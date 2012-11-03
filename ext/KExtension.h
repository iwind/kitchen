//
//  KExtension.h
//  NightClub
//
//  Created by iwind on 6/10/09.
//  Copyright 2009 Bokan Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef enum {
	KSwipeDirectionUp = 0,
	KSwipeDirectionRight = 1,
	KSwipeDirectionDown = 2,
	KSwipeDirectionLeft = 3
} KSwipeDirection;


@interface UIView(Kitchen)

/** set position of the view **/
- (void) setPosition:(CGPoint) point;
- (void) setAnchorPoint:(CGPoint) point;

/** set size of the view **/
- (void) setSize:(CGSize) size;

- (UIImage *) saveAsImage;
- (UIImage *) saveAsImage:(CGSize) size;

- (void) removeAllSubviews;

- (void) transformWithPoint1:(CGPoint) point1 point2:(CGPoint) point2 point3:(CGPoint) point3 point4:(CGPoint) point4;

@end

@interface NSArray (Kitchen)
/** return a new shuffled array **/
- (NSArray*) shuffledArray;

/** get an object by a dotted path (example:a.b.c) **/
- (id) objectForPath:(NSString *) path;
@end

@interface NSMutableArray (Kitchen)
/** shuffle current array **/
- (void) shuffle;
@end

@interface NSDictionary (Kitchen)
/** get an object by a dotted path (example:a.b.c) **/
- (id) objectForPath:(NSString *) path;
- (int) intForPath:(NSString *) path;
- (NSString *) stringForPath:(NSString *) path;
@end

@interface UIViewController(Kitchen)

- (void) redirectTo: (UIViewController *) viewController animated:(BOOL)animated;
- (void) redirectTo: (UIViewController *) viewController;
- (void) pop;

- (void) onInit;
- (void) onBefore;
- (void) onLoad;
- (void) onUnload;

/** set back button **/
- (void) setBackButton:(UIBarButtonItem *)backButton;
- (void) setBackButtonTitle:(NSString *)buttonTitle;

- (void) hideStatusBar;
- (void) showStatusBar;
- (void) showStatusBar:(UIStatusBarStyle) style;

- (void) hideNavigationBar;
- (void) showNavigationBar;

@end


@interface NSString (Kitchen)

- (NSString *) trim;
- (NSString *) base64Encode;
- (NSString *) base64Decode;
- (NSString *) md5;

@end

@interface UIColor (Kitchen)

+ (UIColor *) kColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

@end

@interface UIImageView (Kitchen)

- (id) initWithImageNamed:(NSString *) imageName scale:(float) scale;

@end

@interface UIButton (Kitchen)

- (id) initWithImageNamed:(NSString *) imageName scale:(float) scale;
- (void) setImageNamed:(NSString *) imageName scale:(float) scale;
- (void) insetsToSize:(CGSize) size;

@end

@interface NSData (Kitchen)

- (NSString *) base64Encode;

@end