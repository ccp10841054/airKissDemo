//
//  SunAlertUtils.m
//  MBManager
//
//  Created by Feng on 2018/11/1.
//  Copyright © 2018年 Feng. All rights reserved.
//

#import "SunAlertUtils.h"

@implementation SunAlertUtils

//
NSString *sunTitle; //title
NSString *sunMessage; //message

NSString *sunTextFieldPlaceholder; //textField placeHolder

NSString *sunCancelButtonTitle; //cancel button title
NSString *sunSureButtonTitle;   //sure button title

sunAlertActionBlock sunCompletionBlock;//点击按钮回调

UIViewController *sunParentVC;//父类

//自定义的参数
UIAlertControllerStyle sunAlertStyle; //alter样式
UIAlertActionStyle sunCancelActionStyle; //cancel button样式

NSArray <NSString *> *suntextFieldPlaceholderArry; //textField placeholder数组
NSArray <NSString *> *sunButtonTittleArry; //button title数组

//内部使用
NSInteger buttonIndex;//botton index
NSInteger cancelButtonIndex;// cancel button index 取消和确定两个按钮index有点特殊

UITextField *sunTextField;  //sunTextFieldArry中的textField


#pragma mark --创建Alert
+(UIAlertController *)showAlert{
    
    buttonIndex = 0;
    cancelButtonIndex = 0;
    sunTextField = nil;
    
    UIAlertController * alertVc = [UIAlertController alertControllerWithTitle:sunTitle message:sunMessage preferredStyle:sunAlertStyle];    
    
    //
    //修改title字体颜色和大小
    if (sunTitle != nil && ![sunTitle isEqualToString:@""]) {
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:sunTitle];
        [title addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18.0] range:NSMakeRange(0, title.length)];
        [title addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, title.length)];
        [alertVc setValue:title forKey:@"attributedTitle"]; //title
    }

    //修改message字体颜色和大小
    if (sunMessage != nil && ![sunMessage isEqualToString:@""]) {
        NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:sunMessage];
        [message addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0] range:NSMakeRange(0, message.length)];
        [message addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, message.length)];
        [alertVc setValue:message forKey:@"attributedMessage"]; //message
    }

    //一个 textField
    if (sunTextFieldPlaceholder != nil && ![sunTextFieldPlaceholder isEqualToString:@""]) {
        [alertVc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = sunTextFieldPlaceholder;
        }];
    }
    
    //创建多个textField
    NSInteger num = suntextFieldPlaceholderArry.count;
    for (int i = 0; i < num; i++) {
        NSString *placeholder = [suntextFieldPlaceholderArry objectAtIndex:i];
        if ([placeholder isKindOfClass:[NSString class]]) {
            [alertVc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = placeholder;
            }];
        }
    }
    
    //创建多个button
    NSInteger count = sunButtonTittleArry.count;
    for (int i = 0; i < count; i++) {
        NSString * title = sunButtonTittleArry[i];
        if ([title isKindOfClass:[NSString class]]) {
            UIAlertAction *OtherAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (sunCompletionBlock) {
                    sunCompletionBlock(action,i);
                }
            }];
            buttonIndex ++;
            [alertVc addAction:OtherAction];
            [OtherAction setValue:[UIColor orangeColor] forKey:@"_titleTextColor"]; //修改字体颜色
        }
    }
    
    //cancel button
    if (sunCancelButtonTitle != nil && ![sunCancelButtonTitle isEqualToString:@""]) {
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:sunCancelButtonTitle style:sunCancelActionStyle handler:^(UIAlertAction * _Nonnull action) {
            if (sunCompletionBlock) {
                sunCompletionBlock(action,cancelButtonIndex);
            }
        }];
        [alertVc addAction:cancelAction];
        cancelButtonIndex = buttonIndex;
        buttonIndex ++;
        [cancelAction setValue:[UIColor colorWithRed:77/255.0 green:193/255.0 blue:173/255.0 alpha:1.0] forKey:@"_titleTextColor"]; //修改字体颜色
    }
    
    //sure button
    if (sunSureButtonTitle != nil && ![sunSureButtonTitle isEqualToString:@""]) { // UIAlertActionStyleDefault
        UIAlertAction * sureAction = [UIAlertAction actionWithTitle:sunSureButtonTitle style:sunCancelActionStyle handler:^(UIAlertAction * _Nonnull action) {
            if (sunCompletionBlock) {
                sunCompletionBlock(action,buttonIndex);
            }
        }];
        [alertVc addAction:sureAction];
        [sureAction setValue:[UIColor colorWithRed:77/255.0 green:193/255.0 blue:173/255.0 alpha:1.0] forKey:@"_titleTextColor"]; //修改字体颜色
    }
    
    if (sunParentVC == nil) {
        sunParentVC = [[UIApplication sharedApplication].keyWindow rootViewController];
    }
    [sunParentVC presentViewController:alertVc animated:YES completion:nil];
    return alertVc;
}

