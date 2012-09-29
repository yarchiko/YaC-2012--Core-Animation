//
//  YMCTransitionAnimator.h
//  gesturedFold
//
//  Created by Vladislav Alekseev on 16.09.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

@class YMCGesturedTransition;

/**
 Animator performs the animations attached to YMCGesturedTransition object.
 It is activated and deactivated by YMCGesturedTransition object.
 */
@interface YMCTransitionAnimator : NSObject

/**
 Gestured Transition object that is being animated by this animator.
 */
@property (nonatomic, assign) YMCGesturedTransition *gesturedTransition;

/**
 Activates animator so it can animate attached transition. 
 This happens when a new animation is attached to the Gestured Transition.
 */
- (void)attachToDisplayLink;

/**
 Deactivates animator. This happens when the last animation finishes.
 */
- (void)detachFromDisplayLink;

@end
