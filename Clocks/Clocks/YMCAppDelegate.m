//
//  YMCAppDelegate.m
//  Clocks
//
//  Created by Vladislav Alekseev on 23.09.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import "YMCAppDelegate.h"

#import "YMCViewController.h"

@implementation YMCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[YMCViewController alloc] initWithNibName:@"YMCViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}
@end
