//
//  KExtension.m
//  NightClub
//
//  Created by iwind on 6/10/09.
//  Copyright 2009 Bokan Tech. All rights reserved.
//

#import "KExtension.h"
#import "kitchen_util.h"
#import "base64.h"

@implementation UIView(Kitchen)
- (void) setPosition:(CGPoint) point {
	CGRect f = [self frame];
	f.origin = point;
	[self setFrame:f];
}

- (void) setAnchorPoint:(CGPoint) point {
    float x = (self.bounds.size.width - point.x)/self.bounds.size.width;
    float y = (self.bounds.size.height - point.y)/self.bounds.size.height;
    self.layer.anchorPoint = CGPointMake(x, y);
}

- (void) setSize:(CGSize) size {
	CGRect f = [self frame];
	f.size = size;
	[self setFrame:f];
}

- (UIImage *) saveAsImage {
    return [self saveAsImage:self.frame.size];
}

- (UIImage *) saveAsImage:(CGSize) size {
    if(UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
    return image;
}

- (void) removeAllSubviews {
    NSArray *_subviews = self.subviews;
    for (UIView *subview in _subviews) {
        [subview removeFromSuperview];
    }
}

/** 参考 http://stackoverflow.com/questions/11780141/how-to-calculate-3d-transformation-matrix-for-rectangle-to-quadrilateral **/
- (void) transformWithPoint1:(CGPoint) point1 point2:(CGPoint) point2 point3:(CGPoint) point3 point4:(CGPoint) point4 {
    self.layer.transform = CATransform3DIdentity;
    
    CGRect rect = self.bounds;
    double X = rect.origin.x;
    double Y = rect.origin.y;
    double W = rect.size.width;
    double H = rect.size.height;
    
    double x1a = point1.x - self.frame.origin.x;
    double y1a = point1.y - self.frame.origin.y;
    double x2a = point2.x - self.frame.origin.x;
    double y2a = point2.y - self.frame.origin.y;
    double x3a = point3.x - self.frame.origin.x;
    double y3a = point3.y - self.frame.origin.y;
    double x4a = point4.x - self.frame.origin.x;
    double y4a = point4.y - self.frame.origin.y;
    
    double y21 = y2a - y1a;
    double y32 = y3a - y2a;
    double y43 = y4a - y3a;
    double y14 = y1a - y4a;
    double y31 = y3a - y1a;
    double y42 = y4a - y2a;
    
    double a = -H*(x2a*x3a*y14 + x2a*x4a*y31 - x1a*x4a*y32 + x1a*x3a*y42);
    double b = W*(x2a*x3a*y14 + x3a*x4a*y21 + x1a*x4a*y32 + x1a*x2a*y43);
    double c = H*X*(x2a*x3a*y14 + x2a*x4a*y31 - x1a*x4a*y32 + x1a*x3a*y42) - H*W*x1a*(x4a*y32 - x3a*y42 + x2a*y43) - W*Y*(x2a*x3a*y14 + x3a*x4a*y21 + x1a*x4a*y32 + x1a*x2a*y43);
    
    double d = H*(-x4a*y21*y3a + x2a*y1a*y43 - x1a*y2a*y43 - x3a*y1a*y4a + x3a*y2a*y4a);
    double e = W*(x4a*y2a*y31 - x3a*y1a*y42 - x2a*y31*y4a + x1a*y3a*y42);
    double f = -(W*(x4a*(Y*y2a*y31 + H*y1a*y32) - x3a*(H + Y)*y1a*y42 + H*x2a*y1a*y43 + x2a*Y*(y1a - y3a)*y4a + x1a*Y*y3a*(-y2a + y4a)) - H*X*(x4a*y21*y3a - x2a*y1a*y43 + x3a*(y1a - y2a)*y4a + x1a*y2a*(-y3a + y4a)));
    
    double g = H*(x3a*y21 - x4a*y21 + (-x1a + x2a)*y43);
    double h = W*(-x2a*y31 + x4a*y31 + (x1a - x3a)*y42);
    double i = W*Y*(x2a*y31 - x4a*y31 - x1a*y42 + x3a*y42) + H*(X*(-(x3a*y21) + x4a*y21 + x1a*y43 - x2a*y43) + W*(-(x3a*y2a) + x4a*y2a + x2a*y3a - x4a*y3a - x2a*y4a + x3a*y4a));
    
    //Transposed matrix
    CATransform3D transform;
    transform.m11 = a / i;
    transform.m12 = d / i;
    transform.m13 = 0;
    transform.m14 = g / i;
    transform.m21 = b / i;
    transform.m22 = e / i;
    transform.m23 = 0;
    transform.m24 = h / i;
    transform.m31 = 0;
    transform.m32 = 0;
    transform.m33 = 1;
    transform.m34 = 0;
    transform.m41 = c / i;
    transform.m42 = f / i;
    transform.m43 = 0;
    transform.m44 = i / i;
  
    self.layer.transform = transform;
}

@end

@implementation NSArray (Kitchen)

- (NSArray*) shuffledArray {
	NSMutableArray* shuffledArray = [NSMutableArray arrayWithArray: self];
	[shuffledArray shuffle];
	return shuffledArray;
}

- (id) objectForPath:(NSString *) path {
	return o(self, path);
}

@end

@implementation NSMutableArray (Kitchen)

- (void) shuffle {
	int _count = [self count];
	for (NSInteger i = _count - 1; i > 0; --i) {
		NSInteger j = random() % i;
		[self exchangeObjectAtIndex:j withObjectAtIndex:i]; 
	}
}

@end

@implementation NSDictionary (Kitchen)
- (id) objectForPath:(NSString *) path {
	return o(self, path);
}

- (int) intForPath:(NSString *) path {
    NSString *string = [self objectForPath:path];
    return [string intValue];
}

- (NSString *) stringForPath:(NSString *) path {
    id o = [self objectForPath:path];
    if (o == nil) {
        return @"";
    }
    NSString *s = [NSString stringWithFormat:@"%@", o];
    if ([s isEqualToString:@"<null>"]) {
        s = @"";
    }
    return s;
}

@end

@implementation UIViewController (Kitchen)

- (void) redirectTo: (UIViewController *) viewController animated:(BOOL)animated {
    [self.navigationController pushViewController:viewController animated:animated];
}

- (void) redirectTo: (UIViewController *) viewController {
    [self redirectTo:viewController animated:YES];
}

- (void) pop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) onInit {
    
}

