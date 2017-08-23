//
//  WJProgressView.m
//  CircleProgressView
//
//  Created by JianJian on 17/5/5.
//  Copyright © 2017年 WangJ. All rights reserved.
//

/* 目标:
 1.生成默认简单的进度条显示
 2.生成渐变颜色的进度条展示
 3.支持手动拖动进度显示
 4.动画设定进度条显示
 5.尽量简单易懂
 6.动画的回弹效果
 */

#define DEGREES_TO_ANGLE(x) (M_PI * (x) / 180.0) // 将角度转为弧度

#import "WJProgressView.h"

@interface WJProgressView ()<CAAnimationDelegate>
{
    CGFloat _endValue;
}

@property(nonatomic,strong)CAGradientLayer *colorLayer;
@property(nonatomic,strong)CAShapeLayer *bgMaskLayer;
@property(nonatomic,strong)CAShapeLayer *colorMaskLayer;
@property(nonatomic,copy) ProgressEnd animationEnd;

@end

@implementation WJProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    
    if (self = [super initWithFrame:frame]) {
        //设置默认颜色
        self.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    }
    return self;
}

- (void)startProress
{
    
    self.bgMaskLayer = [self creatMaskLayerWithLineWidth:self.lineWidth];
//    self.layer.mask = self.bgMaskLayer;
    
    self.colorLayer = [self creatGradientLayer];
    self.colorMaskLayer = [self creatMaskLayerWithLineWidth:self.lineWidth];
//    self.colorLayer.mask = self.colorMaskLayer;
//    self.colorMaskLayer.strokeEnd = 0.01;
    
    [self.layer addSublayer:self.colorLayer];
}

/**
 *  创建渐变色layer
 *
 *  @return CAGradientLayer
 */
- (CAGradientLayer *)creatGradientLayer
{
    
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = self.bounds;
    NSMutableArray *muColors = [NSMutableArray array];//颜色数组，放置CGColorref
    if (self.colors) {
        [self.colors enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[UIColor class]]) {
                UIColor *color = (UIColor *)obj;
                [muColors addObject:(id)color.CGColor];
            }
        }];
    }else {
        //设置两组白色
        [muColors addObject:(id)[UIColor whiteColor].CGColor];
        [muColors addObject:(id)[UIColor whiteColor].CGColor];
    }
    layer.colors = muColors;
    
    if (!self.locations) {
        //随便设置两组分割点
        self.locations = [NSMutableArray arrayWithObjects:@0.1, @0.9,nil];
    }
    layer.locations = self.locations;
    
    return layer;
}

/**
 *  设置遮罩layer
 *
 *  @param lineWidth 划线宽度
 *
 *  @return CAShapLayer
 */
- (CAShapeLayer *)creatMaskLayerWithLineWidth:(CGFloat)lineWidth
{
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = self.bounds;
    
    UIBezierPath *path =  [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2) radius:self.bounds.size.width / 2.5 startAngle:DEGREES_TO_ANGLE(-90) endAngle:DEGREES_TO_ANGLE(270) clockwise:YES]; //注意这里的半径,应该为宽度1/2-linewidth/2
    layer.lineWidth = self.lineWidth;
    layer.path = path.CGPath;
    layer.fillColor = [UIColor clearColor].CGColor; //设置填充颜色
    layer.strokeColor = [UIColor blackColor].CGColor; // 设置画笔颜色
    layer.lineCap = kCALineCapRound; // 设置线为圆角
    return layer;
}

- (void)hidePercent
{

    
}

- (void)reloadValue:(CGFloat)value
{

    if (value <= 0.001) {
        value = 0.01;
    }
    self.colorMaskLayer.strokeStart = 0.0f;
    self.colorMaskLayer.strokeEnd = value;
}

- (void)setprogressFromValue:(CGFloat)beginValue endValue:(CGFloat)endValue duration:(CGFloat)time strokeType:(WJStrokeType)type end:(ProgressEnd)endBlock{
    
    _endValue = endValue;
    self.animationEnd = endBlock;
    NSString *animationName = @"strokeStart";
    if (type != 0) {
        animationName = @"strokeEnd";
    }
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:animationName];
    pathAnimation.duration = time;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnimation.fromValue = [NSNumber numberWithFloat:beginValue];
    pathAnimation.toValue = [NSNumber numberWithFloat:endValue];
    pathAnimation.autoreverses = NO;
    pathAnimation.delegate = self;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.fillMode = kCAFillModeForwards;
    [self.colorMaskLayer addAnimation:pathAnimation forKey:@"strokeAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    self.animationEnd();
    [self.colorMaskLayer removeAnimationForKey:@"strokeAnimation"];
    self.colorMaskLayer.strokeEnd = _endValue;
}

@end
