//
//  SunMBHubUtils.h
//  MBManager
//
//  Created by Feng on 2018/10/26.
//  Copyright © 2018年 Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface SunMBHubUtils : NSObject


#pragma mark --toast提示

/**
 * 只显示文字
 * @ param   message :显示文字
 * @ return  nil
 */
+(void)showToast:(NSString *)message;

/**
 * 文字 + 图片
 * @ param   message :显示文字
 * @ param   name :图片名字
 * @ return  nil
 */
+(void)showToast:(NSString *)message imageName:(NSString *)name;


/**
 * 文字 + 图片
 * @ param   message :显示文字
 * @ param   imageName :图片名字
 * @ param   view :提示添加到view上 nil为空时 直接添加到 [[UIApplication sharedApplication] keyWindow]上
 * @ return  nil
 */
+(void)showToast:(NSString *)message imageName:(NSString *)name view:(UIView *)view;


#pragma mark --loading加载图

/**
 * 加载图（默认) + 长久显示((调用hiddenLoading方法隐藏))
 * @ return  nil
 */
+(void)showLoading;

/**
 * 文字 + 加载图（默认） + 长久显示((调用hiddenLoading方法隐藏))
 * @ param   message :显示文字
 * @ return  nil
 */
+(void)showLoading:(NSString *)message;

/**
 * 文字 + 加载图（默认） + 长久显示((调用hiddenLoading方法隐藏))
 * @ param   message :显示文字
 * @ param   view :提示添加到view上 nil为空时 直接添加到 [[UIApplication sharedApplication] keyWindow]上
 * @ return  nil
 */
+(void)showLoading:(NSString *)message view:(UIView *)view;

/**
 * 隐藏loading
 * @ param  nil
 * @ return  nil
 */
+(void)hiddenLoading;



#pragma mark --进度条Progress（TODO://）



@end

NS_ASSUME_NONNULL_END
