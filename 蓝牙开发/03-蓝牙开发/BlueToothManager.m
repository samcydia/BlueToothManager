//
//  BlueToothManager.m
//  03-蓝牙开发
//
//  Created by SAM on 2017/4/26.
//  Copyright © 2017年 itheima. All rights reserved.
//

#import "BlueToothManager.h"

@interface BlueToothManager ()<CBCentralManagerDelegate,CBPeripheralDelegate>

//蓝牙中心
@property(nonatomic,strong)CBCentralManager *centralManager;

//蓝牙外设
@property(nonatomic,strong)CBPeripheral *peripheral;

//扫描外设数组
@property(nonatomic,strong)NSMutableArray *scanArr;

//扫描外设回调
@property(nonatomic,copy)void(^scanBlock)(NSArray *);
//连接外设回调
@property(nonatomic,copy)void(^connectBlock)(NSError *);

@end

@implementation BlueToothManager

+ (instancetype)shareInstance
{
    static BlueToothManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BlueToothManager alloc] init];
    });
    
    return manager;
}

- (CBCentralManager *)centralManager
{
    if (_centralManager != nil) {
        return _centralManager;
    }
    
    //创建蓝牙中心
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    
    return _centralManager;
}

//检测蓝牙是否可用
- (BOOL)availableBluethooth
{
    CBManagerState state = [self.centralManager state];
    /**
     CBManagerStateUnknown = 0,未知（第一次启动蓝牙中心是未知状态）
     CBManagerStateResetting,蓝牙不可用 （未知错误）
     CBManagerStateUnsupported,当前手机不支持蓝牙
     CBManagerStateUnauthorized,//未授权
     CBManagerStatePoweredOff,//蓝牙关闭
     CBManagerStatePoweredOn,//蓝牙可用
     */
    BOOL flag = NO;
    NSString *stateStr;
    switch (state) {
        case CBManagerStateUnknown:
            stateStr = @"第一次启动蓝牙";
            flag = YES;
            break;
        case CBManagerStateResetting:
            stateStr = @"蓝牙不可用";
            break;
        case CBManagerStateUnsupported:
            stateStr = @"蓝牙未授权";
            break;
        case CBManagerStatePoweredOff:
            stateStr = @"蓝牙关闭";
            //实际开发中可以给用户一个弹窗提示 点击跳转到系统蓝牙设置界面
            break;
        case CBManagerStatePoweredOn:
            flag = YES;
            stateStr = @"蓝牙可用";
            
            break;
        default:
            
            break;
    }
    
    return flag;
}



#pragma mark -流程1-扫描设备
- (void)beginScanCBPeripheral:(void (^)(NSArray *))updatePeripheral
{
    
    //1.检测当前手机蓝牙是否可用
    //使用断言  第一个参数是一个条件表达式  第二个参数：当条件表达式不成立时程序会崩溃，参数是崩溃的描述信息
    NSAssert([self availableBluethooth] == YES, @"当前蓝牙不可用，请检查蓝牙状态");
    
    //2.开始扫描外设
    //参数表示扫描指定的外设 如果为nil则表示扫描所有的外设 opention：扫描配置 默认为nil
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    
    //3.保存block
    self.scanBlock = updatePeripheral;
}


#pragma mark -流程3-连接外设
- (void)connectPeripheral:(CBPeripheral *)peripheral Completion:(void(^)(NSError *))completionBlock
{
    [self.centralManager connectPeripheral:peripheral options:nil];
    
    //保存连接回调
    self.connectBlock = completionBlock;
}


#pragma mark ---------蓝牙中心代理CBCentralManagerDelegate

//蓝牙状态更新
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
}


