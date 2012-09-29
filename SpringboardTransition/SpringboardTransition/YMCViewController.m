//
//  YMCViewController.m
//  SpringboardTransition
//
//  Created by Vladislav Alekseev on 13.09.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import "YMCViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+YMCSpringboardTransition.h"

@interface YMCViewController ()

@end

@implementation YMCViewController

- (void)animateCameraMove {
    CATransform3D t = CATransform3DIdentity;
    t.m34 = -1.0/800.0;
    t = CATransform3DRotate(t, -M_PI_2/90*80, 1.0, 0.0, 0.0);
    t = CATransform3DScale(t, 0.75, 0.75, 0.75);
    
    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"sublayerTransform"];
    ani.fromValue = [NSValue valueWithCATransform3D:t];
    ani.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    ani.duration = 10.0;
    [self.view.layer addAnimation:ani forKey:@"sublayerTransformAni"];
    [self updateView:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    [self animateCameraMove];
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(updateView:) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)updateView:(id)sender {
    static BOOL updated = NO;
    [self.viewToUpdate updateViewWithSpringboardTransitionUsingBlock:^{
        if (updated) {
            self.viewToUpdate.backgroundColor = [UIColor redColor];
        }
        else {
            self.viewToUpdate.backgroundColor = [UIColor blueColor];
        }
        updated = !updated;
    } duration:0.75];
}

@end
