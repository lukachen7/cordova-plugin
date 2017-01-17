//
//  PhotoSelectorViewController.m
//  bsl
//
//  Created by chenwj on 2017/1/12.
//
//

#import "PhotoSelectorViewController.h"
#import "UploadImageItemCell.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "TZImagePickerController.h"

@interface PhotoSelectorViewController ()<TZImagePickerControllerDelegate>

@property (nonatomic, strong) UICollectionView *contentColl;
@property (nonatomic, strong) UIButton *addImageBtn;
@property (nonatomic, strong) UIButton *submitBtn;
@property (nonatomic, strong) UIButton *cancelBtn;

@end

@implementation PhotoSelectorViewController{
    int _editIndex;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        _imageUrlList = [NSMutableArray array];
        self.maxPhotoNum = 9;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"图片选择器";
    
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:self.cancelBtn];
    
    [self.view addSubview:self.contentColl];
    [self.view addSubview:self.submitBtn];
}
-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"viewWillAppear");
}
-(void)viewDidDisappear:(BOOL)animated{
    NSLog(@"viewDidDisappear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/****属性设置 set get****/
-(void)setMaxPhotoNum:(int)maxPhotoNum{
    if (maxPhotoNum < 1) {
        _maxPhotoNum = 1;
        NSLog(@"maxPhotoNum 最小为1");
    }else if(maxPhotoNum > 9){
        _maxPhotoNum = 9;
        NSLog(@"maxPhotoNum 最大为9");
    }else{
        _maxPhotoNum = maxPhotoNum;
    }
}

/****public方法****/
-(void)setOriginalImages:(NSArray *)list{
    if (!_imageUrlList) {
        _imageUrlList = [NSMutableArray array];
    }
    for (NSString *url in list) {
        UploadImageModel *tmpImageModel = [[UploadImageModel alloc]init];
        tmpImageModel.url = url;
        tmpImageModel.data = nil;
        tmpImageModel.status = UploadImageStatusNormal;
        [_imageUrlList addObject:tmpImageModel];
    }
}

/****event 方法****/
-(void)addImageBtnPress:(UIButton *)sender{
//    [self presentViewController:[[TestViewController alloc]init] animated:YES completion:nil];
    if ([_imageUrlList count] < self.maxPhotoNum) {
        _editIndex = [_imageUrlList count]+1;
        [self showActionSheet];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"不能添加更多的照片" message:[NSString stringWithFormat:@"能选择最大照片数为%i",self.maxPhotoNum] delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
    }
    
}
-(void)submitBtnPress:(UIButton *)sender{
    [self.delegate photoSelectorDidSubmit:self];
    self.delegate = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)cancelButtonPress:(UIButton *)sender{
    self.delegate = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)longPressToDo:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.contentColl];
    
    NSIndexPath *indexPath = [self.contentColl indexPathForItemAtPoint:p];
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        _editIndex = indexPath.row;
        [self deleteImageByEditIndex];
    }
}