#pragma mark --弹框提示（一个button）
+(UIAlertController *)showAlert:(NSString *)title
         message:(NSString *)message
       sureTitle:(NSString *)sureTitle
 completionBlock:(sunAlertActionBlock)completionBlock
        parentVc:(UIViewController *)parentVc{
    
    sunTitle = title;
    sunMessage = message;
    sunTextFieldPlaceholder = nil;
    sunCancelButtonTitle = nil;
    sunSureButtonTitle = sureTitle;
    sunCompletionBlock = completionBlock;
    sunParentVC = parentVc;
    sunAlertStyle = UIAlertControllerStyleAlert;
    sunCancelActionStyle = UIAlertActionStyleDefault;
    suntextFieldPlaceholderArry = nil;
    sunButtonTittleArry = nil;
    return [self showAlert];
}


#pragma mark --弹框提示（两个button）
+(UIAlertController *)showAlert:(NSString *)title
         message:(NSString *)message
       sureTitle:(NSString *)sureTitle
     cancelTitle:(NSString *)cancelTitle
 completionBlock:(sunAlertActionBlock)completionBlock
        parentVc:(UIViewController *)parentVc{

    sunTitle = title;
    sunMessage = message;
    sunTextFieldPlaceholder = nil;
    sunCancelButtonTitle = cancelTitle;
    sunSureButtonTitle = sureTitle;
    sunCompletionBlock = completionBlock;
    sunParentVC = parentVc;
    sunAlertStyle = UIAlertControllerStyleAlert;
    sunCancelActionStyle = UIAlertActionStyleDefault;
    suntextFieldPlaceholderArry = nil;
    sunButtonTittleArry = nil;
    return [self showAlert];
}

#pragma mark --弹框提示（1个button +一个textField）
+(UIAlertController *)showAlert:(NSString *)title
                        message:(NSString *)message
                    placeholder:(NSString *)textFieldPlaceholder
                      sureTitle:(NSString *)sureTitle
                completionBlock:(sunAlertActionBlock)completionBlock
                       parentVc:(UIViewController *)parentVc{
    sunTitle = title;
    sunMessage = message;
    sunTextFieldPlaceholder = textFieldPlaceholder;
    sunSureButtonTitle = sureTitle;
    sunCancelButtonTitle = nil;
    sunCompletionBlock = completionBlock;
    sunParentVC = parentVc;
    sunAlertStyle = UIAlertControllerStyleAlert;
    sunCancelActionStyle = UIAlertActionStyleDefault;
    return [self showAlert];
}

#pragma mark --弹框提示（2个button +一个textField）
+(UIAlertController *)showAlert:(NSString *)title
         message:(NSString *)message
     placeholder:(NSString *)textFieldPlaceholder
       sureTitle:(NSString *)sureTitle
     cancelTitle:(NSString *)cancelTitle
 completionBlock:(sunAlertActionBlock)completionBlock
        parentVc:(UIViewController *)parentVc{
    
    sunTitle = title;
    sunMessage = message;
    sunTextFieldPlaceholder = textFieldPlaceholder;
    sunCancelButtonTitle = cancelTitle;
    sunSureButtonTitle = sureTitle;
    sunCompletionBlock = completionBlock;
    sunParentVC = parentVc;
    sunAlertStyle = UIAlertControllerStyleAlert;
    sunCancelActionStyle = UIAlertActionStyleDefault;
    suntextFieldPlaceholderArry = nil;
    sunButtonTittleArry = nil;
    return [self showAlert];
}

