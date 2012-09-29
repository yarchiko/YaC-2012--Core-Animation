//
//  YMCAnimationCompletionHandler.h
//  SpringboardTransition
//
//  Created by Vladislav Alekseev on 13.09.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

typedef void (^YMCAnimationEventsHandlerBlock)(BOOL finished);

@interface YMCAnimationEventsHandler : NSObject

@property (nonatomic, assign, readonly) CAAnimation *animation;
@property (nonatomic, copy) YMCAnimationEventsHandlerBlock startHandler;
@property (nonatomic, copy) YMCAnimationEventsHandlerBlock completionHandler;

+ (id)handlerForAnimation:(CAAnimation *)animation
             startHandler:(YMCAnimationEventsHandlerBlock)startHandler
        completionHandler:(YMCAnimationEventsHandlerBlock)completionHandler;

@end