-(void)showActionSheet{
    UIActionSheet *myAS;
    if (_editIndex < [_imageUrlList count]){
        myAS = [[UIActionSheet alloc]
                initWithTitle:@"拍照/从相册选择"
                delegate:self
                cancelButtonTitle:@"取消"
                destructiveButtonTitle:nil
                otherButtonTitles:@"拍照上传",@"从相册选择",@"删除",nil];
    }else{
        myAS = [[UIActionSheet alloc]
                initWithTitle:@"拍照/从相册选择"
                delegate:self
                cancelButtonTitle:@"取消"
                destructiveButtonTitle:nil
                otherButtonTitles:@"拍照上传",@"从相册选择",nil];
    }
    
    [myAS showInView:self.view];
}
-(void)deleteImageByEditIndex{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除提示" message:@"确认要删除选择的图片？" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        NSLog(@"点击取消");
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(_imageUrlList && [_imageUrlList count]>_editIndex){
            [_imageUrlList removeObjectAtIndex:_editIndex];
            [self.contentColl reloadData];
        }
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

/****原生摄像头和图片选择器调用****/
-(void)shootPictureOrVideo{
    [self pickMediaFromSource:UIImagePickerControllerSourceTypeCamera];
}
-(void)selectExistingPictureOrVideo{
//    [self pickMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
    int canSelectNum = self.maxPhotoNum - [_imageUrlList count];
    if (_editIndex < [_imageUrlList count]) {
        canSelectNum = 1;
    }
    if (canSelectNum <= 0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"不能添加更多的照片" message:[NSString stringWithFormat:@"能选择最大照片数为%i",self.maxPhotoNum] delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
        return;
    }
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:canSelectNum columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    
    imagePickerVc.allowTakePicture = false;
    imagePickerVc.allowPickingVideo = false;
    imagePickerVc.allowPickingImage = true;
    imagePickerVc.allowPickingOriginalPhoto = false;
    imagePickerVc.allowPickingGif = false;
    imagePickerVc.sortAscendingByModificationDate = true;
    imagePickerVc.showSelectBtn = NO;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
    
}
-(void)pickMediaFromSource:(UIImagePickerControllerSourceType)sourceType{
    NSArray *mediaTypes=[UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if ([UIImagePickerController isSourceTypeAvailable:sourceType] &&[mediaTypes count]>0){
        UIImagePickerController *picker=[[UIImagePickerController alloc]init];
        picker.mediaTypes= mediaTypes;
        picker.delegate=self;
        picker.allowsEditing=false;
        picker.sourceType=sourceType;
        [self presentViewController:picker animated:true completion:NULL];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"调用摄像头或照片库失败" message:@"调用摄像头或照片库失败" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/****懒加载****/
- (UICollectionView *)contentColl{
    if (!_contentColl) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = -1;
        flowLayout.minimumLineSpacing = -1;
        _contentColl = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 0, kSCREEN_WIDTH-20, kSCREEN_HEIGHT-64) collectionViewLayout:flowLayout];
        _contentColl.delegate = self;
        _contentColl.dataSource = self;
        
        [_contentColl registerClass:[UploadImageItemCell class] forCellWithReuseIdentifier:@"CONTENT"];
//        [_contentColl registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ADDIMAGE"];
        [_contentColl registerClass:[UICollectionViewCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HEADER"];
//        [_contentColl registerClass:[UICollectionViewCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FOOTER"];
        _contentColl.backgroundColor = [UIColor whiteColor];
        
        UILongPressGestureRecognizer *longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
        longPressGr.minimumPressDuration = 1.0;
        longPressGr.delegate = self;
        longPressGr.delaysTouchesBegan = YES;
        [_contentColl addGestureRecognizer:longPressGr];
        
    }
    return _contentColl;
}
-(UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTintColor:[UIColor whiteColor]];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn sizeToFit];
        [_cancelBtn addTarget:self action:@selector(cancelButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}
-(UIButton *)addImageBtn{
    if (!_addImageBtn) {
        _addImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addImageBtn.backgroundColor = kVILightBlue;
        _addImageBtn.layer.cornerRadius = 5;
        [_addImageBtn setTitle:@"添加图片" forState:UIControlStateNormal];
        [_addImageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_addImageBtn addTarget:self action:@selector(addImageBtnPress:) forControlEvents:UIControlEventTouchUpInside];
        _addImageBtn.frame = CGRectMake(8, 10, self.contentColl.frame.size.width-16, 44);
    }
    return _addImageBtn;
}
-(UIButton *)submitBtn{
    if (!_submitBtn) {
        _submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _submitBtn.backgroundColor = kVILightBlue;
        _submitBtn.layer.cornerRadius = 5;
        [_submitBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_submitBtn addTarget:self action:@selector(submitBtnPress:) forControlEvents:UIControlEventTouchUpInside];
        _submitBtn.frame = CGRectMake(self.contentColl.frame.origin.x+8, kSCREEN_HEIGHT_FULL-64, self.contentColl.frame.size.width-16, 44);
    }
    return _submitBtn;
}

/****coll代理****/
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_imageUrlList count];
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CONTENT";
    if (_imageUrlList && indexPath.row < [_imageUrlList count]) {
        UploadImageItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        UploadImageModel *cellDic = _imageUrlList[indexPath.row];
        if (cellDic.data) {
            cell.uploadImage.image = cellDic.data;
        }else{
            [cell setImageUrl:cellDic.url];
        }
        [cell setStatus:cellDic.status];
        
        return cell;
    }
    return nil;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    int sizeW = round(collectionView.frame.size.width/3);
    return CGSizeMake(sizeW, sizeW);
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    int sizeW = collectionView.frame.size.width;
    int sizeH = 64;
    return CGSizeMake(sizeW, sizeH);
}
//-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
//    int sizeW = collectionView.frame.size.width;
//    int sizeH = 64;
//    return CGSizeMake(sizeW, sizeH);
//}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsZero;
}
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *tmpColl;
    if ([kind isEqual:UICollectionElementKindSectionHeader]){
        tmpColl = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"HEADER" forIndexPath:indexPath];
        
        [tmpColl.contentView addSubview:self.addImageBtn];
        
    }
