//
//  YMCShredderTransition.m
//  gesturedFold
//
//  Created by Vladislav Alekseev on 12.09.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import "MPViewRendering.h"
#import "YMCShredderMachineLayer.h"
#import "YMCGesturedTransitionSubclass.h"
#import "YMCShredderGesturedTransition.h"

static NSString *const kYMCShredderVerticalTranslationKey = @"kYMCShredderVerticalTranslationKey";
static NSString *const kYMCShredderOriginalFrameKey = @"kYMCShredderOriginalFrameKey";

@interface YMCShredderGesturedTransition ()
@property (nonatomic, strong) NSMutableArray *shredderLayers;
@property (nonatomic, strong) CALayer *originLayer;
@property (nonatomic, strong) YMCShredderMachineLayer *shredderMachineLayer;
@end

@implementation YMCShredderGesturedTransition

- (id)init
{
    self = [super init];
    if (self) {
        _numberOfLines = 17;
        _maximumVerticalOffset = 3.0;
    }
    return self;
}

- (NSMutableArray *)shredderLayers {
    if (_shredderLayers == nil) {
        _shredderLayers = [[NSMutableArray alloc] init];
    }
    return _shredderLayers;
}

#pragma mark - Subclass Methods

- (void)addTransitionIfNeeded {
    [super addTransitionIfNeeded];
    
    if (self.shredderMachineLayer.superlayer == nil) {
        [self.parentLayer addSublayer:self.originLayer];
        [self setupLayers];
        [self.parentLayer.superlayer addSublayer:self.shredderMachineLayer];
    }
}

- (void)removeTransitionIfNeeded {
    [super removeTransitionIfNeeded];
    
    [self.originLayer removeFromSuperlayer];
    [self.shredderLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.shredderLayers removeAllObjects];
    [self.shredderMachineLayer removeFromSuperlayer];
}

- (void)updateTransitionWithValue:(CGFloat)value {
    [super updateTransitionWithValue:value];
    
    [self updateOriginLayerWithValue:value];
    [self updateLayersWithValue:value];
    [self updateShredderMachineLayerWithValue:value];
}

- (void)setNumberOfLines:(NSUInteger)numberOfLines {
    if (_numberOfLines == numberOfLines) {
        return;
    }
    _numberOfLines = numberOfLines;
    self.shredderMachineLayer.numberOfLines = _numberOfLines;
}

#pragma mark - Internal

- (CALayer *)originLayer {
    if (_originLayer == nil) {
        _originLayer = [CALayer layer];
        _originLayer.contentsScale = self.parentLayer.contentsScale;
        CGRect bounds = self.parentLayer.bounds;
        _originLayer.frame = bounds;
        _originLayer.contentsGravity = kCAGravityResize;
        _originLayer.contents = (id)self.viewImage.CGImage;
        _originLayer.shouldRasterize = YES;
        
        CALayer *mask = [CALayer layer];
        mask.backgroundColor = UIColor.blackColor.CGColor;
        mask.anchorPoint = CGPointMake(0.5, 0.0);
        mask.bounds = bounds;
        mask.position = CGPointMake(CGRectGetWidth(bounds)/2, 0.0);
        _originLayer.mask = mask;
    }
    return _originLayer;
}

- (void)updateOriginLayerWithValue:(CGFloat)value {
    CGRect originRect = self.parentLayer.frame;
    CGRect clippedRect = originRect;
    clippedRect.size.height *= value;
    self.originLayer.mask.bounds = clippedRect;
    self.originLayer.zPosition = 2.0 + 10.0 * (1.0 - value/2);
    self.originLayer.hidden = (value == 0.0);
}

- (CALayer *)layerWithImage:(UIImage *)viewPartImage withFrame:(CGRect)layerFrame {
    CALayer *layer = [CALayer layer];
    layer.contentsScale = self.parentLayer.contentsScale;
    layer.contentsGravity = kCAGravityResizeAspectFill;
    layer.contents = (id)viewPartImage.CGImage;
    layer.anchorPoint = CGPointMake(0.5, 0.0);
    layer.frame = layerFrame;
    layer.shouldRasterize = YES;
    return layer;
}

