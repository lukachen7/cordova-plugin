//
//  PhotoSelectorPlugin.h
//  bsl
//
//  Created by chenwj on 2017/1/12.
//
//

#import <Cordova/CDVPlugin.h>
#import "PhotoSelectorViewController.h"

@interface PhotoSelectorPlugin : CDVPlugin<photoSelectorDelegate>

- (void)getPhotos:(CDVInvokedUrlCommand*)command;
- (void)getPhotosSimple:(CDVInvokedUrlCommand*)command;
//- (void)photoSelectorDidSubmit:(PhotoSelectorViewController *)content;

@end
