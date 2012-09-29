//
//  UIToolbar+YMCToolbarAnimatedUpdate.h
//  ToolbarAnimatedChange
//
//  Created by Vladislav Alekseev on 10.09.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import <dispatch/dispatch.h>

@interface UIToolbar (YMCToolbarAnimatedUpdate)

- (void)rotateToolbarUpdatingWithBlock:(dispatch_block_t)block direction:(BOOL)up;

@end
