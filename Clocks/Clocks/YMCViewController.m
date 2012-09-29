//
//  YMCViewController.m
//  Clocks
//
//  Created by Vladislav Alekseev on 23.09.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import "YMCViewController.h"
#import "YMCClockLayer.h"

@implementation YMCViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    YMCClockLayer *timeview = [YMCClockLayer layer];
    timeview.frame = CGRectMake(20, 20, 200, 200);
    [self.view.layer addSublayer:timeview];
    
    timeview.time = 25200;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"time"];
    animation.toValue = @25200;
    animation.duration = [YMCClockLayer animationDurationWithSourceTime:0.0 targetTime:25200];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [timeview addAnimation:animation forKey:@"timeUpdateAnimation"];
}

@end
