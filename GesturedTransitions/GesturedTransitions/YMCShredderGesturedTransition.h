//
//  YMCShredderTransition.h
//  gesturedFold
//
//  Created by Vladislav Alekseev on 12.09.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import "YMCGesturedTransition.h"

/**
 A transition that performs shreddering of the managedView like in Passbook app.
 This type of transition supports animating the falls of the shreddered lines. 
 This transition is optimised for view with 300 pt width because of shredder machine image which has 320 pt width.
 So, before using this transformation, you will probably need to shrink your view a little, or you can go ahead and update resources and make it work for your needs.
 @see fallProgress.
 */
@interface YMCShredderGesturedTransition : YMCGesturedTransition

/**
 Number of resulting lines that shredder machine generates.
 Changing this after transition is beign presented not supported.
 For better results use odd values (5, 7, 9, etc.)
 Minimum allowed value is 2. Defaults to 15.
 */
@property (nonatomic, assign) NSUInteger numberOfLines;

/**
 Maximum vertical offset of the lines relatively to each other.
 Defaults to 3.0.
 */
@property (nonatomic, assign) CGFloat maximumVerticalOffset;

/**
 Allows you to adjust progress of the falling of the shreddered lines. Animatable.
 When configuring CABasicAnimation, use NSNumber values from 0.0 (lines are in their places) to 1.0 (lines are falled).
 The value of this property should be changed only when transition is completed, that is, when value is 0.0.
 */
@property (nonatomic, assign) CGFloat fallProgress;

@end
