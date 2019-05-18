//
//  LarkDefines.h
//  AirKiss
//
//  Created by Feng on 2018/11/22.
//  Copyright © 2018年 Feng. All rights reserved.
//

#ifndef FengAirKissDefines_h
#define FengAirKissDefines_h

//数据类型
typedef char                LarkInt8_t;
typedef unsigned char       LarkUInt8_t;
typedef short               LarkInt16_t;
typedef unsigned short      LarkUInt16_t;
typedef int                 LarkInt32_t;
typedef unsigned int        LarkUInt32_t;
typedef long long           LarkInt64_t;
typedef unsigned long long  LarkUInt64_t;
typedef float               LarkFloat32_t;
typedef double              LarkFloat64_t;

typedef NS_ENUM(NSInteger,LarkResutCode) {
    
    LarkResutCodeSuccess = 0, //成功
    
    LarkResutCodeAlReadyStart = -1000,//已经开始设置了
    LarkResutCodeSsidNULL = -1001, //ssid为null或空字符
    LarkResutCodePskNULL = -1002, //psk为NUll
    LarkResutCodeCreatScocketFail = -1003, //创建scoket失败
    
    LarkResutCodeAlReadyClosed = -2000,//已经关闭

};


#endif /* LarkDefines_h */
