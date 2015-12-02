//
//  ViewController.m
//  01-GameKitDemo
//
//  Created by xiaomage on 15/10/8.
//  Copyright © 2015年 小码哥. All rights reserved.
//

#import "ViewController.h"
#import <GameKit/GameKit.h>

@interface ViewController () <GKPeerPickerControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>


@property (nonatomic, strong) GKSession *session; /**< 会话 */
@property (weak, nonatomic) IBOutlet UIImageView *icon;

@end

@implementation ViewController

// 建立连接
- (IBAction)buildContent:(id)sender {
    // 1.创建一个附近设备的搜索提示框(类似alert)
    GKPeerPickerController *ppc = [[GKPeerPickerController alloc] init];
    // @interface ViewController () <GKPeerPickerControllerDelegate>
    ppc.delegate = self;
    // 展示
    [ppc show];
}

// 发送数据
- (IBAction)sendData:(id)sender {
    // 第一步先判断要发送的数据是否存在
    if (!self.icon.image) return;
    
    // 发送数据
//    [self.session sendData:UIImagePNGRepresentation(self.icon.image)
//                   toPeers:xxx // 通常是传入已经连接的所有设备
//              withDataMode:GKSendDataMode
//                     error:<#(NSError *__autoreleasing *)#>];
    NSError *error = nil;
    
    BOOL sendState = [self.session sendDataToAllPeers:UIImagePNGRepresentation(self.icon.image)
                        withDataMode:GKSendDataReliable // 可靠的传输方式特点:1慢 2.不会丢包 3.直到传完  GKSendDataUnReliable 可靠的传输方式特点:1快 2.可能会丢包 3.传递的信息不一定完整
                               error:&error];
    if (!sendState) {
        NSLog(@"send error:%@", error.localizedDescription);
    }
}
// 从相册中选择图片
- (IBAction)chooseImaFormLib:(id)sender {
    // 首先应该判断是否支持相册选择
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        NSLog(@"木有相册!!!!");
        return;
    }
    
    // 创建选择图片的控制器
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    // 设置图片的来源
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    // 设置代理
    ipc.delegate = self;
    // modal出来
    [self presentViewController:ipc animated:YES completion:nil];
}
#pragma mark - UIImagePickerControllerDelegate
// 选择图片完毕调用的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // 让picker消失
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"%s, line = %d, info= %@", __FUNCTION__, __LINE__, info);
    // 让选中的图片显示在icon上
    self.icon.image = info[UIImagePickerControllerOriginalImage];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

#pragma mark - GKPeerPickerControllerDelegate

#warning 最常用的方法
// 已经成功连接到某个设备,并且开启了连接会话
/* Notifies delegate that the peer was connected to a GKSession.
 */
- (void)peerPickerController:(GKPeerPickerController *)picker // 搜索框
              didConnectPeer:(NSString *)peerID // 连接的设备
                   toSession:(GKSession *)session // 连接会话:通过会话可以进行数据传输
{
    NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);

    // 首先让搜索弹框消失
    [picker dismiss];
    // 标记会话
    self.session = session;
    
    // 设置接收数据
    // 设置完接受者之后,接收数据会触发: SEL = -receiveData:fromPeer:inSession:context:
    [self.session setDataReceiveHandler:self withContext:nil];
}

#pragma mark - 蓝牙设备接收到数据时,就会调用
- (void)receiveData:(NSData *)data // 数据
           fromPeer:(NSString *)peer // 来自哪个设备
          inSession:(GKSession *)session // 连接会话
            context:(void *)context
{
    NSLog(@"%s, line = %d, data = %@, peer = %@, sessoing = %@", __FUNCTION__, __LINE__, data, peer, session);
    // 将接收到的数据展示在屏幕上
    self.icon.image = [UIImage imageWithData:data];
    // 将图片存入相册
    UIImageWriteToSavedPhotosAlbum(self.icon.image, nil, nil, nil);
}

@end
