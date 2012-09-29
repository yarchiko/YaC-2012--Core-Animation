//
//  MPAnimation.h
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/10/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//  https://github.com/mpospese/AntiAliasingDemo/blob/master/AntiAliasingDemo/MPAnimation.h
//

#import <Foundation/Foundation.h>

@interface MPViewRendering : NSObject

+ (UIImage *)renderImageFromView:(UIView *)view;
+ (UIImage *)renderImageFromView:(UIView *)view withRect:(CGRect)frame;
+ (UIImage *)renderImageFromView:(UIView *)view withRect:(CGRect)frame transparentInsets:(UIEdgeInsets)insets;
+ (UIImage *)renderImageForAntialiasing:(UIImage *)image withInsets:(UIEdgeInsets)insets;
+ (UIImage *)renderImageForAntialiasing:(UIImage *)image;

@end