#pragma mark --自定义样式 多个按钮+一个取消按钮
+(UIAlertController *)showAlert:(NSString *)title
         message:(NSString *)message
      alertStyle:(UIAlertControllerStyle)style
     cancelTitle:(NSString *)cancelTitle
otherButtonTitle:(NSArray <NSString *> *)otherButtonTitleArry
 completionBlock:(sunAlertActionBlock)completionBlock
        parentVc:(UIViewController *)parentVc{
    
    sunTitle = title;
    sunMessage = message;
    sunTextFieldPlaceholder = nil;
    sunCancelButtonTitle = cancelTitle;
    sunSureButtonTitle = nil;
    sunCompletionBlock = completionBlock;
    sunParentVC = parentVc;
    sunAlertStyle = style;
    sunCancelActionStyle = UIAlertActionStyleCancel;
    suntextFieldPlaceholderArry = nil;
    sunButtonTittleArry = otherButtonTitleArry;
    return [self showAlert];
}

#pragma mark --自定义样式 多个输入框+一个按钮
+(UIAlertController *)showAlert:(NSString *)title
                        message:(NSString *)message
                     alertStyle:(UIAlertControllerStyle)style
                      sureTitle:(NSString *)sureTitle
                    placeholder:(NSArray <NSString *> *)textFieldPlaceholderArry
                completionBlock:(sunAlertActionBlock)completionBlock
                       parentVc:(UIViewController *)parentVc{
    
    sunTitle = title;
    sunMessage = message;
    sunTextFieldPlaceholder = nil;
    sunCancelButtonTitle = nil;
    sunSureButtonTitle = sureTitle;
    sunParentVC = parentVc;
    sunAlertStyle = style;
    sunCompletionBlock = completionBlock;
    sunCancelActionStyle = UIAlertActionStyleDefault;
    suntextFieldPlaceholderArry = textFieldPlaceholderArry;
    sunButtonTittleArry = nil;
    return [self showAlert];
}

#pragma mark --自定义样式 多个输入框+2个按钮
+(UIAlertController *)showAlert:(NSString *)title
         message:(NSString *)message
      alertStyle:(UIAlertControllerStyle)style
       sureTitle:(NSString *)sureTitle
     cancelTitle:(NSString *)cancelTitle
     placeholder:(NSArray <NSString *> *)textFieldPlaceholderArry
 completionBlock:(sunAlertActionBlock)completionBlock
        parentVc:(UIViewController *)parentVc{
    
    sunTitle = title;
    sunMessage = message;
    sunTextFieldPlaceholder = nil;
    sunCancelButtonTitle = cancelTitle;
    sunSureButtonTitle = sureTitle;
    sunCompletionBlock = completionBlock;
    sunParentVC = parentVc;
    sunAlertStyle = UIAlertControllerStyleAlert;
    sunCancelActionStyle = UIAlertActionStyleDefault;
    suntextFieldPlaceholderArry = textFieldPlaceholderArry;
    sunButtonTittleArry = nil;
    return [self showAlert];

}

#pragma mark --自定义样式 多个输入框+ 多个button +2个按钮
+(UIAlertController *)showAlert:(NSString *)title
         message:(NSString *)message
      alertStyle:(UIAlertControllerStyle)style
       sureTitle:(NSString *)sureTitle
     cancelTitle:(NSString *)cancelTitle
     placeholder:(NSArray <NSString *> *)textFieldPlaceholderArry
otherButtonTitle:(NSArray <NSString *> *)otherButtonTitleArry
 completionBlock:(sunAlertActionBlock)completionBlock
        parentVc:(UIViewController *)parentVc {
    
    sunTitle = title;
    sunMessage = message;
    sunTextFieldPlaceholder = nil;
    sunCancelButtonTitle = cancelTitle;
    sunSureButtonTitle = sureTitle;
    sunCompletionBlock = completionBlock;
    sunParentVC = parentVc;
    sunAlertStyle = UIAlertControllerStyleAlert;
    sunCancelActionStyle = UIAlertActionStyleDefault;
    suntextFieldPlaceholderArry = textFieldPlaceholderArry;
    sunButtonTittleArry = otherButtonTitleArry;
    return [self showAlert];
}

@end
