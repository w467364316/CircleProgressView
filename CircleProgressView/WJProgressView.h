//
//  WJProgressView.h
//  CircleProgressView
//
//  Created by JianJian on 17/5/5.
//  Copyright © 2017年 WangJ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, WJStrokeType)//动画方式
{
    WJStrokeTypeStart, //开始
    WJStrokeTypeEnd //结束
};

typedef void(^ProgressEnd)();

@interface WJProgressView : UIView
/**
 *  线宽
 */
@property(nonatomic,assign)CGFloat lineWidth;

/**
 *  渐变色颜色组
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

/**
 *  隐藏百分比label
 */
- (void)hidePercentState:(BOOL)state;
@end
