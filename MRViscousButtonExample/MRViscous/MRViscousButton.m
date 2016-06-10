//
//  MRViscousButton.m
//  MRViscousButtonExample
//
//  Created by SinObjectC on 16/6/7.
//  Copyright © 2016年 SinObjectC. All rights reserved.
//

#import "MRViscousButton.h"

// 设置最大圆心距离
#define kMaxDistance 80

@interface MRViscousButton ()<MRViscousButtonDelegate>

/** 小圆 */
@property(nonatomic, strong)UIView *smallCircle;

/** 小圆原始半径 */
@property(nonatomic, assign)CGFloat oriSmallRadius;

/** 图形图层 */
@property(nonatomic, strong)CAShapeLayer *shapeLayer;

@end


@implementation MRViscousButton


#pragma mark - 懒加载
- (UIView *)smallCircle {
    
    if(!_smallCircle) {
        
        UIView *view = [[UIView alloc] init];
        
        view.backgroundColor = self.backgroundColor;
        
        _smallCircle = view;
        
        // 小圆添加按钮的父控件上
        [self.superview insertSubview:view belowSubview:self];
    }
    
    return _smallCircle;
}


- (CAShapeLayer *)shapeLayer {
    
    if(!_shapeLayer) {
        
        // 展示不规则矩形，通过不规则矩形路径生成一个不规则图层
        CAShapeLayer *layer = [CAShapeLayer layer];
        
        _shapeLayer = layer;
        
        layer.fillColor = self.backgroundColor.CGColor;
        
        // 将不规则图层插入到大圆的图层下面一层
        [self.superview.layer insertSublayer:layer below:self.layer];
    }
    
    return _shapeLayer;
}

- (NSArray *)images {
    
    if(!_images) {
        
        NSMutableArray *arrM = [NSMutableArray array];
        
        for (int i = 1; i < 9; i++) {
            
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d", i]];
            
            [arrM addObject:image];
        }
        
        _images = arrM;
    }
    
    return _images;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self setUp];
        
    }
    return self;
}


- (void)awakeFromNib {
    
    [self setUp];
    
}


#pragma mark - 初始化
- (void)setUp {
    
    // 取消父控件xib的自动布局
    self.superview.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGFloat h = self.bounds.size.height;
    
    // 记录小圆最初始半径
    self.oriSmallRadius = h / 2;
    
    self.layer.cornerRadius = h / 2;
    
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    
    // 添加拖动手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    
    [self addGestureRecognizer:pan];
    
    // 添加点击事件监听
    [self addTarget:self action:@selector(clicked) forControlEvents:UIControlEventTouchUpInside];

}


/**
 *	@brief	拖动手势事件
 */
- (void)pan:(UIPanGestureRecognizer *)pan {

    // 获取偏移量
    CGPoint transPoint = [pan translationInView:self];
    
    CGPoint centerPre = self.center;
    
    CGPoint centerNow = CGPointMake(centerPre.x + transPoint.x, centerPre.y + transPoint.y);
    
    self.center = centerNow;
    
    // 复位
    [pan setTranslation:CGPointZero inView:self];
    
    // 设置小圆的半径， 小圆的半径随着两个圆心的距离不断增加而减小
    // 计算圆心距离
    CGFloat d = [self circleCenterDistanceWithBigCircleCenter:self.center smallCircleCenter:self.smallCircle.center];
    
    // 计算小圆的半径
    CGFloat smallRadius = self.oriSmallRadius - d/6;
    
    // 设置小圆的尺寸
    self.smallCircle.bounds = CGRectMake(0, 0, smallRadius * 2, smallRadius * 2);
    
    self.smallCircle.layer.cornerRadius = smallRadius;
    
    // 描述不规则矩形
    // 当圆心距离大于最大圆心距离
    if(d > kMaxDistance) {  // 线被拉断, 圆可以拖出来
        
        // 隐藏小圆
        self.smallCircle.hidden = YES;
        
        // 移除不规则矩形
        [self.shapeLayer removeFromSuperlayer];
        
        self.shapeLayer = nil;
        
    }else if(d > 0 && self.smallCircle.hidden == NO) {  // 有圆心距离, 并且圆心距离没有超过最大, 展示不规则矩形
        
        // 展示不规则矩形，通过不规则矩形的路径生成一个图层
        self.shapeLayer.path = [self pathWithBigCircleView:self smallCircleView:self.smallCircle].CGPath;
        
    }
    
    //  手指抬起
    if(pan.state == UIGestureRecognizerStateEnded) {
    
        // 当圆心距离大于最大圆心距离, 大圆展示动画并且消失
        if(d > kMaxDistance) {
            
            [self dealEvent];
            
        }else { // 未超过最大距离
            
            // 移除不规则矩形
            [self.shapeLayer removeFromSuperlayer];
            
            self.shapeLayer = nil;
            
            // 还原位置
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.2 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
                
                //设置大圆中心点位置
                self.center = self.smallCircle.center;
        
            } completion:^(BOOL finished) {
                // 显示小圆
                self.smallCircle.hidden = NO;
            }];
        }
    }
}


