//
//  YMCFoldGesturedTransition.h
//  gesturedFold
//
//  Created by Vladislav Alexeev on 23.05.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import "YMCGesturedTransition.h"
#import <QuartzCore/QuartzCore.h>

/**
 The transition that performs folding of the managedView.
 */
@interface YMCFoldGesturedTransition : YMCGesturedTransition

/**
 Indicates number of folds. Defaults to 5.
 */
@property (nonatomic, assign) NSUInteger numberOfFolds;

@end
