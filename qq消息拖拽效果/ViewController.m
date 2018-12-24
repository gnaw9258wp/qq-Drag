//
//  ViewController.m
//  qq消息拖拽效果
//
//  Created by wp on 2018/12/20.
//  Copyright © 2018年 wp. All rights reserved.
//

#import "ViewController.h"

/*
 拆分:
 1: 2个圆
 2:贝塞尔曲线画形状
 3:拖动时候 固定的圆的比例是缩小的
 4:到一定距离的时候会断开
 5:松开手势会回弹到原地
 
 */
@interface ViewController ()
@property (nonatomic,strong)UIView *view1;
@property (nonatomic,strong)UIView *view2;
@property (nonatomic,strong)CAShapeLayer *shapeLayer;
@property (nonatomic,assign)CGPoint oldView1Center;
@property (nonatomic,assign)CGRect oldView1Frame;
@property (nonatomic,assign)CGFloat view1R;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)setUp{
    UIView *view1 = [[UIView alloc]initWithFrame:CGRectMake(36, self.view.frame.size.height - 66, 40, 40)];
    view1.backgroundColor = [UIColor redColor];
    view1.layer.cornerRadius = 20;
    view1.layer.masksToBounds = YES;
    _view1 = view1;
    [self.view addSubview:view1];
    
    UIView *view2 = [[UIView alloc]initWithFrame:view1.frame];
    view2.backgroundColor = [UIColor redColor];
    view2.layer.cornerRadius = 20;
    view2.layer.masksToBounds = YES;
    _view2 = view2;
    [self.view addSubview:view2];
    
    UILabel *label = [[UILabel alloc]initWithFrame:_view2.bounds];
    label.text = @"99+";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [_view2 addSubview:label];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
    [_view2 addGestureRecognizer:pan];
    
    //实例化lshapeLayer
    CAShapeLayer *shapLayer = [CAShapeLayer layer];
    self.shapeLayer = shapLayer;
    self.shapeLayer.fillColor = [UIColor redColor].CGColor;

    self.oldView1Frame = self.view1.frame;
    self.oldView1Center = self.view1.center;
    self.view1R = self.view1.frame.size.width*0.5;
}

- (void)panAction:(UIPanGestureRecognizer *)ges{
    if (ges.state == UIGestureRecognizerStateChanged) {
        //view2跟着移动
        _view2.center = [ges locationInView:self.view];
        //计算出6个点 画出贝塞尔曲线
        if (self.view1R < 5) {
            self.view1.hidden = YES;
            [_shapeLayer removeFromSuperlayer];
        }else{
            [self calutePoint];
        }
    }else if (ges.state == UIGestureRecognizerStateFailed || ges.state == UIGestureRecognizerStateEnded || ges.state == UIGestureRecognizerStateCancelled){
        [_shapeLayer removeFromSuperlayer];
        self.view1.hidden = NO;
        [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:.3 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.view2.center = self.oldView1Center;
            self.view1R = self.oldView1Frame.size.width/2;
            self.view1.frame = self.oldView1Frame;
            self.view1.layer.cornerRadius = self.view1R;
        } completion:^(BOOL finished) {

        }];
    }
}

- (void)calutePoint{
    //1 求出2个中心点
    CGPoint center1 = self.view1.center;
    CGPoint center2 = self.view2.center;
    //2 求出2个中心点的距离
    CGFloat dis = sqrtf((center1.x - center2.x)*(center1.x - center2.x) + (center1.y - center2.y)*(center1.y - center2.y));
    
    //3 计算正弦余弦
    CGFloat sin = (center2.x - center1.x)/dis;
    CGFloat cos = (center2.y - center1.y)/dis;
    //计算半径
//    CGFloat r1 = self.view1.frame.size.width*0.5;
    //为了增加拖拽距离越远,view1的半径x越小,所以r1不应该是不变的,所以增加了一个dis/20,但是这个额dis/20可以根据需求改变个和控制
    CGFloat r1 = self.oldView1Frame.size.width*0.5 - dis/20;
    CGFloat r2 = self.view2.frame.size.width*0.5;
    NSLog(@"%f",r1);
    self.view1R = r1;
    //计算6个点
    CGPoint pA = CGPointMake(center1.x - r1*cos,center1.y + r1*sin);
    CGPoint pB = CGPointMake(center1.x + r1*cos,center1.y - r1*sin);
    CGPoint pC = CGPointMake(center2.x + r2*cos, center2.y - r2*sin);
    CGPoint pD = CGPointMake(center2.x - r2*cos, center2.y + r2*sin);
    
    CGPoint pP = CGPointMake(pA.x + dis/2*sin, pA.y + dis/2*cos);
    CGPoint pO = CGPointMake(pB.x + dis/2*sin, pB.y + dis/2*cos);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:pA];
    [path addQuadCurveToPoint:pD controlPoint:pP];
    [path addLineToPoint:pC];
    [path addQuadCurveToPoint:pB controlPoint:pO];
    [path closePath];
    self.shapeLayer.path = path.CGPath;
    [self.view.layer insertSublayer:self.shapeLayer below:self.view2.layer];
    
    //重新设置view的大小
    self.view1.bounds = CGRectMake(0, 0, r1*2, r1*2);
    self.view1.center = self.oldView1Center;
    self.view1.layer.cornerRadius = r1;
    self.view1.layer.masksToBounds = YES;
    
}
@end
