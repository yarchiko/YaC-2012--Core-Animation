//
//  UIView+YMCSpringboardTransition.m
//  SpringboardTransition
//
//  Created by Vladislav Alekseev on 14.09.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import "MPViewRendering.h"
#import "YMCSpringboardLayer.h"
#import <QuartzCore/QuartzCore.h>
#import "YMCAnimationEventsHandler.h"
#import "UIView+YMCSpringboardTransition.h"

static NSString *const kYMCSpringboardTransitionMoveAnimationKey = @"kYMCSpringboardTransitionMoveAnimationKey";
static NSString *const kYMCSpringboardTransitionDimAnimationKey = @"kYMCSpringboardTransitionDimAnimationKey";

@implementation UIView (YMCSpringboardTransition)

- (void)updateViewWithSpringboardTransitionUsingBlock:(dispatch_block_t)updateBlock duration:(NSTimeInterval)duration {
    YMCSpringboardLayer *sourceContentLayer = [self ymc_layerWithCurrentViewContents];
    
    if (updateBlock) {
        updateBlock();
    }
    
    YMCSpringboardLayer *targetContentLayer = [self ymc_layerWithCurrentViewContents];
    
    [self.layer.superlayer addSublayer:sourceContentLayer];
    [self.layer.superlayer addSublayer:targetContentLayer];
    self.hidden = YES;
    
    CAAnimation *zoomingOutAnimation = [self ymc_animationWithDuration:duration forZoomingIn:NO];
    CAAnimation *dimmingInAnimation = [self ymc_dimAnimationWithDuration:duration forZoomingIn:NO];
    CAAnimation *zoomnigInAnimation = [self ymc_animationWithDuration:duration forZoomingIn:YES];
    CAAnimation *dimmingOutAnimation = [self ymc_dimAnimationWithDuration:duration forZoomingIn:YES];
    
    [YMCAnimationEventsHandler handlerForAnimation:zoomnigInAnimation startHandler:NULL completionHandler:^(BOOL finished) {
        [sourceContentLayer removeFromSuperlayer];
        [targetContentLayer removeFromSuperlayer];
        self.hidden = NO;
    }];
    
    [sourceContentLayer addAnimation:zoomingOutAnimation forKey:kYMCSpringboardTransitionMoveAnimationKey];
    [sourceContentLayer.dimLayer addAnimation:dimmingInAnimation forKey:kYMCSpringboardTransitionDimAnimationKey];
    [targetContentLayer addAnimation:zoomnigInAnimation forKey:kYMCSpringboardTransitionMoveAnimationKey];
    [targetContentLayer.dimLayer addAnimation:dimmingOutAnimation forKey:kYMCSpringboardTransitionDimAnimationKey];
}

- (YMCSpringboardLayer *)ymc_layerWithCurrentViewContents {
    YMCSpringboardLayer *sourceContentLayer = [YMCSpringboardLayer layer];
    UIImage *img = [MPViewRendering renderImageFromView:self];
    img = [MPViewRendering renderImageForAntialiasing:img];
    sourceContentLayer.contents = (id)img.CGImage;
    sourceContentLayer.frame = self.frame;
    return sourceContentLayer;
}

- (CATransform3D)ymc_transformWithValue:(CGFloat)value directionLeft:(BOOL)isLeft {
    CATransform3D t = CATransform3DIdentity;
    t.m34 = -1.0/800.0;
    
    CGFloat xOffsetValue = sinf(M_PI * value); // value = 0 ... 1
    
    CGFloat viewWidth = CGRectGetWidth(self.frame);
    CGFloat scale = 1.0 - 0.5 * value;
    CGFloat xTranslation = (isLeft ? -1.0 : 1.0) * xOffsetValue * viewWidth/1.8;
    
    CGFloat zTranslation = - viewWidth * value;
    
    t = CATransform3DScale(t, scale, scale, scale);
    t = CATransform3DTranslate(t,
                               xTranslation,
                               0.0,
                               zTranslation);
    t = CATransform3DRotate(t, (isLeft ? 1.0 : -1.0) * M_PI_2/90.0*30.0 * value, 0.0, 1.0, 0.0);
    return t;
}

- (NSArray *)ymc_valuesWithCount:(NSUInteger)count zoomingIn:(BOOL)zoomingIn {
    NSMutableArray *values = [NSMutableArray array];
    for (NSUInteger index = 0; index < count; index++) {
        CGFloat value;
        if (zoomingIn) {
            value = (CGFloat)(count - 1.0 - index)/(CGFloat)(count - 1.0);
        }
        else {
            value = (CGFloat)index/(CGFloat)(count - 1.0);
        }
        
        CATransform3D t = [self ymc_transformWithValue:value directionLeft:!zoomingIn];
        NSValue *v = [NSValue valueWithCATransform3D:t];
        [values addObject:v];
    }
    return [NSArray arrayWithArray:values];
}

- (CAKeyframeAnimation *)ymc_animationWithDuration:(CFTimeInterval)duration forZoomingIn:(BOOL)zoomingIn {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.values = [self ymc_valuesWithCount:10 zoomingIn:zoomingIn];
    animation.removedOnCompletion = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fillMode = kCAFillModeForwards;
    animation.calculationMode = kCAAnimationCubicPaced;
    animation.duration = duration;
    return animation;
}

- (CABasicAnimation *)ymc_dimAnimationWithDuration:(CFTimeInterval)duration forZoomingIn:(BOOL)zoomingIn {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = zoomingIn ? @1.0f : @0.0f;
    animation.toValue = zoomingIn ? @0.0f : @1.0f;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration = duration;
    return animation;
}

@end
