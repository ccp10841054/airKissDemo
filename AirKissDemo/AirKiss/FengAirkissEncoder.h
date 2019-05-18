//
//  FengAirkissEncoder.h
//  AirKiss
//
//  Created by Feng on 2018/11/26.
//  Copyright © 2018年 Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FengAirKissDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface FengAirkissEncoder : NSObject


@property(nonatomic,readwrite,assign) LarkInt8_t random;//随机数


- (NSMutableArray *)airKissEncorderWithSSID:(NSString *)ssid
                                         password:(NSString *)psk;


@end

NS_ASSUME_NONNULL_END
