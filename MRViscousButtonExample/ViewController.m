//
//  ViewController.m
//  MRViscousButtonExample
//
//  Created by SinObjectC on 16/6/7.
//  Copyright © 2016年 SinObjectC. All rights reserved.
//

#import "ViewController.h"
#import "MRViscousButton.h"

@interface ViewController ()<MRViscousButtonDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    MRViscousButton *btn = [[MRViscousButton alloc] initWithFrame:CGRectMake(100, 150, 30, 30)];
    
    // 设置代理
    btn.delegate = self;
    
    [btn setTitle:@"24" forState:UIControlStateNormal];
    
    [btn setBackgroundColor:[UIColor redColor]];
    
    [self.view  addSubview:btn];
    
    // 设置动画图片
    NSMutableArray *arrM = [NSMutableArray array];
    
    for (int i = 1; i < 9; i++) {
        
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d", i]];
        
        [arrM addObject:image];
    }
    
    btn.images = arrM;
    
}


# pragma mark - <MRViscousButtonDelegate>
- (void)viscousButtonDismissed:(MRViscousButton *)btn {
    
    NSLog(@"%@ - 代理回调方法", btn);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
