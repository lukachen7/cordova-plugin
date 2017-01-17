//
//  UploadImageItemCell.m
//  DashuUApp
//
//  Created by chenwj on 15/12/22.
//  Copyright © 2015年 dashuchina. All rights reserved.
//

#import "UploadImageItemCell.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"

@implementation UploadImageItemCell{
    UIView *_bg;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor whiteColor];
        
        CGRect tmpFrame =self.contentView.bounds;
        _bg = [[UIView alloc]initWithFrame:CGRectMake(8, 8, tmpFrame.size.width-16, tmpFrame.size.height-16)];
        [self.contentView addSubview:_bg];
        
        _uploadImage = [[UIImageView alloc]initWithFrame:CGRectMake(10,10,tmpFrame.size.width-20,tmpFrame.size.height-20)];
        _uploadImage.backgroundColor = [UIColor lightGrayColor];
        _uploadImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_uploadImage];
    }
    return self;
}

-(void)setImageUrl:(NSString *)imageUrl{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^http"];
    if ([pred evaluateWithObject:imageUrl]){
         [_uploadImage sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
    }else{
        _uploadImage.image = [UIImage imageWithContentsOfFile:imageUrl];
    }
}
-(void)setStatus:(UploadImageStatusType)status{
    if (status == UploadImageStatusSuccess) {
        _bg.backgroundColor = [UIColor greenColor];
    }else if(status == UploadImageStatusFail){
        _bg.backgroundColor = [UIColor redColor];
    }else{
        _bg.backgroundColor = [UIColor whiteColor];
    }
}

@end
