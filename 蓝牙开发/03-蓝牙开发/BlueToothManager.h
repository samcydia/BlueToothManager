//
//  HMBlueToothManager.h
//  03-蓝牙开发
//
//  Created by SAM on 2017/4/26.
//  Copyright © 2017年 SAM. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreBluetooth/CoreBluetooth.h>

#define kBlueToothManager [BlueToothManager shareInstance]

@interface BlueToothManager : NSObject


+ (instancetype)shareInstance;


/**
 开始扫描外设

 @param updatePeripheral 扫描外设回调
 */
- (void)beginScanCBPeripheral:(void(^)(NSArray *peripheralArr))updatePeripheral;



/**
 连接设备

 @param peripheral 外设
 @param completionBlock 连接回调
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral Completion:(void(^)(NSError *))completionBlock;

@end
