//
//  Tweener.h
//  Magikid Chinese
//
//  Created by AngellEcho on 14-3-3.
//
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#define easeIn (id)[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]
#define easeOut (id)[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]
#define easeInOut (id)[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]
#define easeDefault (id)[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]

#define KEY_ANIMATE_POSITION @"position"
#define KEY_ANIMATE_SCALE @"transform.scale"
#define KEY_ANIMATE_TRANSFORM @"transform"
#define KEY_ANIMATE_ROTATION_Z @"transform.rotation.z"
#define KEY_AXLE_X @"x"
#define KEY_AXLE_Y @"y"
#define KEY_AXLE_Z @"z"
#define POINT_TO_VALUE(n) [NSValue valueWithCGPoint:n]
#define VALUE_POINT(x,y) [NSValue valueWithCGPoint:CGPointMake(x, y)]
#define VALUE_SCALE(n) [NSValue valueWithCATransform3D:CATransform3DMakeScale(n, n, 1.0f)]

#define ZERO 0.00001f
#define VALUE_NORMAL_SCALE 1.15f

#define MAKETE(v,d,e) LTMakeTweenerWithEase(v, d, e)
#define MAKET(v,d) LTMakeTweener(v, d)

#pragma value and number
#define intToNum(n) [NSNumber numberWithInteger:n]
NSString *intToStr(int i);
#define floatToNum(n) [NSNumber numberWithFloat:n]

#define KEY_TRANSLATION [Tweener translation]
#define KEY_TRANSLATION_X [Tweener translationX]
#define KEY_TRANSLATION_Y [Tweener translationY]
#define KEY_SCALE [Tweener scale]
#define KEY_SCALEX [Tweener scaleX]
#define KEY_SCALEY [Tweener scaleY]
#define KEY_ROTATIONX [Tweener rotationX]
#define KEY_ROTATIONY [Tweener rotationY]
#define KEY_ROTATIONZ [Tweener rotationZ]
#define KEY_OPACITY [Tweener opacity]
#define KEY_POSITION [Tweener position]
#define KEY_POSITIONX [Tweener positionX]
#define KEY_POSITIONY [Tweener positionY]

#ifdef DEBUG
#    define CLog(...)  [AlertBox show:SFM(__VA_ARGS__)]
#    define DLog(...) NSLog(__VA_ARGS__)
#	 define ELog(s,...) NSLog((@"[%s] " s),__func__,## __VA_ARGS__);
#else
#    define CLog(...)  /* */
#    define DLog(...) /* */
#	 define ELog(...) /* */
#endif

/* Category */
@interface CALayer (Tweener)
- (void)setParm:(id)parm forKeyPath:(NSString *)keyPath;
@end

/* EasyType */
enum LTTweenerEaseType
{
    TweenerEaseLine = 0,
    TweenerEaseIn = 1,
    TweenerEaseOut = 2,
    TweenerEaseInOut = 3
};
typedef enum LTTweenerEaseType TweenerEaseType;

/* Block */
@class LTTweener;
typedef void (^TweenerResponse) (LTTweener *tweener, BOOL result);

/* Parms */
@interface Parms : NSObject
@property (nonatomic, strong) id value;
@property (nonatomic, assign) TweenerEaseType easeType;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) CGPathRef path;
@end

Parms *LTMakeTweenerWithEase(id value, NSTimeInterval duration, TweenerEaseType easeType);
Parms *LTMakeTweener(id value, NSTimeInterval duration);
Parms *LTMakePathTweener(CGPathRef path, NSTimeInterval duration, TweenerEaseType easeType);

/* Tweener */
@interface LTTweener : NSObject
@property (nonatomic, readonly) CALayer *target;
@property (nonatomic, readonly) CAAnimation *animation;
@property (nonatomic, weak) id userInfo;
@property (nonatomic) id fromValue;
@property (nonatomic) BOOL isRepeate;
- (void)stop;
+ (void)stopAll;
+ (void)stopByLayer:(CALayer *)layer;
+ (LTTweener *)tweenerWithKeyPath:(NSString *)keyPath andTarget:(CALayer *)target andParms:(NSArray *)array andFromValue:(id)fromValue;
+ (LTTweener *)tweenerWithKeyPath:(NSString *)keyPath andTarget:(CALayer *)target andParms:(NSArray *)array;
+ (LTTweener *)tweenerWithKeyPath:(NSString *)keyPath andTarget:(CALayer *)target andPathParms:(Parms *)parms;
- (void)start;
- (void)start:(TweenerResponse)response;

/* genaral */
+ (LTTweener *)tweenerZoomInWithTarget:(CALayer *)target;
+ (LTTweener *)tweenerZoomOutWithTarget:(CALayer *)target;
+ (LTTweener *)tweenerCardInWithTarget:(CALayer *)target;
+ (LTTweener *)tweenerCardOutWithTarget:(CALayer *)target;
+ (LTTweener *)tweenerSideInWithTarget:(CALayer *)target;
+ (LTTweener *)tweenerSideOutWithTarget:(CALayer *)target;
+ (LTTweener *)tweenerMoveInWithAlex:(NSString *)alex andDistance:(float)distance andTarget:(CALayer *)target;
+ (LTTweener *)tweenerMoveOutWithAlex:(NSString *)alex andDistance:(float)distance andTarget:(CALayer *)target;

/* key */
+ (NSString *)translation;
+ (NSString *)translationX;
+ (NSString *)translationY;
+ (NSString *)scale;
+ (NSString *)scaleX;
+ (NSString *)scaleY;
+ (NSString *)rotationX;
+ (NSString *)rotationY;
+ (NSString *)rotationZ;
+ (NSString *)opacity;
+ (NSString *)position;
+ (NSString *)positionX;
+ (NSString *)positionY;
@end
