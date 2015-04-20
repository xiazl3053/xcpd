//
//  XCUpdView.h
//  FreeIp
//
//  Created by 夏钟林 on 15/3/26.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol XCUpdViewDelegate <NSObject>

-(void)closeView;
-(void)addDeviceInfo;

@end

@interface XCUpdView : UIView

@property (nonatomic,strong) UITextField *txtField;
@property (nonatomic,assign) id<XCUpdViewDelegate> delegate;
@property (nonatomic,strong) UITextField *txtNewPwd;
@property (nonatomic,strong) UITextField *txtConPwd;


-(void)setTitle:(NSString *)strTitle;

-(void)setPlaceText:(NSString *)strPlace;

-(void)txtSetDelegate:(id<UITextFieldDelegate>)delegate;

-(void)addPassword;

-(void)closePassword;

@end
