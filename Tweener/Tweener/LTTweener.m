//
//  Tweener.m
//  Magikid Chinese
//
//  Created by AngellEcho on 14-3-3.
//
//


#import "LTTweener.h"


@implementation  CALayer (Tweener)
- (void)setParm:(id)parm forKeyPath:(NSString *)keyPath
{
    [self setValue:parm forKey:keyPath];
    if ([self presentationLayer] != nil) {
        CALayer *presentationLayer = self.presentationLayer;
        [presentationLayer setValue:parm forKey:keyPath];
    }
}
@end

NSMutableArray *tweenerList = nil;
#pragma mark - Parms class
@implementation Parms
@synthesize easeType = _easeType;
@synthesize duration = _duration;
@synthesize value = _value;
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@! duration = %f value = %@",[super description],self.duration,self.value];
}
@end

Parms *LTMakeTweenerWithEase(id value, NSTimeInterval duration, TweenerEaseType easeType)
{
    Parms *parms = [[Parms alloc] init];
    parms.value = value;
    parms.duration = duration;
    parms.easeType = easeType;
    return parms;
}

Parms *LTMakeTweener(id value, NSTimeInterval duration)
{
    Parms *parms = [[Parms alloc] init];
    parms.value = value;
    parms.duration = duration;
    parms.easeType = TweenerEaseLine;
    return parms;
}

Parms *LTMakePathTweener(CGPathRef path, NSTimeInterval duration, TweenerEaseType easeType)
{
    Parms *parms = [[Parms alloc] init];
    parms.path = path;
    parms.duration = duration;
    parms.easeType = TweenerEaseLine;
    return parms;
}

#pragma mark - Tweener class
@implementation LTTweener
{
    NSString *keyPath;
    __weak CALayer *target;
    __strong CAAnimation *animation;
    TweenerResponse response;
}
@synthesize target;
@synthesize animation;
@synthesize userInfo = _userInfo;
@synthesize fromValue = _fromValue;

#pragma mark - Tweener init
+ (LTTweener *)tweenerWithKeyPath:(NSString *)keyPath andTarget:(CALayer *)target andParms:(NSArray *)array andFromValue:(id)fromValue
{
    if (target == nil) {
        NSLog(@"Warning:target can't be nil");
        return nil;
    }
    /* Create Animation */
    CAAnimation *animation = nil;
    if (array.count <= 0) {
        return nil;
    } else if (array.count == 1)
    {
        Parms *parms = array[0];
        CABasicAnimation *baseAnimation = [CABasicAnimation animationWithKeyPath:keyPath];
        baseAnimation.duration = parms.duration;
        baseAnimation.fromValue = fromValue;
        baseAnimation.toValue = parms.value;
        baseAnimation.timingFunction = [self timingWithEasyType:parms.easeType];
        animation = baseAnimation;
    } else
    {
        CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
        NSMutableArray *timeArray = [NSMutableArray arrayWithObject:[NSNumber numberWithFloat:0]];
        NSMutableArray *valueArray = [NSMutableArray arrayWithObject:fromValue];
        NSMutableArray *timingArray = [NSMutableArray array];
        NSTimeInterval duration = 0;
        for (Parms *parms in array) {
            [valueArray addObject:parms.value];
            [timingArray addObject:[self timingWithEasyType:parms.easeType]];
            duration += parms.duration;
        }
        float currentRate = 0;
        for (Parms *parms in array) {
            currentRate += parms.duration / duration;
            [timeArray addObject:[NSNumber numberWithFloat:currentRate]];
        }
        keyFrameAnimation.values = valueArray;
        keyFrameAnimation.keyTimes = timeArray;
        keyFrameAnimation.timingFunctions = timingArray;
        keyFrameAnimation.duration = duration;
        animation = keyFrameAnimation;
    }
    /* Tweener Init */
    LTTweener *tweener = [[LTTweener alloc] initWithAnimation:animation
                                                andTarget:target
                                               andKeyPath:keyPath];
    tweenerList = tweenerList ?: [NSMutableArray array];
    [tweenerList addObject:tweener];
    return tweener;
}

+ (LTTweener *)tweenerWithKeyPath:(NSString *)keyPath andTarget:(CALayer *)target andParms:(NSArray *)array
{
    return [LTTweener tweenerWithKeyPath:keyPath andTarget:target andParms:array andFromValue:[([target presentationLayer] ?: target) valueForKeyPath:keyPath]];
}

+ (LTTweener *)tweenerWithKeyPath:(NSString *)keyPath andTarget:(CALayer *)target andPathParms:(Parms *)parms
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    animation.path = parms.path;
    animation.duration = parms.duration;
    animation.timingFunction = [self timingWithEasyType:parms.easeType];
    /* Tweener Init */
    LTTweener *tweener = [[LTTweener alloc] initWithAnimation:animation
                                                andTarget:target
                                               andKeyPath:keyPath];
    tweenerList = tweenerList ?: [NSMutableArray array];
    [tweenerList addObject:tweener];
    return tweener;
}