- (CAGradientLayer *)dimLayerWithFrame:(CGRect)layerFrame {
    CAGradientLayer *dimLayer = [CAGradientLayer layer];
    dimLayer.colors = @[
        (id)UIColor.blackColor.CGColor,
        (id)[UIColor.blackColor colorWithAlphaComponent:0.5].CGColor,
        (id)UIColor.blackColor.CGColor
    ];
    dimLayer.locations = @[ @0.0, @0.5, @1.0 ];
    dimLayer.startPoint = CGPointMake(0.0, 0.0);
    dimLayer.endPoint = CGPointMake(1.0, 0.0);
    dimLayer.contentsScale = self.parentLayer.contentsScale;
    dimLayer.frame = CGRectMake(1.0, 0, layerFrame.size.width - 2.0, layerFrame.size.height);
    return dimLayer;
}

- (void)setupLayers {
    for (NSUInteger layerIndex = 0; layerIndex < self.numberOfLines; layerIndex++) {
        CGFloat layerWidth = CGRectGetWidth(self.parentLayer.frame) / self.numberOfLines;
        
        CGRect layerFrame = CGRectMake(layerWidth*layerIndex,
                                       0.0,
                                       layerWidth,
                                       CGRectGetHeight(self.parentLayer.frame));
        CGRect viewPartRect = layerFrame;
        viewPartRect.origin = CGPointMake(CGRectGetWidth(viewPartRect) * layerIndex, 0);
        viewPartRect = CGRectInset(viewPartRect, 1.0, 0.0);
        
        UIImage *viewPartImage = [self viewImageWithRect:viewPartRect];
        viewPartImage = [MPViewRendering renderImageForAntialiasing:viewPartImage withInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
        CALayer *layer = [self layerWithImage:viewPartImage withFrame:layerFrame];
        CAGradientLayer *dimLayer = [self dimLayerWithFrame:layerFrame];
        [layer addSublayer:dimLayer];
        
        CGFloat vTranslation = [self verticalTranslationForLayerAtIndex:layerIndex layersCount:self.numberOfLines];
        [layer setValue:@(vTranslation) forKey:kYMCShredderVerticalTranslationKey];
        [layer setValue:[NSValue valueWithCGRect:layerFrame] forKey:kYMCShredderOriginalFrameKey];
        
        layer.transform = [self transformForShredderLayerAtIndex:layerIndex
                                                     layersCount:self.numberOfLines
                                     relativeVerticalTranslation:vTranslation
                                                   progressValue:0.0];
        dimLayer.opacity = [self opacityForDimLayerFromVerticalTranslation:vTranslation];
        [self.parentLayer addSublayer:layer];
        
        [self.shredderLayers addObject:layer];
    }
}

- (void)updateLayersWithValue:(CGFloat)value {
    for (CALayer *layer in self.shredderLayers) {
        CGFloat vTranslation = [[layer valueForKey:kYMCShredderVerticalTranslationKey] floatValue];
        NSUInteger index = [self.shredderLayers indexOfObject:layer];
        CATransform3D t = [self transformForShredderLayerAtIndex:index
                                                     layersCount:self.numberOfLines
                                     relativeVerticalTranslation:vTranslation
                                                   progressValue:(1.0 - value)];
        layer.transform = t;
    }
}

- (YMCShredderMachineLayer *)shredderMachineLayer {
    if (_shredderMachineLayer == nil) {
        _shredderMachineLayer = [YMCShredderMachineLayer layer];
        CGRect bounds = CGRectZero;
        bounds.size = [_shredderMachineLayer preferredFrameSize];
        _shredderMachineLayer.numberOfLines = self.numberOfLines;
        _shredderMachineLayer.bounds = bounds;
        _shredderMachineLayer.zPosition = 11.0;
    }
    return _shredderMachineLayer;
}

- (void)updateShredderMachineLayerWithValue:(CGFloat)value {
    if (value <= 0.0) {
        self.shredderMachineLayer.birthRate = 0.0;
    }
    else {
        self.shredderMachineLayer.birthRate = 1.0;
    }
    
    CGRect rect = self.managedView.frame;
    CGPoint position = CGPointMake(CGRectGetMinX(rect) + CGRectGetWidth(rect)/2.0, CGRectGetMinY(rect) + CGRectGetHeight(rect)*value);
    self.shredderMachineLayer.position = position;
}

#pragma mark - Helpers

- (CATransform3D)transformForShredderLayerAtIndex:(NSUInteger)index
                                      layersCount:(NSUInteger)count
                      relativeVerticalTranslation:(CGFloat)verticalTranslation
                                    progressValue:(CGFloat)progress {
    BOOL indexIsEven = (index % 2) == 0.0;
    
    CATransform3D t = CATransform3DMakeRotation(M_PI_2/90.0*3.0 * progress, 1.0, 0.0, 0.0);
    t = CATransform3DTranslate(t,
                               0.0,
                               self.maximumVerticalOffset + verticalTranslation * self.maximumVerticalOffset,
                               indexIsEven ? 1.0 : 0.0);
    return t;
}

- (CGFloat)verticalTranslationForLayerAtIndex:(NSUInteger)index layersCount:(NSUInteger)count {
    BOOL indexIsEven = (index % 2) == 0.0;
    CGFloat v = (CGFloat)arc4random()/(CGFloat)NSUIntegerMax;
    return indexIsEven ? v : -v;
}

- (CGFloat)opacityForDimLayerFromVerticalTranslation:(CGFloat)verticalTranslation {
    CGFloat alpha = 0.5 * (1.0 - verticalTranslation)*3.0/5.0;
    alpha = MIN(alpha, 1.0);
    alpha = MAX(0.0, alpha);
    if (verticalTranslation > 0) {
        alpha = 0.0;
    }
    return alpha;
}

#pragma mark - Fall Animation

- (NSArray *)sortedLayersToFall {
    NSArray *layersToFall = [NSArray arrayWithArray:self.shredderLayers];
    layersToFall = [layersToFall sortedArrayUsingComparator:^NSComparisonResult(CALayer *l1, CALayer *l2) {
        CGFloat vTranslation1 = [[l1 valueForKey:kYMCShredderVerticalTranslationKey] floatValue];
        CGFloat vTranslation2 = [[l2 valueForKey:kYMCShredderVerticalTranslationKey] floatValue];
        
        if (vTranslation1 < vTranslation2)
            return NSOrderedAscending;
        if (vTranslation1 > vTranslation2)
            return NSOrderedDescending;
        
        return NSOrderedSame;
    }];
    return layersToFall;
}

- (void)updateWithFallProgress:(CGFloat)progress {
    NSArray *layersToFall = [self sortedLayersToFall];
    [CATransaction setDisableActions:YES];
    for (CALayer *layer in layersToFall) {
        CGFloat vTranslation = [[layer valueForKey:kYMCShredderVerticalTranslationKey] floatValue];
        CGRect originFrame = [[layer valueForKey:kYMCShredderOriginalFrameKey] CGRectValue];
        
        CGFloat boostIndex = (self.maximumVerticalOffset - vTranslation)/5.0 + 1.0;
        
        CGRect targetFrame = originFrame;
        targetFrame.origin = CGPointMake(originFrame.origin.x,
                                         CGRectGetMaxY(originFrame) + (CGRectGetHeight(self.managedView.window.bounds)/2 - CGRectGetHeight(self.managedView.bounds)/2));
        CGRect middleFrame = originFrame;
        middleFrame.origin = CGPointMake(originFrame.origin.x * (progress) + targetFrame.origin.x * (1.0 - progress),
                                         originFrame.origin.y * (progress) + targetFrame.origin.y * (1.0 - progress) * boostIndex);
        layer.frame = middleFrame;
    }
    
    [self updateShredderMachineLayerWithValue:progress - 1.0];
}

- (void)setFallProgress:(CGFloat)fallProgress {
    if (self.value != 0.0) {
        NSLog(@"falls can be performed only when value == 0.0");
        _fallProgress = 0.0;
        return;
    }
    if (_fallProgress == fallProgress) {
        return;
    }
    _fallProgress = fallProgress;
    [self updateWithFallProgress:_fallProgress];
}

- (id)animationValueForKey:(NSString *)key sourceValue:(id)fromValue targetValue:(id)toValue forProgress:(CGFloat)progress {
    if ([key isEqualToString:@"fallProgress"]) {
        CGFloat from = [fromValue floatValue];
        CGFloat to = [toValue floatValue];
        CGFloat middle = from * progress + to * (1.0 - progress);
        return @(middle);
    }
    return [super animationValueForKey:key sourceValue:fromValue targetValue:toValue forProgress:progress];
}

@end
