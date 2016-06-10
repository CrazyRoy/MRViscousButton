//
//  MRViscousButton.h
//  MRViscousButtonExample
//
//  Created by SinObjectC on 16/6/7.
//  Copyright © 2016年 SinObjectC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRViscousButtonDelegate;

@interface MRViscousButton : UIButton

/** 代理 */
@property(nonatomic, weak) id<MRViscousButtonDelegate> delegate;

/** 动画图片数组 */
@property(nonatomic, strong)NSArray *images;

@end

@protocol MRViscousButtonDelegate <NSObject>

@optional


/**
 *	@brief	当粘性按钮消失时的回调方法
 */
- (void)viscousButtonDismissed:(MRViscousButton *)btn;


@end