- (void)setFromValue:(id)fromValue
{
    if ([animation isKindOfClass:[CABasicAnimation class]]) {
        [(CABasicAnimation *)animation setFromValue:fromValue];
    } else if ([animation isKindOfClass:[CAKeyframeAnimation class]])
    {
        NSMutableArray *array = (id)[(CAKeyframeAnimation *)animation values];
        if ([array isKindOfClass:[NSArray class]] && ![array isKindOfClass:[NSMutableArray class]]) {
            array = [NSMutableArray arrayWithArray:array];
        }
        array[0] = fromValue;
        [(CAKeyframeAnimation *)animation setValues:array];
    }
}

- (id)fromValue
{
    if ([animation isKindOfClass:[CABasicAnimation class]]) {
        return [(CABasicAnimation *)animation fromValue];
    } else if ([animation isKindOfClass:[CAKeyframeAnimation class]])
    {
        return [[(CAKeyframeAnimation *)animation values] objectAtIndex:0];
    }
    return nil;
}

- (void)setIsRepeate:(BOOL)isRepeate
{
    animation.repeatCount = isRepeate ? 99999999999 : 0;
}

- (BOOL)isRepeate
{
    return (animation.repeatCount > 0);
}

+ (CAMediaTimingFunction *)timingWithEasyType:(TweenerEaseType)easeType
{
    switch (easeType) {
        case TweenerEaseLine:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        case TweenerEaseIn:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        case TweenerEaseInOut:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        case TweenerEaseOut:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    }
    return nil;
}

- (id)initWithAnimation:(CAAnimation *)aAnimation andTarget:(CALayer *)aTarget andKeyPath:(NSString *)aKeyPath
{
    if (self = [super init]) {
        animation = aAnimation;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        target = aTarget;
        animation.delegate = self;
        keyPath = aKeyPath;
    }
    return self;
}

#pragma mark - Start
- (void)start
{
    [self start:nil];
}

- (void)start:(TweenerResponse)aResponse
{
    if (aResponse != nil) {
        response = [aResponse copy];
    }
    NSString *animationKey = [NSString stringWithFormat:@"tweener_%@",keyPath];
    CAAnimation *tempAnimation = [target animationForKey:animationKey];
    if (tempAnimation != nil) {
        [target removeAnimationForKey:animationKey];
    }
    [target addAnimation:animation forKey:animationKey];
}

#pragma mark - Stop
- (void)stop
{
    response = nil;
    animation.delegate = nil;
    animation = nil;
    NSString *animationKey = [NSString stringWithFormat:@"tweener_%@",keyPath];
    CALayer *currentLayer = target.presentationLayer;
    [target setValue:[currentLayer valueForKeyPath:keyPath] forKeyPath:keyPath];
    [target removeAnimationForKey:animationKey];
}


+ (void)stopAll
{
    if (tweenerList.count > 0) {
        NSArray *tempArray = [NSArray arrayWithArray:tweenerList];
        for (LTTweener *one in tempArray) {
            [one stop];
        }
        tempArray = nil;
    }
}


