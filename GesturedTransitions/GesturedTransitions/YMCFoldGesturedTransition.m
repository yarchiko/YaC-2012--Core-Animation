//
//  BFFoldGesturedTransition.m
//  gesturedFold
//
//  Created by Vladislav Alexeev on 23.05.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import "YMCFoldPartLayer.h"
#import "MPViewRendering.h"
#import "YMCFoldGesturedTransition.h"
#import "YMCGesturedTransitionSubclass.h"

@interface YMCFoldGesturedTransition ()
@property (nonatomic, strong) NSMutableArray *foldLayers;
@property (nonatomic, readonly) NSUInteger numberOfParts;
@property (nonatomic, readonly) CGFloat partHeight;
@end

@implementation YMCFoldGesturedTransition
@synthesize numberOfFolds = _numberOfFolds;
@dynamic numberOfParts;
@synthesize foldLayers = _foldLayers;

#pragma mark - Init

- (id)init {
    self = [super init];
    if (self) {
        _numberOfFolds = 5;
        _foldLayers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [self removeTransitionIfNeeded];
}

#pragma mark - Subclassed Methods

- (void)addTransitionIfNeeded {
    if ([self.foldLayers count] == 0) {
        [self preparePartLayers];
    }
    [super addTransitionIfNeeded];
}

- (void)removeTransitionIfNeeded {
    [super removeTransitionIfNeeded];
    
    [self.foldLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.foldLayers removeAllObjects];
}

- (void)updateTransitionWithValue:(CGFloat)value {
    for (YMCFoldPartLayer *partLayer in self.foldLayers) {
        NSUInteger layerIndex = [self.foldLayers indexOfObject:partLayer];
        [self updateTransitionForPartLayer:partLayer layerIndex:layerIndex withValue:value];
    }
}

#pragma mark - Internal Staff

- (NSUInteger)numberOfParts {
    return self.numberOfFolds + 1;
}

- (void)preparePartLayers {
    for (NSUInteger index = 0; index < self.numberOfParts; index++) {
        YMCFoldPartLayer *partLayer = [self layerForPartAtIndex:index];
        [self.foldLayers addObject:partLayer];
        [self.parentLayer addSublayer:partLayer];
    }
}

#pragma mark - Content, Rects and Layers

- (CGFloat)partHeight {
    CGFloat partHeight = CGRectGetHeight(self.managedView.frame) / self.numberOfParts;
    return partHeight;
}

- (CGRect)rectForPartAtIndex:(NSUInteger)index {
    CGRect rect = CGRectMake(0,
                             self.partHeight*index, 
                             CGRectGetWidth(self.managedView.frame),
                             self.partHeight);
    return rect;
}

- (YMCFoldPartLayer *)layerForPartAtIndex:(NSUInteger)index {
    CGRect partRect = [self rectForPartAtIndex:index];
    
    YMCFoldPartLayer *partLayer = [YMCFoldPartLayer layer];
    partLayer.frame = partRect;
    partLayer.contents = (id)[[self imageForPartAtIndex:index] CGImage];
    return partLayer;
}

- (UIImage *)imageForPartAtIndex:(NSUInteger)index {
    CGRect partRect = [self rectForPartAtIndex:index];
    UIImage *image = [self viewImageWithRect:partRect];
    image = [MPViewRendering renderImageForAntialiasing:image withInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
    return image;
}

- (CATransform3D)transformForPartAtIndex:(NSUInteger)index value:(CGFloat)value {
    BOOL isIndexEven = (index % 2 == 0);
    
    CGFloat partHeight = self.partHeight;
    CGFloat projectedHeight = partHeight * value;
    CGFloat angle;
    if (isIndexEven) {
        angle = M_PI_2 + M_PI + asinf(projectedHeight/partHeight);
    }
    else {
        angle = -M_PI_2 + M_PI - asinf(projectedHeight/partHeight);
    }
    
    CGFloat heightsDiff = (partHeight - projectedHeight)/2.0;
    CGFloat translateByY = heightsDiff*(1.0 + 2.0*index);
     
    CATransform3D t = CATransform3DIdentity;
    t = CATransform3DTranslate(t, 0.0, -translateByY, 0.0);
    t = CATransform3DRotate(t, angle, 1.0, 0, 0);
    
    return t;
}

- (void)updateTransitionForPartLayer:(YMCFoldPartLayer *)partLayer layerIndex:(NSUInteger)layerIndex withValue:(CGFloat)value {
    CATransform3D transform = [self transformForPartAtIndex:layerIndex value:value];
    partLayer.transform = transform;
    partLayer.dimLayer.opacity = (1.0-value)*0.25;
}

@end
