//
//  LarkSmartConfig.h
//  AirKiss
//
//  Created by Feng on 2018/11/22.
//  Copyright © 2018年 Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LarkAirKissDefines.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LarkAirKissDelegate <NSObject>

/**
 返回DSN+setUpToken

 @param sender LarkAirKiss
 @param dsn 设备Dsn
 @param setUpToken 由设备生成setUpToken的才有此值，比如长虹（setUpToken 5mins没注册就失效）
 */
-(void)LarkAirKiss:(id)sender dsn:(NSString *)dsn token:(NSString *)setUpToken;

/**
 完成所有发送

 @param sender LarkAirKiss
 */
-(void)LarkAirKissFinish:(id)sender;


/**
 配置过程过失败，失败原因

 @param sender LarkAirKiss
 @param type 参照 LarkAirKissFailType
 @param error 错误信息
 */
-(void)LarkAirKissError:(id)sender type:(int)type message:(NSString *)error;

@end


@interface LarkAirKiss: NSObject

/**
 设置超时时间 单位：ms
 
 默认为30*1000ms
 * 建议范围：5*1000ms-60*1000ms
 */
@property(nonatomic,readwrite,assign)NSInteger timeOut; //超时时间 默认为10*1000ms

/**
 设置数据包发送间隔 单位：ms
 * 默认为5ms
 * 建议范围：5-80ms
 */
@property(nonatomic,readwrite,assign)NSInteger packetInterval; //数据包间隔

/**
 设置协议包发送间隔 单位：ms
 
 * 默认为100ms
 * 建议范围：0-5000ms
 */
@property(nonatomic,readwrite,assign)NSInteger SNAPInterval; //SNAP协议包间隔


/**
 代理
 */
@property(nonatomic,readwrite,weak) id<LarkAirKissDelegate> delegate;

/**
 开始配网

 @param ssid WiFi ssid
 @param psk  WiFi psk
 @param setUpToken  (可选参数，后期使用DSN注册方式不需要此参数，如果选择AP注册方式，就一定要此参数)
 另外长虹的项目，设备生成setUpToken，所以此处不需要传
 @return LarkResutCode:LarkResutCodeSuccess 成功   其他：失败（详细参考LarkResutCode注释）
 */

-(LarkResutCode)start:(NSString *)ssid psk:(NSString *)psk token:(NSString *)setUpToken;



/**
 停止配网
 配网成功或配网失败或想要终止配网都需要调用此接口
 */
-(LarkResutCode)stop;

@end

NS_ASSUME_NONNULL_END