+ (void)stopByLayer:(CALayer *)layer
{
    if (tweenerList.count > 0) {
        NSArray *tempArray = [NSArray arrayWithArray:tweenerList];
        for (LTTweener *one in tempArray) {
            if (one.target == layer)
                [one stop];
        }
        tempArray = nil;
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (animation != nil) {
        CALayer *currentLayer = target.presentationLayer;
        [target setValue:[currentLayer valueForKeyPath:keyPath] forKeyPath:keyPath];
        animation.delegate = nil;
        animation = nil;
    }
    
    if (response != nil)
        response(self,flag);
    
    if (flag) {
        [target removeAnimationForKey:[NSString stringWithFormat:@"tweener_%@",keyPath]];
    }
    [tweenerList removeObject:self];
}

#pragma mark - general
+ (LTTweener *)tweenerZoomInWithTarget:(CALayer *)target;
{
    LTTweener *t = [self tweenerWithKeyPath:@"transform.scale"
                                andTarget:target
                                 andParms:@[MAKETE(floatToNum(VALUE_NORMAL_SCALE), 0.25, TweenerEaseIn), MAKETE(floatToNum(1.0f), 0.25, TweenerEaseOut)]];
    t.fromValue = floatToNum(ZERO);
    return t;
}

+ (LTTweener *)tweenerZoomOutWithTarget:(CALayer *)target;
{
    LTTweener *t = [self tweenerWithKeyPath:@"transform.scale"
                                andTarget:target
                                 andParms:@[MAKETE(floatToNum(VALUE_NORMAL_SCALE), 0.25, TweenerEaseOut), MAKETE(floatToNum(ZERO), 0.25, TweenerEaseIn)]];
    t.fromValue = floatToNum(1);
    return t;
}

+ (LTTweener *)tweenerCardInWithTarget:(CALayer *)target
{
    LTTweener *t = [LTTweener tweenerWithKeyPath:@"transform.scale.y"
                                   andTarget:target
                                    andParms:@[MAKETE(floatToNum(VALUE_NORMAL_SCALE), 0.25f, TweenerEaseIn),
                                               MAKETE(floatToNum(1.0f), 0.25f, TweenerEaseOut)]];
    t.fromValue = floatToNum(ZERO);
    return t;
}

+ (LTTweener *)tweenerCardOutWithTarget:(CALayer *)target
{
    LTTweener *t = [LTTweener tweenerWithKeyPath:@"transform.scale.y"
                                   andTarget:target
                                    andParms:@[MAKETE(floatToNum(VALUE_NORMAL_SCALE), 0.25f, TweenerEaseOut),
                                               MAKETE(floatToNum(ZERO), 0.25f, TweenerEaseIn)]];
    t.fromValue = floatToNum(1.0f);
    return t;
}

+ (LTTweener *)tweenerSideInWithTarget:(CALayer *)target
{
    LTTweener *t = [LTTweener tweenerWithKeyPath:@"transform.scale.x"
                                   andTarget:target
                                    andParms:@[MAKETE(floatToNum(VALUE_NORMAL_SCALE), 0.25f, TweenerEaseIn),
                                               MAKETE(floatToNum(1.0f), 0.25f, TweenerEaseOut)]];
    t.fromValue = floatToNum(ZERO);
    return t;
}

+ (LTTweener *)tweenerSideOutWithTarget:(CALayer *)target
{
    LTTweener *t = [LTTweener tweenerWithKeyPath:@"transform.scale.x"
                                   andTarget:target
                                    andParms:@[MAKETE(floatToNum(VALUE_NORMAL_SCALE), 0.25f, TweenerEaseOut),
                                               MAKETE(floatToNum(ZERO), 0.25f, TweenerEaseIn)]];
    t.fromValue = floatToNum(1.0f);
    return t;
}


+ (LTTweener *)tweenerMoveInWithAlex:(NSString *)alex andDistance:(float)distance andTarget:(CALayer *)target
{
    LTTweener *t = [LTTweener tweenerWithKeyPath:[@"transform.translation." stringByAppendingString:alex]
                                   andTarget:target
                                    andParms:@[MAKETE(floatToNum(distance * (1 -VALUE_NORMAL_SCALE)), 0.25f, TweenerEaseIn),
                                               MAKETE(floatToNum(0), 0.25f, TweenerEaseOut)]];
    t.fromValue = floatToNum(distance);
    return t;
}

+ (LTTweener *)tweenerMoveOutWithAlex:(NSString *)alex andDistance:(float)distance andTarget:(CALayer *)target
{
    LTTweener *t = [LTTweener tweenerWithKeyPath:[@"transform.translation." stringByAppendingString:alex]
                                   andTarget:target
                                    andParms:@[MAKETE(floatToNum(distance * (1 -VALUE_NORMAL_SCALE)), 0.25f, TweenerEaseOut),
                                               MAKETE(floatToNum(distance), 0.25f, TweenerEaseIn)]];
    t.fromValue = floatToNum(0);
    return t;
}
#pragma mark - key
+ (NSString *)translation
{
    static NSString *key = @"transform.translation";
    return key;
}

+ (NSString *)translationX
{
    static NSString *key = @"transform.translation.x";
    return key;
}

+ (NSString *)translationY
{
    static NSString *key = @"transform.translation.y";
    return key;
}

+ (NSString *)scale
{
    static NSString *key = @"transform.scale";
    return key;
}

+ (NSString *)scaleX
{
    static NSString *key = @"transform.scale.x";
    return key;
}

+ (NSString *)scaleY
{
    static NSString *key = @"transform.scale.y";
    return key;
}

+ (NSString *)rotationX
{
    static NSString *key = @"transform.rotation.x";
    return key;
}

+ (NSString *)rotationY
{
    static NSString *key = @"transform.rotation.y";
    return key;
}

+ (NSString *)rotationZ
{
    static NSString *key = @"transform.rotation.z";
    return key;
}

+ (NSString *)opacity
{
    static NSString *key = @"opacity";
    return key;
}

+ (NSString *)position
{
    static NSString *key = @"position";
    return key;
}

+ (NSString *)positionX
{
    static NSString *key = @"position.x";
    return key;
}

+ (NSString *)positionY
{
    static NSString *key = @"position.y";
    return key;
}
@end
