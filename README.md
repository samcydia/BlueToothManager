# BlueToothManager
一键蓝牙连接 外部扫描 快速高效 高度封装,导入即用 (如果觉得好用请star一下,谢谢~)

特别注意 : 模拟器无蓝牙,需要进行代码需要选择真机测试!!!否则会崩溃!!!

使用说明:
导入BlueToothManager.h/BlueToothManager.m到项目

在ViewController中导入"BlueToothManager.h"头文件,添加点击按钮,开始扫描

- (IBAction)scanButtonClick:(id)sender {
    
    [kBlueToothManager beginScanCBPeripheral:^(NSArray *peripheralArr) {
    
        self.tableArr = peripheralArr;
        
        [self.tableView reloadData];
        
    }];
    
}

以上代码已经完成蓝牙扫描到获取数据.

/////////////////////////////////////////////////////////////

以下为ViewController中剩余代码显示数据设置tableView

//添加tableView代理及数据源方法

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

//storyBoard连线tableView(或者代码创建添加tableView)

@property (weak, nonatomic) IBOutlet UITableView *tableView;

//扫描的蓝牙列表数据

@property(nonatomic,strong)NSArray <CBPeripheral *>*tableArr;

@end

///////////////////////////////////////////////////////////////

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{

    return self.tableArr.count;
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    CBPeripheral *peripheral = self.tableArr[indexPath.row];
    
    cell.textLabel.text = peripheral.name ;
    
    cell.detailTextLabel.text = [peripheral.identifier UUIDString];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
     CBPeripheral *peripheral = self.tableArr[indexPath.row];
    
    [kBlueToothManager connectPeripheral:peripheral Completion:^(NSError *error) {
    
        if (error == nil) {
        
            NSLog(@"连接成功");
            
        }
        
    }];
    
}


示例图片:

![image](https://github.com/samcydia/BlueToothManager/blob/master/示例图片/Snip20170503_1.png)
