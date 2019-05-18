//
//  LarkSmartConfig.h
//  AirKiss
//
//  Created by Feng on 2018/11/22.
//  Copyright © 2018年 Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FengAirKissDefines.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FengAirKissDelegate <NSObject>

/**
 airKiss配网成功

 @param sender FengAirKiss
 @param dsn 设备Dsn
 @param setUpToken 由设备生成的setUpToken
 */
-(void)FengAirKissFinish:(id)sender dsn:(NSString *)dsn token:(NSString *)setUpToken;


/**
 airKiss配网失败

 @param sender FengAirKiss
 @param error 错误信息
 */
-(void)FengAirKissError:(id)sender message:(NSString *)error;

@end


@interface FengAirKiss: NSObject

/**
 设置超时时间 单位：ms
 
 默认为60*1000ms
 * 建议范围：5*1000ms-60*1000ms
 */
@property(nonatomic,readwrite,assign)NSInteger timeOut; //超时时间

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
@property(nonatomic,readwrite,weak) id<FengAirKissDelegate> delegate;


/**
 开始配网

 @param ssid WiFi ssid
 @param psk  WiFi psk
 @return LarkResutCode:LarkResutCodeSuccess 成功   其他：失败（详细参考LarkResutCode注释）
 */

-(LarkResutCode)start:(NSString *)ssid psk:(NSString *)psk;


/**
 停止配网
 配网成功或配网失败或想要终止配网都需要调用此接口
 */
-(LarkResutCode)stop;

@end

NS_ASSUME_NONNULL_END