/**
 *	@brief	根据两个圆的中心点得到中心点的距离
 *
 *	@param 	bigCircleCenter 	大圆中心点
 *	@param 	smallCircleCenter 	小圆中心点
 *
 *	@return	间距
 */
- (CGFloat)circleCenterDistanceWithBigCircleCenter:(CGPoint)bigCircleCenter smallCircleCenter:(CGPoint)smallCircleCenter
{
    
    CGFloat offsetX = bigCircleCenter.x - smallCircleCenter.x;
    
    CGFloat offsetY = bigCircleCenter.y - smallCircleCenter.y;
    
    return sqrt(offsetX * offsetX + offsetY * offsetY);
}


/**
 *	@brief	描述两个圆中间的一条矩形路径
 */
- (UIBezierPath *)pathWithBigCircleView:(UIView *)bigCircleView smallCircleView:(UIView *)smallCircleView
 {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGPoint bigCenter = bigCircleView.center;
    
    CGFloat x2 = bigCenter.x;
    
    CGFloat y2 = bigCenter.y;
    
    CGFloat r2 = bigCircleView.bounds.size.height / 2;
    
    CGPoint smallCenter = smallCircleView.center;
    
    CGFloat x1 = smallCenter.x;
    
    CGFloat y1 = smallCenter.y;
    
    CGFloat r1 = smallCircleView.bounds.size.height / 2;
    
    // 获取两圆心的间距
    CGFloat d = [self circleCenterDistanceWithBigCircleCenter:bigCenter smallCircleCenter:smallCenter];
    
    CGFloat cosΘ = (y2-y1) / d;
    
    CGFloat sinΘ = (x2-x1) / d;
    
    // 不规则图形基于父控件的坐标系
    CGPoint pointA = CGPointMake(x1 - r1 * cosΘ, y1 + r1 * sinΘ);
     
    CGPoint pointB = CGPointMake(x1 + r1 * cosΘ, y1 - r1 * sinΘ);
     
    CGPoint pointC = CGPointMake(x2 + r2 * cosΘ, y2 - r2 * sinΘ);
     
    CGPoint pointD = CGPointMake(x2 - r2 * cosΘ, y2 + r2 * sinΘ);
     
    CGPoint pointO = CGPointMake(pointA.x + d / 2 * sinΘ, pointA.y + d / 2 * cosΘ);
     
    CGPoint pointP = CGPointMake(pointB.x + d / 2 * sinΘ, pointB.y + d / 2 * cosΘ);
    
    // 描绘路径: A
    [path moveToPoint:pointA];
    
    // AB
    [path addLineToPoint:pointB];
    
    // 绘制BC曲线
    [path addQuadCurveToPoint:pointC controlPoint:pointP];
    
    // CD
    [path addLineToPoint:pointD];
    
    // 绘制DA曲线
    [path addQuadCurveToPoint:pointA controlPoint:pointO];
    
    return path;
    
}

#pragma mark - button消失动画
- (void)startDestroyAnimations {
    
    UIImageView *ainmImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    
    ainmImageView.animationImages = self.images;
    
    ainmImageView.animationRepeatCount = 1;
    
    ainmImageView.animationDuration = 0.5;
    
    [ainmImageView startAnimating];
    
    [self addSubview:ainmImageView];
}


/**
 *	@brief	在父控件addSubview时调用
 */
- (void)didMoveToSuperview {
    
    [super didMoveToSuperview];
    
    // 设置小圆的位置和尺寸
    self.smallCircle.center = self.center;
    
    self.smallCircle.bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.height);
    
    self.smallCircle.layer.cornerRadius = self.bounds.size.height / 2;

}


/**
 *	@brief	粘性按钮即将消失
 */
- (void)clicked {

    // 移除小圆
    [self.smallCircle removeFromSuperview];
    
    [self dealEvent];
    
    // 移除不规则矩形
    [self.shapeLayer removeFromSuperlayer];
    
    self.shapeLayer = nil;
    
}

/**
 *	@brief	事件处理
 */
- (void)dealEvent {

    // 显示gif动画
    [self startDestroyAnimations];
    
    // 动画完成之后, 从父控件中移除
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self removeFromSuperview];
        
        // 调用代理方法
        if([self.delegate respondsToSelector:@selector(viscousButtonDismissed:)]) {
            
            // 调用回调方法
            [self.delegate viscousButtonDismissed:self];
        }
    });

}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