#pragma mark -流程2-扫描到设备
//扫描到设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"唯一标识符：%@",peripheral.identifier);//设备唯一标识符
    NSLog(@"外设:%@",peripheral);
    NSLog(@"外设广告语：%@",advertisementData);
    NSLog(@"当前外设信号：%@",RSSI);//信号主要由距离决定 信号越好 值越低
    
    
    //扫描到设备之后添加到扫描设备数组，用于界面显示
    //同一个设备会被重复扫描，添加数组时应该做一个重复判断
    if (self.scanArr == nil) {
        self.scanArr = [[NSMutableArray alloc] init];
    }
    
    //如果设备已经在数组中则不添加，否则添加
    if(![self.scanArr containsObject:peripheral])
    {
        [self.scanArr addObject:peripheral];
    }
    
    //送出回调，刷新UI
    if(self.scanBlock)
    {
        self.scanBlock([self.scanArr copy]);
    }
}

//连接外设成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if (self.connectBlock) {
        self.connectBlock(nil);
    }
    
    //1.先保存外设
    self.peripheral = peripheral;
    //2.设置外设的代理
    self.peripheral.delegate = self;
    
    
#pragma mark -流程4 开发发现外设的服务
    //如果没有寻找服务的话，外设的服务数组是空
    //3.寻找外设的服务，为nil则表示寻找所有的服务
    [peripheral discoverServices:nil];
}


//外设连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    NSLog(@"蓝牙连接失败：%@",error);
    if (self.connectBlock) {
        self.connectBlock(error);
    }
}

//外设断开：蓝牙的有效距离大概20M左右 由于中心与外设距离过远 或者外设本身问题导致断开
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    
}

#pragma mark -----蓝牙外设代理CBPeripheralDelegate

//外设名字更新
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral
{
    
}

//外设信号变化
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    
}

//读取到外设信号
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(nullable NSError *)error
{
    
}

#pragma mark -流程5 发现外设的服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    //遍历外设的服务
    for (CBService *service in peripheral.services) {
        //实际工作中，智能硬件开发，硬件工程师会给你一份蓝牙协议，协议中会表名哪一个功能对应哪一个服务
        NSLog(@"服务UUID：%@",service.UUID);
        //开始寻找服务的特征 第一个参数：特征UUID 为nil表示寻找所有特征 第二个参数：服务
        [peripheral discoverCharacteristics:nil forService:service];
    }


}




#pragma mark -流程6 发现服务的特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error
{
    
        for (CBService *service in peripheral.services) {
                //遍历服务的特征
                for (CBCharacteristic *characteristic in service.characteristics) {
                    
                    //特征是中心与外设进行数据交互最小的单位  所有的数据的发送都是发送给特征的  每一个特征都对应一个非常细节的功能：
                    NSLog(@"特征UUID：%@",characteristic.UUID);
                    

                    //开启与特征之间的通知（中心与外设长连接，当特征发送数据过来时，能够及时收到）
                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                    //读取特征服务，一次性
                    //       [peripheral readValueForCharacteristic:c];
                    
                    //例如我的小米手环1代  其中  2A06这一个特征表示寻找手环功能  如果给该特征发送一个  二进制为2的指令  此时手环会震动
#pragma mark -给特征发送数据
                    if ([[characteristic.UUID UUIDString] isEqualToString:@"2A06"]) {
                        /**
                         Value:给特征发送的数据
                         Characteristic：特征
                         type：特征的类型 实际开发过程中：特征的类型不能写错 具体的情况我们可以两个都试一下 CBCharacteristicWriteWithResponse 该类型需要回应
                         CBCharacteristicWriteWithoutResponse,不需要回应
                         */
                        Byte byte[1];
                        byte[0] = 2 & 0xff;
                        [peripheral writeValue:[NSData dataWithBytes:byte length:1] forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
                    }
                    
                }
               }
   
}


//给特征发送数据回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    
}



#pragma mark- 获取外设发来的数据，不论是read和notify,获取数据都是从这个方法中读取。
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"外设发送过来的数据:%@",characteristic.value.description );
}


#pragma mark- 中心读取外设实时数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        
    }
    // Notification has started
    if (characteristic.isNotifying) {
        //读取外设数据
        [peripheral readValueForCharacteristic:characteristic];
        NSLog(@"%@",characteristic.value);
        
    } else { // Notification has stopped
        // so disconnect from the peripheral
        //        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        
    }
}



@end
