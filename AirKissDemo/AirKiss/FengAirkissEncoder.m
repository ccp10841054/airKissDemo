//
//  FengAirkissEncoder.m
//  AirKiss
//
//  Created by Feng on 2018/11/26.
//  Copyright © 2018年 Feng. All rights reserved.
//

#import "FengAirkissEncoder.h"

@interface FengAirkissEncoder(){
    LarkUInt8_t m_random;
}

@property(nonatomic,readwrite,copy)NSMutableArray *encoderDataArry;

@end


@implementation FengAirkissEncoder

/**
 airKiss协议
 
 controll字段：
 Magic code field (4个9bits)
 .
 . 20个magic code
 .
 Prefix code field (4个9bits)
 Data字段:(N个Sequence序列)
 Sequence header field(2个9bits)
 Data field(4个9bits)
 .
 .
 Sequence header field(2个9bits)
 Data field(4个9bits) （数据格式：psk+random+ssid，以4为粒度，最后数据不足4，以0补齐）
 */


-(NSMutableArray *)encoderDataArry {
    if (!_encoderDataArry) {
        _encoderDataArry = [[NSMutableArray alloc] init];
    }
    return _encoderDataArry;
}

/**
 random
 */
- (LarkInt8_t) GetRandomNum {
    return (LarkInt8_t)arc4random()%127;
}

/**
 CRC
 */
- (LarkUInt8_t) crc8:(LarkUInt8_t *)data len:(LarkInt32_t)len {
    LarkUInt8_t cFcs = 0;
    for(int i = 0; i < len; i ++ ) {
        cFcs ^= data[i];
        for(int j = 0; j < 8; j ++) {
            if(cFcs & 1) {
                cFcs ^= 0x18; /* CRC (X(8) + X(5) + X(4) + 1) */
                cFcs >>= 1;
                cFcs |= 0x80;//cFcs = (BYTE)((cFcs >> 1) ^ AL2_FCS_COEF);
            } else {
                cFcs >>= 1;
            }
        }
    }
    return cFcs;
}

/**
 *前导域
 * 固定为｛1,2,3,4｝
 */
- (void) addLeadingPart {
    
    for (int i = 0; i < 50;i++) { //发送50个前导域 假设设备以50ms的频率切换信道，则可以覆盖20个信道，一般8个最多14,多发一些保险
        for (int j = 1; j < 5; j++) { //固定为｛1,2,3,4｝
            [self.encoderDataArry addObject:[NSNumber numberWithInt:j]];
        }
    }
}

/**
 Magic code (4个9bits，控制字段, 第8bit为0，第7bit为0 与Sequence header区分)
 *
 * bit8-4: 0x0  bit3-0:length(high) 要发送数据长度的高四位(包括随机数)
 * bit8-4: 0x1  bit3-0:length(low)  要发送数据长度的低四位
 * bit8-4: 0x2  bit3-0:ssid crc(high) ssid的crc的高四位
 * bit8-4: 0x3  bit3-0:ssid crc(low)  ssid的crc的低四位
 
 */
- (void) addMagicCode:(NSString *)ssid psk:(NSString *)psk{
    LarkUInt8_t length = strlen([ssid UTF8String])+strlen([psk UTF8String])+1;
    LarkUInt8_t crc8 = [self crc8:(LarkUInt8_t*)[ssid UTF8String] len:(LarkInt32_t)strlen([ssid UTF8String])];//字符串校验和需要ASCII编码
    
    LarkUInt8_t magicCode[4] = {0x00,0x00,0x00,0x00};
    magicCode[0] = 0x00 | ((length>>4)&0x0F);
    if (magicCode[0] == 0) {
        magicCode[0] = 0x08;
    }
    magicCode[1] = 0x10 | (length&0x0F);
    magicCode[2] = 0x20 | (crc8>>4&0x0F);
    magicCode[3] = 0x30 | (crc8&0x0F);
    
    //20个magic
    for (int i = 0; i < 20; i++) {
        for (int j = 0; j < 4; j++) {
            [self.encoderDataArry addObject:[NSNumber numberWithUnsignedChar:magicCode[j]]];
        }
    }
}


