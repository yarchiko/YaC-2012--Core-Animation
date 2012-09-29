//
//  YMCSpringboardLayer.m
//  SpringboardTransition
//
//  Created by Vladislav Alekseev on 14.09.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import "YMCSpringboardLayer.h"

@interface YMCSpringboardLayer ()
@property (nonatomic, strong) CALayer *dimLayer;
@end

@implementation YMCSpringboardLayer

- (id)init {
    self = [super init];
    if (self) {
        self.contentsGravity = kCAGravityResizeAspect;
        [self addSublayer:self.dimLayer];
    }
    return self;
}

- (CALayer *)dimLayer {
    if (_dimLayer == nil) {
        _dimLayer = [CALayer layer];
        _dimLayer.backgroundColor = UIColor.blackColor.CGColor;
        _dimLayer.opacity = 0.0;
    }
    return _dimLayer;
}



- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.dimLayer.bounds = self.bounds;
    self.dimLayer.position = CGPointMake(CGRectGetWidth(bounds)/2, CGRectGetHeight(bounds)/2);
}

@end
