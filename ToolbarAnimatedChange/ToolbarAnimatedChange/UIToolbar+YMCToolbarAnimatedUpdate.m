//
//  UIToolbar+YMCToolbarAnimatedUpdate.m
//  ToolbarAnimatedChange
//
//  Created by Vladislav Alekseev on 10.09.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import "MPViewRendering.h"
#import <QuartzCore/QuartzCore.h>
#import "UIToolbar+YMCToolbarAnimatedUpdate.h"

@implementation UIToolbar (YMCToolbarAnimatedUpdate)

- (void)rotateToolbarUpdatingWithBlock:(dispatch_block_t)block direction:(BOOL)rotateUp {
    UIImage *sourceImage = [MPViewRendering renderImageFromView:self];
    sourceImage = [MPViewRendering renderImageForAntialiasing:sourceImage withInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
    block();
    UIImage *targetImage = [MPViewRendering renderImageFromView:self];
    targetImage = [MPViewRendering renderImageForAntialiasing:targetImage withInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
    self.hidden = YES;
    
    CATransform3D notModifiedTransform = CATransform3DIdentity;
    notModifiedTransform.m34 = -1.0/500.0;
    
    CATransform3D bottomTransform = CATransform3DIdentity;
    bottomTransform = CATransform3DTranslate(bottomTransform, 0.0, targetImage.size.height/2.0, -targetImage.size.height/2.0);
    bottomTransform = CATransform3DRotate(bottomTransform, -M_PI_2, 1.0, 0.0, 0.0);
    
    CATransform3D topTransform = CATransform3DIdentity;
    topTransform = CATransform3DTranslate(topTransform, 0.0, -sourceImage.size.height/2.0, -sourceImage.size.height/2.0);
    topTransform = CATransform3DRotate(topTransform, M_PI_2, 1.0, 0.0, 0.0);
    
    CALayer *parentLayer = [CATransformLayer layer];
    parentLayer.frame = self.frame;
    [self.superview.layer addSublayer:parentLayer];
    
    CALayer *placeholderSourceLayer = [CALayer layer];
    placeholderSourceLayer.contents = (id)sourceImage.CGImage;
    placeholderSourceLayer.contentsGravity = kCAGravityResize;
    placeholderSourceLayer.contentsScale = self.contentScaleFactor;
    placeholderSourceLayer.frame = parentLayer.bounds;
    [parentLayer addSublayer:placeholderSourceLayer];
    
    CALayer *placeholderTargetLayer = [CALayer layer];
    placeholderTargetLayer.contents = (id)targetImage.CGImage;
    placeholderTargetLayer.contentsGravity = kCAGravityResize;
    placeholderTargetLayer.frame = parentLayer.bounds;
    [parentLayer addSublayer:placeholderTargetLayer];
    placeholderTargetLayer.transform = rotateUp ? bottomTransform : topTransform;
    
    NSTimeInterval duration = 0.25;
    
    CABasicAnimation *parentLayerAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    parentLayerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    parentLayerAnimation.fromValue = (id)[NSValue valueWithCATransform3D:notModifiedTransform];
    parentLayerAnimation.toValue = (id)[NSValue valueWithCATransform3D: rotateUp ? topTransform : bottomTransform];
    parentLayerAnimation.duration = duration;
    [parentLayer addAnimation:parentLayerAnimation forKey:@"rotateAnimation"];
    parentLayer.transform = topTransform;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.hidden = NO;
        [placeholderTargetLayer removeFromSuperlayer];
        [placeholderSourceLayer removeFromSuperlayer];
        [parentLayer removeFromSuperlayer];
    });
}

@end
