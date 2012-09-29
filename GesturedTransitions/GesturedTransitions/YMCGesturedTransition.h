//
//  YMCGesturedTransition.h
//  gesturedFold
//
//  Created by Vladislav Alexeev on 23.05.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

/**
 Default duration of the animations that will be attached to this transition.
 */
UIKIT_EXTERN CGFloat const kYMCGesturedTransitionDefaultDuration;

/**
 The basic transition class. 
 Transition imitate updates of the view appearance by creating
 a image copy of the view and removing it from the window hierarchy.
 When transition starts, it hides managedView. 
 When transition finishes, it shows managedView.
 */
@interface YMCGesturedTransition : NSObject

/**
 A view that will be modified during transition.
 */
@property (nonatomic, strong) UIView *managedView;

/**
 Represents current progress of the transition. Animatable.
 Valid values are from 0.0 (managedView is completely modified) to 1.0 (managedView is not modified).
 Defaults to 1.0.
 */
@property (nonatomic, assign) CGFloat value;

/**
 Adds specified animation and updates state using it's properties.
 Currently only the following properties are considered:
 - beginTime (optional)
 - duration (optional, you can obtain default duration from kYMCGesturedTransitionDefaultDuration const)
 - fromValue (optional, using current value if no specified)
 - toValue (required)
 - timingFunction (optional)
 - keyPath (required, base class supports only @"value")
 
 Other properties of the animation are ignored. 
 Animations will notify it's delegate when it will start and stop.
 @param animation Animation to attach. Animation is copied.
 @param key Key that to associate animation with. Must not be nil.
 */
- (void)addAnimation:(CABasicAnimation *)animation forKey:(NSString *)key;

/** 
 Remove any animation attached to the gestured transition for 'key'. 
*/
- (void)removeAnimationForKey:(NSString *)key;

/**
 Remove all animations attached to the gestured transition.
 */
- (void)removeAllAnimations;

/**
 Returns an array containing the keys of all animations currently attached to the receiver. 
 */
- (NSArray *)animationKeys;

/**
 Returns the animation with identifier 'key', or nil if no such animation exists. 
 Attempting to modify any properties of the returned object will result in undefined behavior. 
 */
- (CABasicAnimation *)animationForKey:(NSString *)key;

@end
