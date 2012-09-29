//
//  BFBatteryTimeView.h
//  Clocks
//
//  Created by Vladislav Alekseev on 10.08.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface YMCClockLayer : CALayer

+ (NSTimeInterval)animationDurationWithSourceTime:(NSTimeInterval)sourceTime targetTime:(NSTimeInterval)targetTime;

@property (nonatomic, assign) NSTimeInterval time;

@end
