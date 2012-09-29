//
//  YMCViewController.m
//  gesturedFold
//
//  Created by Vladislav Alexeev on 23.05.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import "YMCViewController.h"
#import "YMCShredderGesturedTransition.h"
#import "YMCFoldGesturedTransition.h"
#import "UIView+YMCShredderingAnimation.h"

@interface YMCViewController ()
@property (nonatomic, strong) YMCFoldGesturedTransition *foldTransition;
@end

@implementation YMCViewController
@synthesize viewToTransit = _viewToTransit;

- (void)viewDidLoad {
    [super viewDidLoad];
    

    NSString *pagePath = [[NSBundle mainBundle] pathForResource:@"webViewPage" ofType:@"html"];
	NSURL *pageURL = [NSURL fileURLWithPath:pagePath isDirectory:NO];
	[self.viewToTransit loadRequest:[NSURLRequest requestWithURL:pageURL]];
    
    self.foldTransition = [[YMCFoldGesturedTransition alloc] init];
    self.foldTransition.managedView = self.viewToTransit;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [pan requireGestureRecognizerToFail:tap];
    [self.view addGestureRecognizer:pan];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)sliderChanged:(UISlider *)sender {
    self.foldTransition.value = sender.value;
}

#pragma mark - Gesture Recognizers

- (void)tap:(UITapGestureRecognizer *)tapGR {
    [self.viewToTransit animateShredderingWithCompletionHandler:NULL];
}

- (void)pan:(UIPanGestureRecognizer *)panGR {
    
    switch (panGR.state) {
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [panGR translationInView:self.view];
            CGFloat value = self.foldTransition.value;
            CGFloat valueDiff = translation.y / CGRectGetHeight(self.view.frame);
            value += valueDiff;
            value = MAX(value, 0.0);
            value = MIN(1.0, value);
            self.foldTransition.value = value;
            [panGR setTranslation:CGPointZero inView:self.view];
        } break;
        case UIGestureRecognizerStateEnded: {
            CGFloat velocity = [panGR velocityInView:self.view].y;
            CGFloat location = [panGR locationInView:self.view].y;
            
            CGFloat distanceToComplete;
            if (velocity < 0.0) {
                distanceToComplete = location;
            }
            else {
                distanceToComplete = CGRectGetHeight(self.view.frame) - location;
            }
            
            NSTimeInterval timeToComplete = distanceToComplete / fabs(velocity);
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"value"];
            animation.duration = MIN(timeToComplete, 1.0);
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            animation.toValue = velocity < 0.0 ? @0.0 : @1.0;
            [self.foldTransition addAnimation:animation forKey:@"completionAnimation"];
        } break;
        default:
            break;
    }
}

@end
