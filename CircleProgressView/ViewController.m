//
//  ViewController.m
//  CircleProgressView
//
//  Created by JianJian-Mac on 17/5/5.
//  Copyright © 2017年 WangJ. All rights reserved.
//

#define COLOR(R,G,B,A)         [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
#define WIDTH         [UIScreen mainScreen].bounds.size.width
#define HEIGHT        [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"
#import "WJProgressView.h"

@interface ViewController ()
@property(nonatomic,strong)UISlider *sliderView;
@property(nonatomic,strong)WJProgressView *progress;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.progress = [[WJProgressView alloc] initWithFrame:CGRectMake(WIDTH/2 - 100, HEIGHT/2 - 100, 200, 200)];
//    self.progress.colors = @[COLOR(100, 150, 0, 1),COLOR(0, 150, 130, 1),COLOR(60, 0, 190, 1)];
    self.progress.lineWidth = 20;
//    self.progress.backgroundColor = [UIColor yellowColor];
    [self.progress startProress];
    
    [self.view addSubview: self.progress];
    
    self.sliderView = [[UISlider alloc] initWithFrame:CGRectMake(100, 100, WIDTH - 200, 50)];
    [self.sliderView addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.sliderView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 100, 100);
    [button setTitle:@"加载" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

- (void)sliderChanged:(UISlider *)slider {

    [self.progress reloadValue:slider.value];
}

- (void)buttonClicked:(UIButton *)button {
    
    static CGFloat endValue = 0.0f;
    
    [self.progress setprogressFromValue:endValue endValue:endValue + 0.1 duration:2.0 strokeType:1 end:^{
        NSLog(@"动画结束");
        endValue = endValue>=1.0?0.1f:endValue+0.1;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
