//
//  YMCGesturedTransition+Subclass.h
//  gesturedFold
//
//  Created by Vladislav Alexeev on 30.05.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import "YMCGesturedTransition.h"

@interface YMCGesturedTransition (YMCForSubclassEyesOnly)

/**
 A layer which subsclasses can use to add their sublayers to.
 */
@property (nonatomic, readonly, strong) CALayer *parentLayer;

/**
 An image of the view which is being transitioned.
 */
@property (nonatomic, readonly, strong) UIImage *viewImage;

/**
 Returns an image of the view cropped to the specified rect.
 */
- (UIImage *)viewImageWithRect:(CGRect)rect;

/**
 Called when transition begins or updates. 
 You should create and add your internal layer structure to the parentLayer (if you didn't yet).
 You must call super implementation.
 */
- (void)addTransitionIfNeeded;

/**
 Called when transition is finished.
 You should remove your internal layer structure from the parentLayer.
 You must call super implementation.
 */
- (void)removeTransitionIfNeeded;

/**
 Called when transition is updated.
 Update your internal layer structure with specified value.
 Default implementation disables actions for current CATransaction.
 @param value A transition progress, form 0.0 to 1.0
 */
- (void)updateTransitionWithValue:(CGFloat)value;

/**
 Called by the animator while animating the changing of the property.
 In order to support custom animations you must calculate appropriate middle value for the progress
 using provided fromValue and toValue.
 Default implementation supports calculating the value for the "value" key, where fromValue and toValue are NSNumbers.
 @param key KeyPath that is used to create an basic animation attached to the gestured transition.
 @param fromValue Source value that was set to the animation's fromValue property.
 @param toValue Target value that was set to the animation's toValue property.
 @param progress Current animation progress, may be 0.0 ... 1.0. 0.0 means animation was just started, 1.0 - finished.
 @return "middle" value for the animation with the specified key and values.
 */
- (id)animationValueForKey:(NSString *)key sourceValue:(id)fromValue targetValue:(id)toValue forProgress:(CGFloat)progress;

@end
