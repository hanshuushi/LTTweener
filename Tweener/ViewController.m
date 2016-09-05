//
//  ViewController.m
//  Tweener
//
//  Created by Latte on 16/9/5.
//  Copyright © 2016年 舟弛 范. All rights reserved.
//

#import "ViewController.h"
#import "LTTweener.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIView *yellowBlock = [self.view.subviews objectAtIndex:0];
    
    [[LTTweener tweenerCardInWithTarget:yellowBlock.layer] start];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UIView *yellowBlock = [self.view.subviews objectAtIndex:0];
    
    [[LTTweener tweenerCardOutWithTarget:yellowBlock.layer] start];
}
@end