//    else if([kind isEqual:UICollectionElementKindSectionFooter]){
//        tmpColl = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"FOOTER" forIndexPath:indexPath];
//        
//        [tmpColl.contentView addSubview:self.submitBtn];
//    }
    return tmpColl;
}
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    _editIndex = indexPath.row;
    [self showActionSheet];
    
}

/****actionSheet代理****/
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex != [actionSheet cancelButtonIndex]){
        switch (buttonIndex) {
            case 0:
                [self shootPictureOrVideo];
                break;
            case 1:
                [self selectExistingPictureOrVideo];
                break;
            case 2:
                [self deleteImageByEditIndex];
                break;
            default:
                break;
        }
    }
}
/****原生图片选择器代理****/
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"finish!");
    if ([info[UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage]){
        UIImage *chosenImage=info[UIImagePickerControllerOriginalImage];
        if (_editIndex < [_imageUrlList count]) {
            _imageUrlList[_editIndex] = [[UploadImageModel alloc]init];
            ((UploadImageModel*)_imageUrlList[_editIndex]).url = @"";
            ((UploadImageModel*)_imageUrlList[_editIndex]).data = chosenImage;
            ((UploadImageModel*)_imageUrlList[_editIndex]).status = UploadImageStatusNormal;
        }else{
            UploadImageModel *tmpImageModel = [[UploadImageModel alloc]init];
            tmpImageModel.url = @"";
            tmpImageModel.data = chosenImage;
            tmpImageModel.status = UploadImageStatusNormal;
            [_imageUrlList addObject:tmpImageModel];
        }
    }else if([info[UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeMovie]){
        NSLog(@"此处只能选择图片");
    }
    [picker dismissViewControllerAnimated:true completion:NULL];
    [_contentColl reloadData];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"cancel!");
    [picker dismissViewControllerAnimated:true completion:NULL];
}
/****TZImagePickerController代理****/
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    NSLog(@"finish!");

    if (_editIndex < [_imageUrlList count]) {
        _imageUrlList[_editIndex] = [[UploadImageModel alloc]init];
        ((UploadImageModel*)_imageUrlList[_editIndex]).url = @"";
        ((UploadImageModel*)_imageUrlList[_editIndex]).data = photos[0];
        ((UploadImageModel*)_imageUrlList[_editIndex]).status = UploadImageStatusNormal;
    }else{
        for (UIImage *tmpImage in photos) {
            UploadImageModel *tmpImageModel = [[UploadImageModel alloc]init];
            tmpImageModel.url = @"";
            tmpImageModel.data = tmpImage;
            tmpImageModel.status = UploadImageStatusNormal;
            [_imageUrlList addObject:tmpImageModel];
        }
        
    }

    [picker dismissViewControllerAnimated:true completion:NULL];
    [_contentColl reloadData];
}

@end
