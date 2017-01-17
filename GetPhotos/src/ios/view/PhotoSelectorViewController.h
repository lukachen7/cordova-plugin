//
//  PhotoSelectorViewController.h
//  bsl
//
//  Created by chenwj on 2017/1/12.
//
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/UTCoreTypes.h>

#define kStatusAndNavH         64
#define kSCREEN_WIDTH          ([UIScreen mainScreen].bounds.size.width)
#define kSCREEN_HEIGHT         ([UIScreen mainScreen].bounds.size.height-kStatusAndNavH)
#define kSCREEN_HEIGHT_FULL    ([UIScreen mainScreen].bounds.size.height)
#define kVILightBlue           [UIColor colorWithRed:27/255.0 green:154/255.0 blue:245/255.0 alpha:1.0]

@class PhotoSelectorViewController;

@protocol photoSelectorDelegate

-(void)photoSelectorDidSubmit:(PhotoSelectorViewController *)content;

@end

@interface PhotoSelectorViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@property(assign,nonatomic)int maxPhotoNum;

@property(strong,nonatomic)id<photoSelectorDelegate> delegate;
@property(strong,nonatomic,readonly)NSMutableArray *imageUrlList;

-(void)setOriginalImages:(NSArray *)list;

@end
