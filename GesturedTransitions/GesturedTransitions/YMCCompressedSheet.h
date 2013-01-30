//
//  YMCCompressedSheet.h
//  GesturedTransitions
//
//  Created by beefon on 30.01.13.
//  Copyright (c) 2013 Yandex Mobile Camp. All rights reserved.
//

#import "YMCGesturedTransition.h"

extern NSUInteger const YMCCompressedSheetDefaultLayersCount;
extern CGFloat const YMCCompressedSheetDefaultCurlHeight;

@interface YMCCompressedSheet : YMCGesturedTransition

@property (nonatomic, assign) NSUInteger numberOfLayers;    // defaults to YMCCompressedSheetDefaultLayersCount
@property (nonatomic, assign) CGFloat curlHeight;       // defaults to YMCCompressedSheetDefaultCurlHeight

@end
