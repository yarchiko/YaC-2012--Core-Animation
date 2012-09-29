//
//  YMCShredderMachineLayer.m
//  gesturedFold
//
//  Created by Vladislav Alekseev on 13.09.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import "YMCShredderMachineLayer.h"

@interface YMCShredderMachineLayer ()
@property (nonatomic, strong) CALayer *shredderImageLayer;
@property (nonatomic, strong) NSMutableArray *shredderCuts;
@property (nonatomic, readonly) NSUInteger numberOfCuts;
@end

@implementation YMCShredderMachineLayer

- (id)init
{
    self = [super init];
    if (self) {
        _numberOfLines = 15;
        
        [self configureEmitter];
        [self addSublayer:self.shredderImageLayer];
        [self setupCuts];
    }
    return self;
}

- (void)configureEmitter
{
    self.emitterShape = kCAEmitterLayerLine;
    self.emitterCells = @[[self emitterCellWithIndex:1], [self emitterCellWithIndex:2], [self emitterCellWithIndex:3]];
}

- (CAEmitterCell *)emitterCellWithIndex:(NSUInteger)index
{
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    cell.contents = (id)[[UIImage imageNamed:[NSString stringWithFormat:@"shredderCut%d.png", index]] CGImage];
    cell.birthRate = 1.0;
    cell.spinRange = 3*M_PI;
    cell.color = UIColor.whiteColor.CGColor;
    cell.yAcceleration = 5000.0;
    cell.speed = 25.0;
    cell.lifetime = 15.0;
    return cell;
}

#pragma mark - Overrides

- (CGSize)preferredFrameSize {
    return [UIImage imageNamed:@"Shredder.png"].size;
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    self.emitterPosition = CGPointMake(bounds.size.width/2.0, bounds.size.height + 1.0);
    self.emitterSize = bounds.size;
    
    self.shredderImageLayer.bounds = self.bounds;
    self.shredderImageLayer.position = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    
    [self layoutCutLayers];
}

- (void)setNumberOfLines:(NSUInteger)numberOfLines {
    if (_numberOfLines == numberOfLines) {
        return;
    }
    [_shredderCuts makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [_shredderCuts removeAllObjects];
    _numberOfLines = numberOfLines;
    [self setupCuts];
}

#pragma mark - Lazy

- (CALayer *)shredderImageLayer {
    if (_shredderImageLayer == nil) {
        _shredderImageLayer = [CALayer layer];
        _shredderImageLayer.bounds = self.bounds;
        _shredderImageLayer.position = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
        _shredderImageLayer.contents = (id)[UIImage imageNamed:@"Shredder.png"].CGImage;
    }
    return _shredderImageLayer;
}

- (NSMutableArray *)shredderCuts {
    if (_shredderCuts == nil) {
        _shredderCuts = [[NSMutableArray alloc] initWithCapacity:self.numberOfLines];
    }
    return _shredderCuts;
}

#pragma mark - Internal

- (NSUInteger)numberOfCuts {
    return self.numberOfLines + 1;
}

- (void)setupCuts {
    UIImage *cutImage = [UIImage imageNamed:@"ShredderScissor.png"];
    for (NSUInteger cutIndex = 1; cutIndex < self.numberOfCuts - 1; cutIndex++) {
        CALayer *cutLayer = [CALayer layer];
        cutLayer.anchorPoint = CGPointMake(0.5, 0.0);
        cutLayer.bounds = CGRectMake(0, 0, cutImage.size.width, cutImage.size.height);
        cutLayer.contents = (id)cutImage.CGImage;
        [self.shredderCuts addObject:cutLayer];
        [self addSublayer:cutLayer];
    }
}

- (void)layoutCutLayers {
    for (NSUInteger cutIndex = 1; cutIndex < self.numberOfCuts - 1; cutIndex++) {
        CALayer *cutLayer = [self.shredderCuts objectAtIndex:cutIndex - 1];
        CGFloat idx = cutIndex / (CGFloat)(self.numberOfCuts - 1);
        
        cutLayer.position = CGPointMake(CGRectGetWidth(self.bounds) * idx - 18 * (idx - 0.5),
                                        CGRectGetHeight(self.bounds) - 15);
    }
}

@end
