//
//  YMCTransitionAnimator.m
//  gesturedFold
//
//  Created by Vladislav Alekseev on 16.09.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import "YMCTransitionAnimator.h"
#import "YMCGesturedTransition.h"
#import <QuartzCore/QuartzCore.h>
#import "YMCGesturedTransitionSubclass.h"

@interface YMCTransitionAnimator ()
@property (nonatomic, readonly) UIScreen *animationScreen;
@property (nonatomic, readonly) NSArray *animations;
@property (nonatomic, assign) CADisplayLink *animationDisplayLink;
@end

@implementation YMCTransitionAnimator

- (void)attachToDisplayLink {
    if (self.animationDisplayLink) {
        return;
    }
    self.animationDisplayLink = [self.animationScreen displayLinkWithTarget:self
                                                                   selector:@selector(displayLinkDidUpdate:)];
    [self.animationDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)detachFromDisplayLink {
    [self.animationDisplayLink invalidate];
    self.animationDisplayLink = nil;
}

#pragma mark - Internal Properties

- (UIScreen *)animationScreen {
    UIScreen *screen = self.gesturedTransition.managedView.window.screen;
    if (!screen) {
        screen = [UIScreen mainScreen];
    }
    return screen;
}

#pragma mark - Timing Function Support

static inline CGFloat cubed(CGFloat value){
    return value*value*value;
}

static inline CGFloat squared(CGFloat value){
    return value*value;
}

// see http://cocoawithlove.com/2008/09/parametric-acceleration-curves-in-core.html
// http://code.google.com/r/truongnnuit-cocotron/source/browse/QuartzCore/CARenderer.m?r=3314d926f006fcefd11a1c27a2529bea49bc4c9e
- (CGFloat)progressValueBySolvingTimingFunction:(CAMediaTimingFunction *)function forValue:(CGFloat)t {
    CGFloat cp1[2];
    CGFloat cp2[2];
    
    [function getControlPointAtIndex:1 values:cp1];
    [function getControlPointAtIndex:2 values:cp2];
    
    CGFloat y = cubed(1.0-t)*0.0+3*squared(1-t)*t*cp1[1]+3*(1-t)*squared(t)*cp2[1]+cubed(t)*1.0;
    
    return y;
}

#pragma mark - Display Link 

- (void)displayLinkDidUpdate:(CADisplayLink *)displayLink {
    NSArray *keys = [self.gesturedTransition animationKeys];
    for (NSString *key in keys) {
        CABasicAnimation *animation = [self.gesturedTransition animationForKey:key];
        
        if (animation.beginTime > displayLink.timestamp) {
            continue;
        }
        if (animation.beginTime < displayLink.timestamp && animation.beginTime > displayLink.timestamp - displayLink.duration) {
            if ([animation.delegate respondsToSelector:@selector(animationDidStart:)]) {
                [animation.delegate animationDidStart:animation];
            }
        }
        
        if (animation.beginTime + animation.duration < displayLink.timestamp) {
            [self.gesturedTransition setValue:animation.toValue forKey:animation.keyPath];
            [self.gesturedTransition removeAnimationForKey:key];
            continue;
        }
        else {
            CFTimeInterval timeSinceStart = displayLink.timestamp - animation.beginTime;
            CGFloat progressValue = timeSinceStart/animation.duration;
            
            if (animation.timingFunction) {
                progressValue = [self progressValueBySolvingTimingFunction:animation.timingFunction forValue:progressValue];
            }
            id calculatedValue = [self.gesturedTransition animationValueForKey:animation.keyPath
                                                                   sourceValue:animation.fromValue
                                                                   targetValue:animation.toValue
                                                                   forProgress:progressValue];
            
            [self.gesturedTransition setValue:calculatedValue forKey:animation.keyPath];
        }
    }
}

@end
