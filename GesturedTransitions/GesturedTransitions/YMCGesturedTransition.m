//
//  YMCGesturedTransition.m
//  gesturedFold
//
//  Created by Vladislav Alexeev on 23.05.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import "MPViewRendering.h"
#import "YMCGesturedTransition.h"
#import "YMCTransitionAnimator.h"
#import "YMCGesturedTransitionSubclass.h"

CGFloat const kYMCGesturedTransitionDefaultDuration = 0.75;

@interface YMCGesturedTransition ()
@property (nonatomic, strong) CALayer *parentLayer;
@property (nonatomic, strong) UIImage *viewImage;
@property (nonatomic, strong) YMCTransitionAnimator *animator;
@property (nonatomic, strong) NSMutableDictionary *animations;
@end

@implementation YMCGesturedTransition

#pragma mark - Init and Dealloc

- (id)init
{
    self = [super init];
    if (self) {
        _value = 1.0;
    }
    return self;
}

- (void)dealloc {
    _animator.gesturedTransition = nil;
    [_animator detachFromDisplayLink];
    [self removeTransitionIfNeeded];
}

#pragma mark - Public Interface

- (void)setValue:(CGFloat)value {
    if (_value == value) {
        return;
    }
    _value = value;
    
    if (_value == 1.0) {
        [self removeTransitionIfNeeded];
    }
    else {
        [self setTransitionValue:value];
    }
}

#pragma mark - Private Stuff Accessible from Subclasses

- (UIImage *)viewImage {
    if (!_viewImage) {
        BOOL viewInitiallyHidden = self.managedView.isHidden;
        self.managedView.hidden = NO;
        _viewImage = [MPViewRendering renderImageFromView:self.managedView];
        self.managedView.hidden = viewInitiallyHidden;
    }
    return _viewImage;
}

- (UIImage *)viewImageWithRect:(CGRect)rect {
    BOOL viewInitiallyHidden = self.managedView.isHidden;
    self.managedView.hidden = NO;
    UIImage *img = [MPViewRendering renderImageFromView:self.managedView withRect:rect];
    self.managedView.hidden = viewInitiallyHidden;
    return img;
}

- (CALayer *)parentLayer {
    if (_parentLayer == nil) {
        _parentLayer = [CALayer layer];
        _parentLayer.frame = self.managedView.frame;
        CATransform3D t = CATransform3DIdentity;
        t.m34 = -1.0/1000.0;
        _parentLayer.sublayerTransform = t;
    }
    return _parentLayer;
}

#pragma mark - Internal

- (void)setTransitionValue:(CGFloat)value {
    [CATransaction setDisableActions:YES];
    [self addTransitionIfNeeded];
    [self updateTransitionWithValue:value];
}

#pragma mark - Subclass

- (void)addTransitionIfNeeded {
    [CATransaction setDisableActions:YES];
    [self.managedView setHidden:YES];
    [self.managedView.layer.superlayer addSublayer:self.parentLayer];
}

- (void)removeTransitionIfNeeded {
    [CATransaction setDisableActions:YES];
    [self.managedView setHidden:NO];
    [self.parentLayer removeFromSuperlayer];
}

- (void)updateTransitionWithValue:(CGFloat)value {
    [CATransaction setDisableActions:YES];
}

#pragma mark - Animations support

- (YMCTransitionAnimator *)animator {
    if (_animator == nil) {
        _animator = [[YMCTransitionAnimator alloc] init];
        _animator.gesturedTransition = self;
    }
    return _animator;
}

- (NSMutableDictionary *)animations {
    if (_animations == nil) {
        _animations = [[NSMutableDictionary alloc] init];
    }
    return _animations;
}

- (void)addAnimation:(CABasicAnimation *)animation forKey:(NSString *)key {
    NSParameterAssert(key);
    NSParameterAssert(animation);
    
    if (animation.beginTime == 0.0) {
        animation.beginTime = CACurrentMediaTime();
    }
    if (animation.duration == 0.0) {
        animation.duration = kYMCGesturedTransitionDefaultDuration;
    }
    if (animation.fromValue == nil) {
        animation.fromValue = [self valueForKey:animation.keyPath];
    }
    
    [self.animations setObject:[animation copy] forKey:key];
    [self.animator attachToDisplayLink];
}

- (void)removeAnimationForKey:(NSString *)key {
    CABasicAnimation *animationToRemove = [self animationForKey:key];
    if ([animationToRemove.delegate respondsToSelector:@selector(animationDidStop:finished:)]) {
        BOOL finished = ([[self valueForKey:animationToRemove.keyPath] isEqual:animationToRemove.toValue]);
        [animationToRemove.delegate animationDidStop:animationToRemove finished:finished];
    }
    [self.animations removeObjectForKey:key];
    if ([self.animations count] == 0) {
        [self.animator detachFromDisplayLink];
    }
}

- (void)removeAllAnimations {
    [self.animations removeAllObjects];
    [self.animator detachFromDisplayLink];
}

- (id)animationValueForKey:(NSString *)key sourceValue:(id)fromValue targetValue:(id)toValue forProgress:(CGFloat)progress {
    if ([key isEqualToString:@"value"]) {
        CGFloat value = [fromValue floatValue] * (1.0 - progress) + [toValue floatValue] * (progress);
        return @(value);
    }
    NSAssert(NO, @"Unknown key %@. You must override %@ method and return correct value.", key, NSStringFromSelector(_cmd));
    return nil;
}

- (NSArray *)animationKeys {
    return [self.animations allKeys];
}

- (CABasicAnimation *)animationForKey:(NSString *)key {
    return [self.animations objectForKey:key];
}

@end
