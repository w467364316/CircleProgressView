//
//  WJViewController.m
//  CircleProgressView
//
//  Created by JianJian-Mac on 17/5/27.
//  Copyright © 2017年 WangJ. All rights reserved.
//
#define DEGREES_TO_ANGLE(x) (M_PI * (x) / 180.0) // 将角度转为弧度

#import "WJViewController.h"

@interface WJViewController ()

@end

@implementation WJViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = CGRectMake(100, 100, 200, 200);
    layer.borderWidth = 2;
    layer.borderColor = [UIColor blackColor].CGColor;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(100, 100) radius:100-10 startAngle:DEGREES_TO_ANGLE(90) endAngle:DEGREES_TO_ANGLE(180) clockwise:NO];
    layer.path = path.CGPath;
    layer.lineWidth = 20;
    layer.lineCap = kCALineCapRound;
    layer.fillColor = [UIColor redColor].CGColor;
    layer.strokeColor = [UIColor colorWithRed:138/255.0 green:220/255.0 blue:255.0 alpha:0.5].CGColor;
    [self.view.layer addSublayer:layer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
