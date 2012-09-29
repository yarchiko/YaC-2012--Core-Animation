//
//  YMCFoldPartLayer.m
//  gesturedFold
//
//  Created by Vladislav Alexeev on 23.05.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import "YMCFoldPartLayer.h"

@implementation YMCFoldPartLayer
@synthesize dimLayer = _dimLayer;

- (id)init {
    self = [super init];
    if (self) {
        //self.doubleSided = NO;
        [self addSublayer:self.dimLayer];
    }
    return self;
}

- (CAGradientLayer *)dimLayer {
    if (_dimLayer == nil) {
        _dimLayer = [[CAGradientLayer alloc] init];
        _dimLayer.frame = self.bounds;
        _dimLayer.colors = [NSArray arrayWithObjects:
                            (id)[[UIColor blackColor] CGColor],
                            (id)[[UIColor clearColor] CGColor], nil];
        _dimLayer.opacity = 0.5;
    }
    return _dimLayer;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.dimLayer.frame = self.bounds;
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.dimLayer.frame = self.bounds;
}

@end
