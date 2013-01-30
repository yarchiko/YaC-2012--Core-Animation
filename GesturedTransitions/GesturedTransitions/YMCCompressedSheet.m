//
//  YMCCompressedSheet.m
//  GesturedTransitions
//
//  Created by beefon on 30.01.13.
//  Copyright (c) 2013 Yandex Mobile Camp. All rights reserved.
//

#import "YMCCompressedSheet.h"
#import "YMCGesturedTransitionSubclass.h"

NSUInteger const YMCCompressedSheetDefaultLayersCount = 5;
CGFloat const YMCCompressedSheetDefaultCurlHeight = 75.0;

@interface YMCCompressedSheet ()

@property (nonatomic, strong) NSMutableArray *mutableLayers;

@end

@implementation YMCCompressedSheet

- (id)init
{
    self = [super init];
    if (self) {
        _numberOfLayers = YMCCompressedSheetDefaultLayersCount;
        _curlHeight = YMCCompressedSheetDefaultCurlHeight;
        _mutableLayers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addTransitionIfNeeded {
    if (self.mutableLayers.count == 0) {
        for (NSUInteger idx = 0; idx < self.numberOfLayers; idx++) {
            CALayer *sublayer = [self sublayerWithIndex:idx];
            [self.mutableLayers addObject:sublayer];
            [self.parentLayer addSublayer:sublayer];
        }
    }
}

- (void)removeTransitionIfNeeded {
    if (self.mutableLayers.count > 0) {
        [self.mutableLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [self.mutableLayers removeAllObjects];
    }
}

- (void)updateTransitionWithValue:(CGFloat)value {
    
}

- (CALayer *)sublayerWithIndex:(NSUInteger)index {
    CGFloat partHeight = CGRectGetHeight(self.managedView.bounds) / self.numberOfLayers;
    CGFloat partOffset = partHeight * index;
    
    CGRect rect = CGRectMake(0, partOffset, CGRectGetWidth(self.managedView.bounds), partHeight);
    UIImage *partImage = [self viewImageWithRect:rect];
    CALayer *l = [CALayer layer];
    l.frame  = rect;
    l.contents = partImage.CGImage;
    return l;
}

- (CGFloat)zPositionForY:(CGFloat)y {
    CGFloat z = 0;
    if (y < 0) {
        y = 0;
    }
    
    if (y < self.curlHeight) {
        z = sinf(M_PI_2 * y / self.curlHeight);
    }
    return z;
}

- (CGFloat)angleForY:(CGFloat)y {
    CGFloat angle = 0;
    if (y < 0) {
        y = 0;
    }
    
    if (y < self.curlHeight) {
        
    }
    return angle;
}

@end
