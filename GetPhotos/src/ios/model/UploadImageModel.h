//
//  UploadImageModel.h
//  DashuApp
//
//  Created by chenwj on 15/11/17.
//  Copyright (c) 2015年 dashuchina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef enum {
    UploadImageStatusNormal,
    UploadImageStatusSuccess,
    UploadImageStatusFail
}UploadImageStatusType;

@interface UploadImageModel : NSObject

@property(copy,nonatomic)NSNumber *dynamicColumnId;
@property(copy,nonatomic)NSString *url;
@property(strong,nonatomic)UIImage *data;
@property(assign,nonatomic)UploadImageStatusType status;

@end
