//
//  UIView+ShredderingAnimation.m
//  gesturedFold
//
//  Created by Vladislav Alekseev on 12.09.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import "YMCShredderGesturedTransition.h"
#import "UIView+YMCShredderingAnimation.h"
#import "YMCGesturedTransitionSubclass.h"
#import "YMCAnimationEventsHandler.h"

@implementation UIView (YMCShredderingAnimation)

- (void)animateShredderingWithCompletionHandler:(dispatch_block_t)handler {
    YMCShredderGesturedTransition *transition = [[YMCShredderGesturedTransition alloc] init];
    transition.managedView = self;
    transition.value = 0.99; // setting the value smaller than 1.0 initiates transition, capturing screenshot, etc.
    // we do it here to not loose Core Animation frames later
    
    CABasicAnimation *shredderAnimation = [CABasicAnimation animationWithKeyPath:@"value"]; // will start from current value (0.99 in our case)
    shredderAnimation.toValue = @0.0;
    shredderAnimation.duration = 1.3;
    
    [YMCAnimationEventsHandler handlerForAnimation:shredderAnimation startHandler:NULL completionHandler:^(BOOL finished) {
        CABasicAnimation *fallAnimation = [CABasicAnimation animationWithKeyPath:@"fallProgress"];
        fallAnimation.fromValue = @0.0;
        fallAnimation.toValue = @1.0;
        fallAnimation.duration = 0.75;
        fallAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        
        [YMCAnimationEventsHandler handlerForAnimation:fallAnimation startHandler:NULL completionHandler:^(BOOL finished) {
            [transition value];  // ugly solution to keep transition alive till the end of fall animation
            if (handler) {
                handler();
            }
        }];
        [transition addAnimation:fallAnimation forKey:@"fallAnimation"];
    }];
    
    [transition addAnimation:shredderAnimation forKey:@"shredderAnimation"];
}

@end