- (void) onBefore {
    
}

- (void) onLoad {
    
}

- (void) onUnload {
    
}

#pragma mark Back Button
- (void) setBackButton:(UIBarButtonItem *)backButton {
    NSArray *controllers = self.navigationController.viewControllers;
    if ([controllers count] > 1) {
        UIViewController *rootController = [controllers objectAtIndex:(controllers.count - 2)];
        rootController.navigationItem.backBarButtonItem = backButton;
    }
}

- (void) setBackButtonTitle:(NSString *)buttonTitle {
    [self setBackButton:[[UIBarButtonItem alloc] initWithTitle:buttonTitle style:UIBarButtonItemStyleBordered target:nil action:nil]];
}

- (void) hideStatusBar {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void) showStatusBar {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void) showStatusBar:(UIStatusBarStyle) style {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:style];
}

- (void) hideNavigationBar {
    self.navigationController.navigationBar.hidden = YES;
}

- (void) showNavigationBar {
    self.navigationController.navigationBar.hidden = NO;
}

- (void) showNavigationBar:(UIBarStyle) style {
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barStyle = style;
}

- (void) adjustViewForKeyboard:(UIView *) inputView {
    int keyboardHeight = 240.0;
    CGPoint location = [self.view convertPoint:CGPointMake(0.0, 0.0) fromView:inputView];
    float diff = location.y + inputView.frame.size.height + keyboardHeight - self.view.frame.size.height;
    if (diff > 0) {
        [UIView animateWithDuration:0.2 animations:^{
            [self.view setPosition:CGPointMake(0.0, -diff)];
        }];
    }
}

@end

@implementation NSString (Kitchen)

- (NSString *) trim {
    NSCharacterSet *spaces = [NSCharacterSet characterSetWithCharactersInString:@" \t\r\n"];
    return [self stringByTrimmingCharactersInSet:spaces];
}

- (NSString *) base64Encode {
    const char *chars = [self UTF8String];
    int length = [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    char to[length * 2];
    k_base64_encode(to, (char *)chars, length);
    return [NSString stringWithUTF8String:to];
}

- (NSString *) base64Decode {
    const char *chars = [self UTF8String];
    int length = [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    char to[length];
    k_base64_decode(to, (char *)chars, length);
    return [NSString stringWithUTF8String:to];
}

- (NSString *) md5 {
    return KMd5(self);
}

@end

@implementation UIColor (Kitchen)

+ (UIColor *) kColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

@end

@implementation UIImageView (Kitchen)

- (id) initWithImageNamed:(NSString *) imageName scale:(float) scale {
    UIImage *image = [UIImage imageNamed:imageName];
    if (self = [self initWithFrame:CGRectMake(0.0, 0.0, image.size.width * scale, image.size.height * scale)]) {
        self.image = image;
    }
    return self;
}

@end

@implementation UIButton (Kitchen)

- (id) initWithImageNamed:(NSString *) imageName scale:(float) scale {
    UIImage *image = [UIImage imageNamed:imageName];
    if (self = [self initWithFrame:CGRectMake(0.0, 0.0, floorf(image.size.width * scale), floorf(image.size.height * scale))]) {
        [self setImage:image forState:UIControlStateNormal];
    }
    return self;
}

- (void) setImageNamed:(NSString *) imageName scale:(float) scale {
    UIImage *image = [UIImage imageNamed:imageName];
    CGPoint oldCenter = self.center;
    [self setSize:CGSizeMake(floorf(image.size.width * scale), floorf(image.size.height * scale))];
    [self setImage:image forState:UIControlStateNormal];
    [self setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    [self setCenter:oldCenter];
}

- (void) insetsToSize:(CGSize) size {
    CGSize oldSize = self.imageView.frame.size;
    float x = (int)(size.width - oldSize.width)/2;
    float y = (int)(size.height - oldSize.height)/2;
    CGPoint oldCenter = self.center;
    [self setSize:size];
    [self setImageEdgeInsets:UIEdgeInsetsMake(y, x, y, x)];
    [self setCenter:oldCenter];
}
@end

@implementation NSData (Kitchen)


- (NSString *) base64Encode {
    int length = [self length];
    const char *chars = [self bytes];
    char stringChars[length * 2];
    k_base64_encode(stringChars, (char *)chars, length);
    return [NSString stringWithUTF8String:stringChars];
}

@end

@implementation NSURL (Kitchen)

- (NSString *) param:(NSString *) name {
    NSString *query = [self query];
    if (query == nil || query.length == 0) {
        return @"";
    }
    for (NSString *param in [query componentsSeparatedByString:@"&"]) {
        NSRange range = [param rangeOfString:@"="];
        if (range.location != NSNotFound) {
            NSString *paramName = [param substringToIndex:range.location];
            if ([paramName isEqualToString:name]) {
                return [[param substringFromIndex:range.location + 1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
        }
    }
    return @"";
}

@end