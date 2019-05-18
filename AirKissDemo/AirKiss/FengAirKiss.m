//
//  LarkSmartConfig.m
//  AirKiss
//
//  Created by Feng on 2018/11/22.
//  Copyright © 2018年 Feng. All rights reserved.
//

#import "FengAirKiss.h"
#import "GCDAsyncUdpSocket.h"
#import "FengAirkissEncoder.h"
#import "FengAirKissDefines.h"
#include <ifaddrs.h>
#import <arpa/inet.h>
#include <net/if.h>

#define kAirKiss_Port                    10000
#define kAirKiss_Host                    @"255.255.255.255"

#define WEAK(weaks,s)  __weak __typeof(&*s)weaks = s;

#define IOS_CELLULAR    @"pdp_ip0"

#define IOS_WIFI        @"en0"

#define IOS_VPN         @"utun0"

#define IP_ADDR_IPv4    @"ipv4"

#define IP_ADDR_IPv6    @"ipv6"

@interface FengAirKiss()<GCDAsyncUdpSocketDelegate>{
    
    BOOL isStarted;
    BOOL isClosed;
    BOOL isTimeOut;
    
    NSInteger m_timeOut;
    NSInteger m_packetInterval;
    NSInteger m_SNAPInterval;

    NSTimer *m_timer;
    
    NSString *serIp;
    NSString *LocaIp;
    int serPort;
    
    GCDAsyncUdpSocket *clientUdpSocket;
    GCDAsyncUdpSocket *serverUdpSocket;
}

@property(nonatomic,readwrite,strong)FengAirkissEncoder *airKissEncoder;

@end

@implementation FengAirKiss


#pragma mark -- 初始化
-(instancetype)init{
    self = [super init];
    if (self) {
        isStarted = NO;
        isClosed = YES;
        isTimeOut = NO;
        
        m_timeOut = 60*1000; //60s
        m_packetInterval = 5; //5ms
        m_SNAPInterval = 100; //100ms
        
        m_timer = nil;
        clientUdpSocket = nil;
        serverUdpSocket = nil;

    }
    return self;
}

#pragma mark --setter
-(void)setTimeOut:(NSInteger)timeOut {
    _timeOut = timeOut;
    m_timeOut = timeOut;
}

-(void)setPacketInterval:(NSInteger)packetInterval {
    _packetInterval = packetInterval;
    m_packetInterval = packetInterval;
}

-(void)setSNAPInterval:(NSInteger)SNAPInterval {
    _SNAPInterval = SNAPInterval;
    m_SNAPInterval = SNAPInterval;
}

#pragma mark --懒加载
-(FengAirkissEncoder *)airKissEncoder {
    if (!_airKissEncoder) {
        _airKissEncoder = [[FengAirkissEncoder alloc] init];
    }
    return _airKissEncoder;
}

#pragma mark - 创建 udp socket
- (LarkResutCode)createClientUdpSocket {
    NSError *error = nil;
    if (!clientUdpSocket) {
        clientUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        [clientUdpSocket enableBroadcast:YES error:&error];
    }
    
    if (![clientUdpSocket bindToPort:0 error:&error]){
        return LarkResutCodeCreatScocketFail;
    }
    
    if (![clientUdpSocket beginReceiving:&error]){
        return LarkResutCodeCreatScocketFail;
    }
    return LarkResutCodeSuccess;
}

- (LarkResutCode)createServerUdpSocket {
    if (!serverUdpSocket) {
        serverUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        [serverUdpSocket enableBroadcast:YES error:nil];
    }
    
    NSError *error = nil;
    if (![serverUdpSocket bindToPort:kAirKiss_Port error:&error]){
        return LarkResutCodeCreatScocketFail;
    }
    
    if (![serverUdpSocket beginReceiving:&error]){
        return LarkResutCodeCreatScocketFail;
    }
    return LarkResutCodeSuccess;
}

#pragma mark --开始配网
-(LarkResutCode)start:(NSString *)ssid psk:(NSString *)psk {
    if (isStarted) {
        return LarkResutCodeAlReadyStart;
    }
    if (ssid == nil || [ssid isEqualToString:@""]) {
        return LarkResutCodeSsidNULL;
    }
    if (psk == nil) {
        return LarkResutCodePskNULL;
    }
    
    LarkResutCode ret;
    ret = [self createClientUdpSocket];
    if (ret < 0) {
        return ret;
    }
    ret = [self createServerUdpSocket];
    if (ret < 0) {
        return ret;
    }

    isStarted = YES;
    isClosed = NO;
    isTimeOut = NO;
    
    
    m_timer = [NSTimer scheduledTimerWithTimeInterval:m_timeOut/1000 target:self selector:@selector(timeOutAction:) userInfo:nil repeats:NO];
    
    [self sendData:ssid psk:psk];
    
    return LarkResutCodeSuccess;
}

#pragma mark --停止配网
-(LarkResutCode)stop {
    isStarted = NO;
    return [self closeSocket];
}

#pragma mark --关闭
-(LarkResutCode)closeSocket {
    if (isClosed) {
        return LarkResutCodeAlReadyClosed;
    }
    if (clientUdpSocket) {
        [clientUdpSocket close];
    }
    if (serverUdpSocket) {
        [serverUdpSocket close];
    }
    if (m_timer) {
        [m_timer invalidate];
    }
    
    clientUdpSocket = nil;
    serverUdpSocket = nil;
    m_timer = nil;
    
    isClosed = YES;
    return LarkResutCodeSuccess;
}

