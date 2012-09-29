//
//  UIView+YMCSpringboardTransition.h
//  SpringboardTransition
//
//  Created by Vladislav Alekseev on 14.09.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (YMCSpringboardTransition)

- (void)updateViewWithSpringboardTransitionUsingBlock:(dispatch_block_t)updateBlock duration:(NSTimeInterval)duration;

@end
