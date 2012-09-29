//
//  UIView+ShredderingAnimation.h
//  gesturedFold
//
//  Created by Vladislav Alekseev on 12.09.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (YMCShredderingAnimation)

- (void)animateShredderingWithCompletionHandler:(dispatch_block_t)handler;

@end
