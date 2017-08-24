###### 小牢骚
好久没有记录文章了,近期在学习前端的相关知识,也没有好好的静下心来整理东西,这次准备把之前自己用到的东西做一个总结,方便以后自己查阅.
 
###正文
这次记录使用CALayer创建一个环形进度条的view,加上简单的动画,项目中刚好有使用到。
效果图：
![porgressView.gif](http://upload-images.jianshu.io/upload_images/2203462-b354fa97e09dd7e2.gif?imageMogr2/auto-orient/strip)
要点： 主要使用layer的mask属性，mask属性可以让layer只显示遮罩层上面的路径（环形）

### 分析
在进度值为0的时候，有一个黄色的底色，然后进度条的颜色是渐变的，底色环形可以通过给view的layer添加一个带环形路径的CAShapeLayer作为mask,渐变色可以使用CAGrandientLayer创建一个渐变图层，然后创建一个带环形路径的CAShapeLayer,将其作为渐变图层的mask，这样就能达到预期的效果

### 相关知识点
- CAGradientLayer
 创建渐变色layer,他是继承自CALayer的一个用于绘制多色图层的子类，主要用于设置的属性值为
    -  @property(nullable, copy) NSArray *colors;
      设置需要加载的颜色数组（CGColorRef类型）
    -  @property(nullable, copy) NSArray<NSNumber *> *locations;
      不同颜色值的分布分割点（NSNumber类型）
    - @property CGPoint startPoint;
    - @property CGPoint endPoint;

具体的相关详细解析这里引用一篇文章:[CAGradientLayer详细使用](CAGradientLayer)
本文中使用到的只是简单的创建三个颜色值的图层
 ```
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
 ```
代码中的self.colors为包含UICololr的颜色数组，self.locations为包含NSNumber值的数组
颜色值设为@[COLOR(100, 150, 0, 1),COLOR(0, 150, 130, 1),COLOR(60, 0, 190, 1)];location设置为@[@0.1,0.5,0.9]，效果如下
![渐变色图层.png](http://upload-images.jianshu.io/upload_images/2203462-a061b89e06540d0e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
- CAShaprLayer 一个很强大的CALayer子类，由于其可以添加path路径，因此可以绘制出很多复杂的图形。这里也引用一篇之前看过的不错的博客：[关于CAShapeLayer和UIBzierPath的使用](http://www.cocoachina.com/ios/20160214/15251.html)
本文中主要使用CAShapeLayer创建一个环形路径的图层
```
#define DEGREES_TO_ANGLE(x) (M_PI * (x) / 180.0) // 将角度转为弧度
CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = self.bounds;
    
    UIBezierPath *path =  [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2) radius:self.bounds.size.width / 2.5 startAngle:DEGREES_TO_ANGLE(-90) endAngle:DEGREES_TO_ANGLE(270) clockwise:YES]; //注意这里的半径,应该为宽度1/2-linewidth/2
    layer.lineWidth = self.lineWidth; //线的宽度
    layer.path = path.CGPath;
    layer.fillColor = [UIColor clearColor].CGColor; //设置填充颜色
    layer.strokeColor = [UIColor blackColor].CGColor; // 设置画笔颜色
    layer.lineCap = kCALineCapRound; // 设置线为圆角
```
其中需要注意的点：
 - 这里的坐标系和数学中的坐标系是反的，简单的理解就是-90°等价数学坐标系中的90°，90°等价数学坐标系中的270°，所以如果希望进度条从顶部按照顺时针走，那么在设置UIBezierPath画圆弧的时候就应该为clockwise：yes(顺时针)，startangle(开始弧度)：(-90°对应的弧度)，endangle：(270°对应的弧度)，这样就是生成按照顺时针方向从-90°的点到270°的点之间的路径。
如下图片中不同的角度对应的效果图：
![多种弧度的圆弧.png](http://upload-images.jianshu.io/upload_images/2203462-e1aee6e4ee8cd594.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
 - 在选择半径时，如果fram宽度为100，希望绘制一个宽度20紧靠边缘的环形，那么半径应该是50-20/2，并不是50-20。

### 代码解析
progressView.h
```
typedef NS_ENUM (NSInteger, WJStrokeType)//动画方式
{
    WJStrokeTypeStart, //开始
    WJStrokeTypeEnd //结束
};
//动画结束回调
typedef void(^ProgressEnd)();

@interface WJProgressView : UIView
/**
 *  线宽
 */
@property(nonatomic,assign)CGFloat lineWidth;

/**
 *  背景颜色
 */
@property(nonatomic,strong)UIColor *bgColor;

/**
 *  渐变色颜色组
 */
@property(nonatomic,strong)NSArray *colors;

/**
 *  颜色分割位置数组
 */
@property(nonatomic,strong)NSArray *locations;

/**
 *  隐藏百分比label
 */
- (void)hidePercent;

/**
 *  设置创建图层
 */
- (void)startProress;

/**
 *  更新progress
 *
 *  @param value progress Value
 */
- (void)reloadValue:(CGFloat)value;

/**
 *  进度动画
 *
 *  @param beginValue 开始value
 *  @param endValue   结束value
 *  @param duration   动画持续时间
 *  @param type       动画类型
 *  @param endBlock   动画结束回调
 */
- (void)setprogressFromValue:(CGFloat)beginValue endValue:(CGFloat)endValue duration:(CGFloat)duration strokeType:(WJStrokeType)type end:(ProgressEnd)endBlock;
```

.m
```
- (void)setprogressFromValue:(CGFloat)beginValue endValue:(CGFloat)endValue duration:(CGFloat)time strokeType:(WJStrokeType)type end:(ProgressEnd)endBlock
{
    if (beginValue >= 1.0) {
        endBlock();
        return;
    }
    _endValue = endValue;
    self.animationEnd = endBlock;
    NSString *animationName = @"strokeStart";
    if (type) {
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

```
对于cCAShapeLayer，stokeEnd和strokestart属性都直接动画操作。
在动画过程中关于中间percentLabel的显示，使用定时器设置时间间隔实现变化。
```
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
```
注意点：dispatch_source_t 的创建定一个属性值来保存。不要直接在方法中创建。
在动画结束后对timer进行销毁处理。
```
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
```
End
简书地址 ： http://www.jianshu.com/p/cacf25171005
