//
//  SunMBHubUtils.m
//  MBManager
//
//  Created by Feng on 2018/10/26.
//  Copyright © 2018年 Feng. All rights reserved.
//

#import "SunMBHubUtils.h"

#define kSunDefaultView     ([[UIApplication sharedApplication] keyWindow])
#define kSunBlackColor   ([UIColor colorWithRed:0 green:0 blue:0 alpha:0.5])
#define kSunClearColor  ([UIColor colorWithRed:1 green:1 blue:1 alpha:0])
#define kSunDelayHidden  (2.0)

@implementation SunMBHubUtils

UIView *hudBackView;             //背景
NSString *title;            //提示标题
NSString *imageName;        //图片名字
MBProgressHUDMode hudMode; //模式
UIView *prestrainView;     //父view
NSTimeInterval delay;     //延迟时长

#pragma mark -   类初始化
+(void)initialize {
    if (self == [SunMBHubUtils self]) {
        [self backView];
    }
}

#pragma mark --创建hudView背景view
+(void)backView { //意图控制maxSise 因为hud没有接口设置maxSize
    hudBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];//maxSize(300,200)
    hudBackView.backgroundColor = kSunClearColor ;
    hudBackView.hidden = YES;
}

#pragma mark --配置父view
+(void)backViewConfig {
    hudBackView.hidden = NO;
    if (prestrainView) {
        [prestrainView addSubview:hudBackView];
    }
    else{
        [kSunDefaultView addSubview:hudBackView];
        prestrainView = kSunDefaultView;
    }
    hudBackView.center = prestrainView.center;
}

#pragma mark --创建hub
+(void)showHud {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self backViewConfig];
        
        [UIActivityIndicatorView appearanceWhenContainedInInstancesOfClasses:@[[MBProgressHUD class]]].color = [UIColor whiteColor];//菊花颜色 放在创建之后，第一次会不生效，所以一定要先设置
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:hudBackView animated:YES];
        
        if (imageName != nil && ![imageName isEqualToString:@""]) {//MBProgressHUDModeCustomView模式下
            UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAutomatic];//自定义图片
            hud.customView = [[UIImageView alloc]initWithImage:image];;
            hud.square = YES;
        }
        
        hud.mode = hudMode; //模式 MBProgressHUDModeText模式时 模式设置一定要在前，否则字体颜色不生效
       
        hud.label.text = title; //内容
        hud.label.textColor = [UIColor whiteColor]; //颜色
        hud.label.font = [UIFont systemFontOfSize:12.0];//大小
        hud.label.numberOfLines = 0; //支持换行
        
        hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;//不固定
        hud.bezelView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0];//颜色
        hud.bezelView.alpha = 0.8;//透明度
        hud.bezelView.layer.cornerRadius = 5; //圆角值，
        hud.contentMode = UIViewContentModeCenter; //位置
        
        hud.animationType = MBProgressHUDAnimationZoomIn;//显示/隐藏动画模式
        hud.removeFromSuperViewOnHide = YES; //隐藏时移除hud
        hud.margin = 10.0f; //各个元素距离矩形边框的距离
        hud.minSize = CGSizeMake(100, 44);//最小值
        hud.square = NO;//hub 不等宽
        
        [hud showAnimated:NO];
        if (delay > 0) {
            [hud hideAnimated:NO afterDelay:delay];
        }
        hud.completionBlock = ^{ //这个回调 只对hideAnimated有效  hud.hidden = Yes或removeFromSuperview无效
            hudBackView.hidden = YES;
            [hudBackView removeFromSuperview];
        };
    });
}

#pragma mark --toast 文字
+(void)showToast:(NSString *)message {
    title = message;
    imageName = nil;
    hudMode = MBProgressHUDModeText;
    prestrainView = nil;
    delay = kSunDelayHidden;
    [self showHud];
}

#pragma mark --toast 文字+图片
+(void)showToast:(NSString *)message imageName:(NSString *)name {
    title = message;
    imageName = name;
    hudMode = MBProgressHUDModeText;
    prestrainView = nil;
    delay = kSunDelayHidden;
    [self showHud];
}

#pragma mark --toast 指定添加到固定的view上
+(void)showToast:(NSString *)message imageName:(NSString *)name view:(UIView *)view {
    title = message;
    imageName = name;
    hudMode = MBProgressHUDModeCustomView;
    prestrainView = view;
    delay = kSunDelayHidden;
    [self showHud];
}

#pragma mark --loading 只有菊花
+(void)showLoading {
    title = nil;
    imageName = nil;
    hudMode = MBProgressHUDModeIndeterminate;
    prestrainView = nil;
    delay = 0;
    [self showHud];
}

#pragma mark --loading 菊花+文字
+(void)showLoading:(NSString *)message {
    title = message;
    imageName = nil;
    hudMode = MBProgressHUDModeIndeterminate;
    prestrainView = nil;
    delay = 0;
    [self showHud];
}

#pragma mark --loading 指定添加到固定的view上
+(void)showLoading:(NSString *)message view:(UIView *)view {
    title = message;
    imageName = nil;
    hudMode = MBProgressHUDModeIndeterminate;
    prestrainView = view;
    delay = 0;
    [self showHud];
}

#pragma mark --隐藏loading
+(void)hiddenLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSEnumerator *subviewsEnum = [hudBackView.subviews reverseObjectEnumerator];
        for (UIView *subview in subviewsEnum) {
            if ([subview isKindOfClass:[MBProgressHUD class]]) {
               MBProgressHUD *hud = (MBProgressHUD *)subview;
                [hud hideAnimated:NO];
                [hud removeFromSuperview];
            }
        }
    });
}

#pragma mark --progress

                                  
                                  
@end

