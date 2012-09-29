//
//  YMCAnimationCompletionHandler.h
//  SpringboardTransition
//
//  Created by Vladislav Alekseev on 13.09.12.
//  Copyright (c) 2012 Yandex. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

typedef void (^YMCAnimationEventsStartBlock)();
typedef void (^YMCAnimationEventsFinishBlock)(BOOL finished);

@interface YMCAnimationEventsHandler : NSObject

@property (nonatomic, assign, readonly) CAAnimation *animation;
@property (nonatomic, copy) YMCAnimationEventsStartBlock startHandler;
@property (nonatomic, copy) YMCAnimationEventsFinishBlock completionHandler;

+ (id)handlerForAnimation:(CAAnimation *)animation
             startHandler:(YMCAnimationEventsStartBlock)startHandler
        completionHandler:(YMCAnimationEventsFinishBlock)completionHandler;

@end
