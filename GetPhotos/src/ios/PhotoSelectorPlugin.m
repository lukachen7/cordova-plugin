//
//  PhotoSelectorPlugin.m
//  bsl
//
//  Created by chenwj on 2017/1/12.
//
//

#import "PhotoSelectorPlugin.h"
#import "PhotoSelectorViewController.h"
#import "UploadImageModel.h"
#import "ImageUtil.h"


@implementation PhotoSelectorPlugin{
    CDVInvokedUrlCommand *_commond;
    CGFloat _imageQuality;
}
- (void)pluginInitialize {
    NSString* tmpStr2 = [[self.commandDelegate settings] objectForKey:@"camera_usage_description"];
    NSLog(@"tmpstr:%@",tmpStr2);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //在这里获取应用程序Documents文件夹里的文件及文件夹列表
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [NSString stringWithFormat:@"%@/%@",[documentPaths firstObject],@"tmpphoto"];
    [fileManager changeCurrentDirectoryPath:documentDir];
    NSError *error = nil;
    NSArray *fileList = [[NSArray alloc] init];
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
    
    for (NSString *file in fileList){
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@",documentDir,file] error:NULL];
        });
    }
}

#pragma mark - 参数1为最大图片数默认1，参数2为压缩比例默认0.7
- (void)getPhotos:(CDVInvokedUrlCommand*)command{
    NSArray *arguments = [command arguments];
    if ([arguments count] < 2) {
        arguments = @[@1,@0.7];
    }
    NSNumber *maxPhotoNum = [arguments objectAtIndex:0];
    NSNumber *tmpQuality = [arguments objectAtIndex:1];
    _imageQuality = [tmpQuality floatValue];
    NSMutableArray *photoList = [NSMutableArray array];
    for (int i=2; i<[arguments count]; i++) {
        if ([arguments[i] isKindOfClass:[NSString class]]) {
            NSLog(@"图片URL：%@",arguments[i]);
            [photoList addObject:arguments[i]];
        }
    }
    
    _commond = command;
    PhotoSelectorViewController *photoSelector = [[PhotoSelectorViewController alloc]init];
    photoSelector.delegate = self;
    photoSelector.isPreview = YES;
    photoSelector.maxPhotoNum = [maxPhotoNum intValue];
    [photoSelector setOriginalImages:photoList];
    
    //设置导航样式
    UINavigationController *rootNav = [[UINavigationController alloc]initWithRootViewController:photoSelector];
    rootNav.navigationBar.barTintColor = kVILightBlue;
    rootNav.navigationBar.tintColor = [UIColor whiteColor];
    rootNav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.viewController presentViewController:rootNav animated:YES completion:nil];
}

#pragma mark - 同getPhotos，不压缩，不预览，参数1为最大图片数默认1
- (void)getPhotosSimple:(CDVInvokedUrlCommand*)command{
    NSArray *arguments = [command arguments];
    if ([arguments count] < 1) {
        arguments = @[@1];
    }
    NSNumber *maxPhotoNum = [arguments objectAtIndex:0];
    _imageQuality = 1.0;
    NSMutableArray *photoList = [NSMutableArray array];
    for (int i=1; i<[arguments count]; i++) {
        if ([arguments[i] isKindOfClass:[NSString class]]) {
            NSLog(@"图片URL：%@",arguments[i]);
            [photoList addObject:arguments[i]];
        }
    }
    
    _commond = command;
    PhotoSelectorViewController *photoSelector = [[PhotoSelectorViewController alloc]init];
    photoSelector.delegate = self;
    photoSelector.maxPhotoNum = [maxPhotoNum intValue];
    [photoSelector setOriginalImages:photoList];
    
    //设置导航样式
    UINavigationController *rootNav = [[UINavigationController alloc]initWithRootViewController:photoSelector];
    rootNav.navigationBar.barTintColor = kVILightBlue;
    rootNav.navigationBar.tintColor = [UIColor whiteColor];
    rootNav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.viewController presentViewController:rootNav animated:YES completion:nil];
}

-(void)photoSelectorDidSubmit:(PhotoSelectorViewController *)content{
    NSLog(@"delegate done");
    NSString *savePath = [self getSavePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSMutableArray *imageList = [NSMutableArray array];
    
    CDVPluginResult* pluginResult = nil;
    
    for (UploadImageModel *model in content.imageUrlList) {
        NSString *tmpFileFullName;
        //由于重选图片会把url设置为空，所以优先判断url
        if (!model.url || [model.url isEqualToString:@""]) {
            NSString *tmpFileName = [NSString stringWithFormat:@"%f.jpg",[[NSDate date] timeIntervalSince1970]];
            tmpFileFullName = [NSString stringWithFormat:@"%@/%@",savePath,tmpFileName];
            if ([fm createFileAtPath:tmpFileFullName contents:[ImageUtil imageWithImage:model.data scaledToSize:model.data.size andQuality:_imageQuality] attributes:nil]) {
                NSLog(@"保存文件：%@",tmpFileFullName);
                [imageList addObject:tmpFileFullName];
            }else{
                NSLog(@"保存文件失败");
            }
        }else{
            tmpFileFullName = model.url;
            [imageList addObject:tmpFileFullName];
        }
    }
    
    NSDictionary *jsonDic = @{@"photos":imageList};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *jsonStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:jsonStr];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:_commond.callbackId];
}

-(NSString *)getSavePath{
    //设置目录名
    NSString *tmpFilePath;
    NSString *tmpPathName = @"tmpphoto";
    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    BOOL isDirectory = NO;
    
    [fm changeCurrentDirectoryPath:urlStr];
    
    if (![fm fileExistsAtPath:tmpPathName isDirectory:&isDirectory]||!isDirectory) {
        NSError *err;
        //新建目录
        if (![fm createDirectoryAtPath:tmpPathName withIntermediateDirectories:YES attributes:nil error:&err]) {
            NSLog(@"err:%@",err);
            tmpFilePath = urlStr;
        }else{
            tmpFilePath = [urlStr stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/",tmpPathName]];
        }
    }else{
        tmpFilePath = [urlStr stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/",tmpPathName]];
    }
    return tmpFilePath;
}

@end
