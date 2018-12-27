//
//  SunAlertUtils.h
//  MBManager
//
//  Created by Feng on 2018/11/1.
//  Copyright © 2018年 Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SunAlertUtils : NSObject

/*
 * buttonIndex:otherButton的index按照传入otherButtonTitleArry的顺序
 * 默认的
 *
 */
typedef void (^sunAlertActionBlock) (UIAlertAction * action,NSInteger buttonIndex);


#pragma mark --提示+按钮#pragma mark --提示+一个输入框+按钮（取消+确认）

/**
 * Alter提示 提示+确认按钮
 * @ param  title 标题
 * @ param  message 信息
 * @ param  sureTitle 按钮title
 * @ param  sunAlertActionBlock 按钮handler
 * @ return  UIAlertController (alert.textFields,alert.actions)
 */
+(UIAlertController *)showAlert:(NSString *)title
         message:(NSString *)message
       sureTitle:(NSString *)sureTitle
     completionBlock:(sunAlertActionBlock)completionBlock
      parentVc:(UIViewController *)parentVc;

/**
 * Alter提示 提示+2个按钮（确认和取消）
 * @ param  title 标题
 * @ param  message 信息
 * @ param  sureTitle 确定按钮title
 * @ param  cancelTitle 取消按钮title
 * @ param  sunAlertActionBlock 按钮handler
 * @ return  UIAlertController (alert.textFields,alert.actions)
 */
+(UIAlertController *)showAlert:(NSString *)title
         message:(NSString *)message
       sureTitle:(NSString *)sureTitle
     cancelTitle:(NSString *)cancelTitle
 completionBlock:(sunAlertActionBlock)completionBlock
parentVc:(UIViewController *)parentVc;

#pragma mark --提示+一个输入框+按钮（取消+确认）

/**
 * Alter提示 提示+输入框+确认按钮
 * @ param  title 标题
 * @ param  message 信息
 * @ param  textFieldPlaceholder textField placeHolder
 * @ param  sureTitle 按钮title
 * @ param  sunAlertActionBlock 按钮handler
 * @ return  UIAlertController (alert.textFields,alert.actions)
 */
+(UIAlertController *)showAlert:(NSString *)title
         message:(NSString *)message
     placeholder:(NSString *)textFieldPlaceholder
       sureTitle:(NSString *)sureTitle
 completionBlock:(sunAlertActionBlock)completionBlock
parentVc:(UIViewController *)parentVc;

/**
 * Alter提示 提示+输入框+2个按钮（确认和取消）
 * @ param  title 标题
 * @ param  message 信息
 * @ param  textFieldPlaceholder textField placeHolder
 * @ param  sureTitle 确定按钮title
 * @ param  cancelTitle 取消按钮title
 * @ param  completionBlock 按钮handler
 * @ return  UIAlertController (alert.textFields,alert.actions)
 */
+(UIAlertController *)showAlert:(NSString *)title
         message:(NSString *)message
     placeholder:(NSString *)textFieldPlaceholder
       sureTitle:(NSString *)sureTitle
     cancelTitle:(NSString *)cancelTitle
 completionBlock:(sunAlertActionBlock)completionBlock
parentVc:(UIViewController *)parentVc;


#pragma mark --自定义模式
/**
 * Alter提示 自定义模式(多个按钮+一个取消按钮)
 * @ param  title 标题
 * @ param  message 信息
 * @ param  tyle 样式
 * @ param  cancelTitle 取消按钮title
 * @ param  otherButtonTitleArry    按钮标题
 * @ param  completionBlock block回调
 * @ param  parentVc Alter父类VC
 * @ return  UIAlertController (alert.textFields,alert.actions)
 */
+(UIAlertController *)showAlert:(NSString *)title
         message:(NSString *)message
      alertStyle:(UIAlertControllerStyle)style
     cancelTitle:(NSString *)cancelTitle
otherButtonTitle:(NSArray <NSString *> *)otherButtonTitleArry
 completionBlock:(sunAlertActionBlock)completionBlock
parentVc:(UIViewController *)parentVc;

/**
 * Alter提示 自定义模式(多个输入框+一个确定按钮)
 * @ param  title 标题
 * @ param  message 信息
 * @ param  tyle 样式
 * @ param  sureTitle 确定按钮title
 * @ param  textFieldPlaceholderArry 所有输入框placeHolder
 * @ param  textFieldBlock 输入框block回调
 * @ param  completionBlock block回调
 * @ param  parentVc Alter父类VC
 * @ return  UIAlertController (alert.textFields,alert.actions)
*/
+(UIAlertController *)showAlert:(NSString *)title
         message:(NSString *)message
      alertStyle:(UIAlertControllerStyle)style
       sureTitle:(NSString *)sureTitle
     placeholder:(NSArray <NSString *> *)textFieldPlaceholderArry
 completionBlock:(sunAlertActionBlock)completionBlock
parentVc:(UIViewController *)parentVc;

/**
 * Alter提示 自定义模式(多个输入框+2个按钮（确认和取消）)
 * @ param  title 标题
 * @ param  message 信息
 * @ param  tyle 样式
 * @ param  sureTitle 确定按钮title
 * @ param  cancelTitle 取消按钮title
 * @ param  textFieldPlaceholderArry 所有输入框placeHolder
 * @ param  textFieldBlock 输入框block回调
 * @ param  completionBlock block回调
 * @ param  parentVc Alter父类VC
 * @ return  UIAlertController (alert.textFields,alert.actions)
 */
+(UIAlertController *)showAlert:(NSString *)title
         message:(NSString *)message
      alertStyle:(UIAlertControllerStyle)style
       sureTitle:(NSString *)sureTitle
     cancelTitle:(NSString *)cancelTitle
     placeholder:(NSArray <NSString *> *)textFieldPlaceholderArry
 completionBlock:(sunAlertActionBlock)completionBlock
parentVc:(UIViewController *)parentVc;

/**
 * Alter提示 自定义模式(多个输入框+多个按钮+2个按钮（确认和取消）)
 * @ param  title 标题
 * @ param  message 信息
 * @ param  tyle 样式
 * @ param  sureTitle 确定按钮title
 * @ param  cancelTitle 取消按钮title
 * @ param  textFieldPlaceholderArry 所有输入框placeHolder
 * @ param  otherButtonTitleArry    按钮标题
 * @ param  textFieldBlock 输入框block回调
 * @ param  completionBlock block回调
 * @ param  parentVc Alter父类VC
 * @ return  UIAlertController (alert.textFields,alert.actions)
 */
+(UIAlertController *)showAlert:(NSString *)title
                        message:(NSString *)message
                     alertStyle:(UIAlertControllerStyle)style
                      sureTitle:(NSString *)sureTitle
                    cancelTitle:(NSString *)cancelTitle
                    placeholder:(NSArray <NSString *> *)textFieldPlaceholderArry
               otherButtonTitle:(NSArray <NSString *> *)otherButtonTitleArry
                completionBlock:(sunAlertActionBlock)completionBlock
                       parentVc:(UIViewController *)parentVc;

@end

NS_ASSUME_NONNULL_END