#pragma mark --超时
-(void)timeOutAction:(NSTimer *)timer {
    isTimeOut = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(FengAirKissError:message:)]) {
        [_delegate FengAirKissError:self message:@"time out"];
    }
}

#pragma mark --发送数据线程
-(void)sendData:(NSString *)ssid psk:(NSString *)psk{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        /* 关于超时时间
         ** 按照协议的纠错分析，最坏的情况下，最多需要5次就可以完成信息的发送，发送五次后纠错成功率99.999%
         * 一般长度的ssid和psk基本上30s足够发五六次，但是因为手机和设备端不同步问题，建议设置成60s
         */
        NSMutableArray *dataArry = [self.airKissEncoder airKissEncorderWithSSID:ssid password:psk];
        self->LocaIp = [self getDeviceIp:YES];
        while (1) {
            if (self->isClosed || self->isTimeOut) {//已关闭或超时
                break;
            }
            [self sendWifi:dataArry];
            [NSThread sleepForTimeInterval:self->m_SNAPInterval/1000.0];
        }
    });
}
#pragma mark --发送WIFI数据
-(void)sendWifi:(NSMutableArray *)dataArry{
    if (isClosed || isTimeOut) {
        return;
    }
    for (int i = 0 ; i < dataArry.count; i++) {
        if (isClosed || isTimeOut) {
            break;
        }
        LarkInt16_t  length = [dataArry[i] unsignedShortValue];
        NSMutableData *mData = [NSMutableData data];
        unsigned int value = 0;
        for (int j = 0; j < length; j++) {
            if (isClosed || isTimeOut) {
                break;
            }
            [mData appendBytes:&value length:1];
        }
        [clientUdpSocket sendData:mData
                                toHost:kAirKiss_Host
                                  port:kAirKiss_Port
                           withTimeout:-1
                                   tag:99999];
        [NSThread sleepForTimeInterval:m_packetInterval/1000.0];
    }
}

#pragma mark - GCDAsyncUdpSocketDelegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    // 已发送的数据包 tag
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    // 发送失败的数据包 tag
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext{
        
    if (serverUdpSocket == sock) {
        if (address != nil) {
            serIp = [GCDAsyncUdpSocket hostFromAddress:address];
            [serIp stringByReplacingOccurrencesOfString:@"::ffff:" withString:@""];
            serPort = (int)[GCDAsyncUdpSocket portFromAddress:address];
            if ([serIp isEqualToString:LocaIp]) {
                return;//是本机的数据直接返回
            }
        }
        if (data != nil) {
            [self dataParse:data];
        }
    }
}

#pragma mark --数据解析
-(void)dataParse:(NSData *)data{
    
    /**
     数据格式：为自定义格式，按照各自定的协议解析
      random(1byte)+dsn_len(1byte)+DSN(n bytes)+token_len(1byte)+setup_token(n bytes)
     */
    LarkInt8_t *bytes = (LarkInt8_t *)[data bytes];
    NSUInteger totalLen = data.length;
    int index = 0;
    LarkInt8_t random = bytes[index];
    index++;
    if (random == self.airKissEncoder.random) {
        NSString *dsn;
        NSString *setUpToken;
        
        if (index+1 > totalLen) {
            return;
        }
        LarkInt8_t dsn_len = bytes[index];
        index ++;
        if (index+dsn_len+1 > totalLen) {
            return;
        }
        NSData *dsnData = [NSData dataWithBytes:bytes+index length:dsn_len];
        dsn = [[NSString alloc] initWithData:dsnData encoding:NSUTF8StringEncoding];
        
        index += dsn_len;
        if (totalLen > index+1) {
            LarkInt8_t setUpToken_len = bytes[index];
            index++;
            if (index+setUpToken_len > totalLen) {
                return;
            }
            NSData *setUpTokenData = [NSData dataWithBytes:bytes+index length:setUpToken_len];
            setUpToken = [[NSString alloc] initWithData:setUpTokenData encoding:NSUTF8StringEncoding];
        }
        
        if (dsn != nil && ![dsn isEqualToString:@""]) {
            if (_delegate && [_delegate respondsToSelector:@selector(FengAirKissFinish:dsn:token:)]) {
                [_delegate FengAirKissFinish:self dsn:dsn token:setUpToken];
                if (m_timer) {
                    [m_timer invalidate];
                }
            }
        }
    }
}

#pragma mark - 获取设备当前网络IP地址
- (NSString *)getDeviceIp:(BOOL)preferIPv4 {
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop){
         address = addresses[key];
         //筛选出IP地址格式
         if([self isValidatIP:address]) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

- (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            NSString *result=[ipAddress substringWithRange:resultRange];
            //输出结果
            NSLog(@"%@",result);
            return YES;
        }
    }
    return NO;
}

- (NSDictionary *)getIPAddresses{
    
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        freeifaddrs(interfaces);
        
    }
    return [addresses count] ? addresses : nil;
    
}

-(void)dealloc {
    NSLog(@"air Kiss dealloc");
}

@end
