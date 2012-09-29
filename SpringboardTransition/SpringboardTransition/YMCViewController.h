//
//  YMCViewController.h
//  SpringboardTransition
//
//  Created by Vladislav Alekseev on 13.09.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YMCViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *viewToUpdate;
- (IBAction)updateView:(id)sender;

@end
