//
//  UploadImageModel.m
//  DashuApp
//
//  Created by chenwj on 15/11/17.
//  Copyright (c) 2015年 dashuchina. All rights reserved.
//

#import "UploadImageModel.h"

@implementation UploadImageModel

-(instancetype)init{
    self = [super init];
    if (self) {
        _url = @"";
        _data = nil;
        _status = UploadImageStatusNormal;
    }
    return self;
}

@end
