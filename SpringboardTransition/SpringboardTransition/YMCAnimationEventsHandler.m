//
//  YMCAnimationCompletionHandler.m
//  SpringboardTransition
//
//  Created by Vladislav Alekseev on 13.09.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import "YMCAnimationEventsHandler.h"

@interface YMCAnimationEventsHandler ()
@property (nonatomic, assign) CAAnimation *animation;
@end

@implementation YMCAnimationEventsHandler

+ (id)handlerForAnimation:(CAAnimation *)animation
             startHandler:(YMCAnimationEventsHandlerBlock)startHandler
        completionHandler:(YMCAnimationEventsHandlerBlock)completionHandler {
    YMCAnimationEventsHandler *handler = [[self alloc] init];
    handler.animation = animation;
    animation.delegate = handler;
    handler.completionHandler = completionHandler;
    handler.startHandler = startHandler;
    return handler;
}

#pragma mark - Animation Delegate

- (void)animationDidStart:(CAAnimation *)theAnimation {
    if (self.startHandler) {
        self.startHandler(NO);
        self.startHandler = nil;
    }
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished {
    if (self.completionHandler) {
        self.completionHandler(finished);
        self.completionHandler = nil;
    }
    self.startHandler = nil;
}

@end
