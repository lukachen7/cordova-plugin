//
//  UploadImageItemCell.h
//  DashuUApp
//
//  Created by chenwj on 15/12/22.
//  Copyright © 2015年 dashuchina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UploadImageModel.h"

@interface UploadImageItemCell : UICollectionViewCell

@property(copy,nonatomic)NSString *imageUrl;
@property(strong,nonatomic)UIImageView *uploadImage;
-(void)setImageUrl:(NSString *)imageUrl;
-(void)setStatus:(UploadImageStatusType)status;

@end