/**
 Prefix code(4个9bits,控制字段 ，与Magic code一样，第8bit为0，第7bit为0)
 *
 * bit8-4: 0x4  bit3-0:psk length(high) psk数据长度的高四位
 * bit8-4: 0x5  bit3-0:psk length(low)  psk送数据长度的低四位
 * bit8-4: 0x6  bit3-0:psk length crc(high) psk数据长度的crc的高四位
 * bit8-4: 0x7  bit3-0:psk length crc(low)  psk数据长度的crc的低四位
 
 */
- (void)addPrefixCode:(NSString *)psk{
    LarkUInt8_t len_psk = strlen([psk UTF8String]);
    LarkUInt8_t crc8 = [self crc8:&len_psk len:1];
    LarkUInt8_t prefixCode[4] = {0x00,0x00,0x00,0x00};
    prefixCode[0] = 0x40 | (len_psk>>4&0x0F);
    prefixCode[1] = 0x50 | (len_psk&0x0F);
    prefixCode[2] = 0x60 | (crc8>>4&0x0F);
    prefixCode[3] = 0x70 | (crc8&0x0F);
    
    for (int i = 0; i < 4; i++) {
        [self.encoderDataArry addObject:[NSNumber numberWithUnsignedChar:prefixCode[i]]];
    }
}

/**
 *
 Sequence header （2个9bits，控制字段 第8bit为0，第7bit为1 与magic区分）
 
 * bit8-7:01 bit6-0:Sequence crc8低7位
 * bit8-7:01 bit6-0:Sequence index
 
 data field （4个9bits，data字段，第8bit为1）
 
 * bit8:1  bit7-0:Sequence crc8低7位
 * bit8:1  bit7-0:Sequence crc8低7位
 * bit8:1  bit7-0:Sequence crc8低7位
 * bit8:1  bit7-0:Sequence crc8低7位
 */

- (void) addSequenceHeaderAndDataField:(NSData *)data index:(LarkUInt8_t) index {
    
    //Sequence Header
    LarkUInt8_t newIndex = index & 0xFF;
    NSMutableData *mData = [NSMutableData dataWithBytes:&newIndex length:1];
    [mData appendData:data];
    LarkUInt8_t *newUData      = (LarkUInt8_t *)[mData bytes]; //1字节
    
    LarkUInt8_t crc8 = [self crc8:newUData len:(LarkInt32_t)mData.length];
    
    [self.encoderDataArry addObject:[NSNumber numberWithUnsignedChar:(0x80 | crc8)]];
    [self.encoderDataArry addObject:[NSNumber numberWithUnsignedChar:(0x80 | index)]];
    
    //Sequence data field
    LarkUInt8_t *originUData   = (LarkUInt8_t *)[data bytes]; //2字节
    
    for (int i = 0; i < data.length; i++) {
        [self.encoderDataArry addObject:[NSNumber numberWithUnsignedShort:0x100 |originUData[i]]];
    }
}

/**
 *Sequence(data字段 第8bit为1)
 *数据内容：psk+random(1bytes)+ssid 以4为粒度，不足补0
 
 *Sequence header （2个9bits）
 * data field （4个9bits）
 */
- (void)addSequence:(NSString *)ssid psk:(NSString *)psk {
    NSMutableData *data = [NSMutableData dataWithData:[psk dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendBytes:&(m_random) length:1];
    [data appendData:[ssid dataUsingEncoding:NSUTF8StringEncoding]];
    
    int size = 4; //以4为粒度
    int index = 0;
    NSData *tempData = nil;
    for (index = 0; index < (data.length/size); index++) { //4为粒度
        tempData = [data subdataWithRange:NSMakeRange(index*size, size)];
        [self addSequenceHeaderAndDataField:tempData index:index];
    }
    
    if ((data.length%size) != 0) { //不足4的字节的数据
        tempData = [data subdataWithRange:NSMakeRange(index * size, data.length % size)];
        [self addSequenceHeaderAndDataField:tempData index:index];
    }
}


-(NSMutableArray *)airKissEncorderWithSSID:(NSString *)ssid
                                   password:(NSString *)psk{
    
    [self.encoderDataArry removeAllObjects];

    [self addLeadingPart]; //前导域
    [self addMagicCode:ssid psk:psk];//magic code
    m_random = [self GetRandomNum];
    self.random = m_random;
    for (int i = 0; i < 15; i++) { //16为4的整数（保证了airkiss需要 以4为粒度的要求）
        [self addPrefixCode:psk]; //prefix code
        [self addSequence:ssid psk:psk]; //sequence psk+random+ssid
    }
    return self.encoderDataArry;
}

@end
