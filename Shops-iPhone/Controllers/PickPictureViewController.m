//
//  PickPictureViewController.m
//  Shops-iPhone
//
//  Created by cml on 15/7/17.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "PickPictureViewController.h"

//// Views
//#import "KLCPopup.h"
//#import "YunShareView.h"
//
//@interface PickPictureViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, YunShareViewDelegate>
//
//@property (nonatomic, copy) NSString *imagePath;
//
//@property (nonatomic, strong) UIButton *changeImg;
//
//@end
//
//@implementation PickPictureViewController
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    
//    //获取Documents文件夹目录
//    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentPath = [path objectAtIndex:0];
//    
//    //指定新建文件夹路径
//    NSString *imageDocPath = [documentPath stringByAppendingPathComponent:@"ImageFile"];
//    
//    //创建ImageFile文件夹
//    [[NSFileManager defaultManager] createDirectoryAtPath:imageDocPath withIntermediateDirectories:YES attributes:nil error:nil];
//    
//    //保存图片的路径
//    self.imagePath = [imageDocPath stringByAppendingPathComponent:@"image.png"];
//}
//
//-(void)viewWillAppear:(BOOL)animated
//{
//    _changeImg = [UIButton buttonWithType:UIButtonTypeCustom];
//    _changeImg.frame = CGRectMake(50, 200, 100, 100);
//    [_changeImg addTarget:self action:@selector(changeImage:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:_changeImg];
//    
//    [super viewWillAppear:YES];
//    
//    //根据图片路径载入图片
//    UIImage *image=[UIImage imageWithContentsOfFile:self.imagePath];
//    
//    if (image == nil) {
//        //显示默认
//        [_changeImg setBackgroundImage:[UIImage imageNamed:@"default_image"] forState:UIControlStateNormal];
//    } else {
//        //显示保存过的
//        [_changeImg setBackgroundImage:image forState:UIControlStateNormal];
//    }
//}
//
//- (void)changeImage:(id)sender {
////    UIActionSheet *myActionSheet = [[UIActionSheet alloc]
////                                    initWithTitle:nil
////                                    delegate:self
////                                    cancelButtonTitle:@"取消"
////                                    destructiveButtonTitle:nil
////                                    otherButtonTitles: @"从相册选择", @"拍照",nil];
////    
////    [myActionSheet showInView:self.view];
//    [self openShare];
//}
//
//- (void)openShare
//{
//    YunShareView *shareView = [[YunShareView alloc] initWithTopBar:@[@{@"icon" : @"share_photo" , @"title" : @"相册"},
//                                                                     
//                                                                     @{@"icon" : @"share_camera" , @"title" : @"拍照"}]
//                                                         bottomBar:@[]
//                               ];
//    
//    shareView.delegate = self;
//    [shareView setTip:@"从下面方法获取图片"];
//    KLCPopup *popUp = [KLCPopup popupWithContentView:shareView showType:KLCPopupShowTypeBounceInFromBottom dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
//    [popUp showAtCenter:CGPointMake(kScreenWidth * 0.5, kScreenHeight - shareView.frame.size.height * 0.5) inView:self.view];
//}
//
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    switch (buttonIndex) {
//        case 0:
//            //从相册选择
//            [self LocalPhoto];
//            break;
//        case 1:
//            //拍照
//            [self takePhoto];
//            break;
//        default:
//            break;
//    }
//}
////从相册选择
//-(void)LocalPhoto{
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    
//    //资源类型为图片库
//    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    picker.delegate = self;
//    
//    //设置选择后的图片可被编辑
//    picker.allowsEditing = YES;
//    
//    [self presentViewController:picker animated:YES completion:nil];
//}
//
////拍照
//-(void)takePhoto{
//    //资源类型为照相机
//    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
//    
//    //判断是否有相机
//    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
//        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//        picker.delegate = self;
//        
//        //设置拍照后的图片可被编辑
//        picker.allowsEditing = YES;
//        
//        //资源类型为照相机
//        picker.sourceType = sourceType;
//        
//        [self presentViewController:picker animated:YES completion:nil];
//    } else {
//        NSLog(@"该设备无摄像头");
//    }
//}
//#pragma Delegate method UIImagePickerControllerDelegate
////图像选取器的委托方法，选完图片后回调该方法
//-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
//    
//    //当图片不为空时显示图片并保存图片
//    if (image != nil) {
//        //图片显示在界面上
//        [_changeImg setBackgroundImage:image forState:UIControlStateNormal];
//        
//        //以下是保存文件到沙盒路径下
//        //把图片转成NSData类型的数据来保存文件
//        NSData *data;
//        
//        //判断图片是不是png格式的文件
//        if (UIImagePNGRepresentation(image)) {
//            //返回为png图像。
//            data = UIImagePNGRepresentation(image);
//        } else {
//            //返回为JPEG图像。
//            data = UIImageJPEGRepresentation(image, 1.0);
//        }
//        //保存
//        [[NSFileManager defaultManager] createFileAtPath:self.imagePath contents:data attributes:nil];
//    }
//    //关闭相册界面
//    [picker dismissModalViewControllerAnimated:YES];
//}
//
//#pragma mark - YunShareViewDelegate -
//
//- (void)shareViewDidSelectViewInSection:(NSUInteger)section index:(NSUInteger)index
//{
//    YunLog(@"您点击了第%lu排的第%lu个按钮", section + 1, index + 1);
//    
//    switch (index) {
//        case 0:
//            //从相册选择
//            [self LocalPhoto];
//            break;
//        case 1:
//            //拍照
//            [self takePhoto];
//            break;
//        default:
//            break;
//    }
//}
//
///*
//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}
//*/
//
//@end
