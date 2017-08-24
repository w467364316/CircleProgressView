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

#define DEGREES_TO_ANGLE(x)         (M_PI * (x) / 180.0) // 将角度转为弧度
#define DEFALUTLINEWIDTH            20      //path默认宽度为20

#import "WJProgressView.h"

@interface WJProgressView ()<CAAnimationDelegate>
{
    CGFloat _endValue;
    BOOL hiddenLabel;
}

@property(nonatomic,strong)CAGradientLayer *colorLayer;
@property(nonatomic,strong)CAShapeLayer *bgMaskLayer;
@property(nonatomic,strong)CAShapeLayer *colorMaskLayer;
@property(nonatomic,strong)UIView *contenView;
@property(nonatomic,strong)UILabel *centerLabel;
@property(nonatomic,strong) dispatch_source_t timer;

@property(nonatomic,copy) ProgressEnd animationEnd;

@end

@implementation WJProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    
    if (self = [super initWithFrame:frame]) {
        //设置默认颜色
        self.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
        self.contenView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:self.contenView];
    }
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
//    [super setBackgroundColor:backgroundColor];
    self.contenView.backgroundColor = backgroundColor;
}

- (CGFloat)lineWidth
{
    if (!_lineWidth) _lineWidth = DEFALUTLINEWIDTH;
    return _lineWidth;
}
#pragma mark - privateMethods
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
    
//    CAShapeLayer *layer = [CAShapeLayer layer];
//    layer.frame = self.bounds;
//    layer.fillRule = kCAFillRuleEvenOdd;
//    
//    CGFloat radius = self.frame.size.width /2;
//    CGFloat otherRadius = radius - lineWidth;
//    CGPoint center = CGPointMake(self.bounds.size.width/2, self.frame.size.height/2);
//    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:DEGREES_TO_ANGLE(-90) endAngle:DEGREES_TO_ANGLE(270) clockwise:YES];
//    UIBezierPath *otherpath = [UIBezierPath bezierPathWithArcCenter:center radius:otherRadius startAngle:DEGREES_TO_ANGLE(-90) endAngle:DEGREES_TO_ANGLE(270) clockwise:YES];
//    [path appendPath:otherpath];
//    layer.fillColor = [UIColor blackColor].CGColor;
//    layer.path = path.CGPath;
//    return layer;
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = self.bounds;
    
    CGFloat radius = self.frame.size.width/2 - lineWidth /2;
    UIBezierPath *path =  [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2) radius:radius startAngle:DEGREES_TO_ANGLE(-90) endAngle:DEGREES_TO_ANGLE(270) clockwise:YES]; //注意这里的半径,应该为宽度1/2-linewidth/2
    layer.lineWidth = self.lineWidth;
    layer.fillRule = kCAFillRuleEvenOdd;
    layer.path = path.CGPath;
    layer.fillColor = [UIColor clearColor].CGColor; //设置填充颜色
    layer.strokeColor = [UIColor blackColor].CGColor; // 设置画笔颜色
    layer.lineCap = kCALineCapRound; // 设置线为圆角
    return layer;
}

/**
 创建定时器在layer animation过程中改变percent

 @param beginValue 初始值
 @param endValue 结束值
 @param time 时间间隔
 */
- (void)creatTimerFromValue:(CGFloat)beginValue endValue:(CGFloat)endValue duration:(CGFloat)time
{
    __block CGFloat beginPercent = beginValue;
    CGFloat timeInterval = 0.1;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.timer, dispatch_walltime(NULL, 0), timeInterval*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CGFloat difference = endValue - beginValue;
            CGFloat addValue = difference/time/(1/timeInterval);
            beginPercent += addValue;
            if (beginPercent >= endValue)  beginPercent = endValue;
            if (beginPercent >= 1.0)  beginPercent = 1.0f;
            [self reloadPercentLabelValue:beginPercent];
        });
    });
    dispatch_resume(_timer);
}

- (void)reloadPercentLabelValue:(CGFloat)value
{
    if (value >= 1.0) {
        value = 1.0;
    }
    if (value <= 0.001f) {
        value = 0;
    }
    self.centerLabel.text = [NSString stringWithFormat:@"%.f%%",value * 100];;
}

#pragma mark - animationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.animationEnd) self.animationEnd();
    [self.colorMaskLayer removeAnimationForKey:@"strokeAnimation"];
    self.colorMaskLayer.strokeEnd = _endValue;
    if (self.timer) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
}

#pragma mark - publicMethods
- (void)startProress
{
    //添加第一个遮罩，用于显示背景色
    self.bgMaskLayer = [self creatMaskLayerWithLineWidth:self.lineWidth];
    self.contenView.layer.mask = self.bgMaskLayer;
//    self.layer.mask = self.bgMaskLayer;
//    [self.layer addSublayer:self.bgMaskLayer];
    
    //添加gradientlayer遮罩
    self.colorLayer = [self creatGradientLayer];
    self.colorMaskLayer = [self creatMaskLayerWithLineWidth:self.lineWidth];
    self.colorLayer.mask = self.colorMaskLayer;
    self.colorMaskLayer.strokeEnd = 0.001f;
    
    [self.contenView.layer addSublayer:self.colorLayer];
    
    CGFloat width = CGRectGetWidth(self.frame) - self.lineWidth *2;
    self.centerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    self.centerLabel.center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetWidth(self.frame)/2);
    self.centerLabel.font = [UIFont systemFontOfSize:20];
    self.centerLabel.textAlignment = NSTextAlignmentCenter;
    self.centerLabel.hidden = hiddenLabel;
    [self reloadPercentLabelValue:0.001f];
    [self addSubview:self.centerLabel];
}

- (void)hidePercentState:(BOOL)state
{
    self.centerLabel.hidden = state;
}

- (void)reloadValue:(CGFloat)value
{
    if (value <= 0.001) {
        value = 0.01;
    }
    self.colorMaskLayer.strokeStart = 0.0f;
    self.colorMaskLayer.strokeEnd = value;
    [self reloadPercentLabelValue:value];
}

- (void)setprogressFromValue:(CGFloat)beginValue endValue:(CGFloat)endValue duration:(CGFloat)time strokeType:(WJStrokeType)type end:(ProgressEnd)endBlock
{
    if (beginValue >= 1.0) {
        endBlock();
        return;
    }
    
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
    
    [self creatTimerFromValue:beginValue endValue:endValue duration:time];
}

@end
