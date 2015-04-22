//
//  XCAddDevViewController.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/25.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "XCAddDevViewController.h"
#import "ZBarSDK.h"
#import "Toast+UIView.h"
#import "UtilsMacro.h"
#import "UIView+Extension.h"
#import "XCUpdView.h"
#import "XCNotification.h"
#import "AddDeviceService.h"
#import "IQKeyboardManager.h"

@interface XCAddDevViewController ()<ZBarReaderViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,XCUpdViewDelegate,UITextFieldDelegate>
{
    int num;
    BOOL upOrdown;
    UIButton *btnPhoto;
    NSTimer *timer;
    CGFloat fVWidth,fVHeight;
    AddDeviceService *addService;
}
@property (nonatomic,strong) XCUpdView *addView;
@property (nonatomic,strong) UIImageView *line;
@property (nonatomic,strong) ZBarReaderView *readerView;
@property (nonatomic,strong) UIImagePickerController *imagePicker;


@end

@implementation XCAddDevViewController

-(void)dealloc
{
    [_readerView removeFromSuperview];
    _readerView = nil;
    [_line removeFromSuperview];
    
    _line = nil;
    [_imagePicker removeFromParentViewController];
    _imagePicker = nil;
    
    [timer invalidate];
    timer = nil;
    [btnPhoto removeFromSuperview];
    btnPhoto = nil;
}

-(void)navBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)loadView
{
    if (IOS_SYSTEM_8) {
        fVHeight = kScreenSourchHeight;
        fVWidth = kScreenSourchWidth;
    }
    else
    {
        fVWidth = kScreenSourchHeight;
        fVHeight = kScreenSourchWidth;
    }
    self.view = [[UIView alloc] initWithFrame:Rect(0, 0, fVWidth, fVHeight)];
}

-(void)enterAddTextController
{
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self initUIView];
}

- (void)initUIView
{
    CGFloat fWidth,fHeight;

    UIView *headView = [[UIView alloc] initWithFrame:Rect(0, 0,fVWidth,64)];
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(navBack) forControlEvents:UIControlEventTouchUpInside];
    [btnBack setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    [headView addSubview:btnBack];
    [self.view addSubview:headView];
    
    btnBack.frame = Rect(10, 10, 44, 44);
    
    
    [headView setBackgroundColor:RGB(15, 173, 225)];
    UILabel *lblName = [[UILabel alloc] initWithFrame:Rect(50, 20, fVWidth-100, 20)];
    [lblName setFont:XCFONT(20.0)];
    [lblName setTextColor:RGB(255, 255,255)];
    [lblName setText:XCLocalized(@"devDetails")];
    [lblName setTextAlignment:NSTextAlignmentCenter];
    [headView addSubview:lblName];

    
    
    _readerView = [[ZBarReaderView alloc] init];
    _readerView.frame = Rect(0,64,fVWidth,fVHeight-64);
    [self.view addSubview:_readerView];
    _readerView.readerDelegate = self;
    [_readerView setAllowsPinchZoom:YES];
    [_readerView willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight duration:1.0f];
    
    ZBarImageScanner * scanner = _readerView.scanner;
    [scanner setSymbology:ZBAR_I25
                   config:ZBAR_CFG_ENABLE
                       to:0];
    _readerView.torchMode = 0;
    
    UIView *view = [[UIView alloc] initWithFrame:Rect(0, 0,fVWidth, 170)];//上
    [view setBackgroundColor:[UIColor blackColor]];
    [_readerView addSubview:view];
    view.alpha = 0.6f;
    
    UIView *view1 = [[UIView alloc] initWithFrame:Rect(0,170,330,_readerView.height-170)];//左
    [view1 setBackgroundColor:[UIColor blackColor]];
    [_readerView addSubview:view1];
    view1.alpha = 0.6f;
    
    UIView *view2 = [[UIView alloc] initWithFrame:Rect(_readerView.width-330,170,364,364)];//右
    [view2 setBackgroundColor:[UIColor blackColor]];
    [_readerView addSubview:view2];
    view2.alpha = 0.6f;
    
    UIView *view3 = [[UIView alloc] initWithFrame:Rect(330,_readerView.height-170,self.view.width-330,170)];//下
    [view3 setBackgroundColor:[UIColor blackColor]];
    [_readerView addSubview:view3];
    view3.alpha = 0.6f;
    
    UIButton *btnInput = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnInput setImage:[UIImage imageNamed:@"input"] forState:UIControlStateNormal];
    [btnInput setImage:[UIImage imageNamed:@"input_h"] forState:UIControlStateHighlighted];
    [btnInput addTarget:self action:@selector(enterInputView) forControlEvents:UIControlEventTouchUpInside];
    [_readerView addSubview:btnInput];
    btnInput.frame = Rect(118,_readerView.height/2-47, 94, 94);
    [btnInput.layer setCornerRadius:47];
    [btnInput.layer setMasksToBounds:YES];
    
    UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSearch setImage:[UIImage imageNamed:@"pic_scanf"] forState:UIControlStateNormal];
    [btnSearch setImage:[UIImage imageNamed:@"pic_scanf_h"] forState:UIControlStateHighlighted];
    [btnSearch addTarget:self action:@selector(scanQRCode) forControlEvents:UIControlEventTouchUpInside];
    [_readerView addSubview:btnSearch];
    btnSearch.frame = Rect(812, _readerView.height/2-47, 94, 94);
    [btnSearch.layer setMasksToBounds:YES];
    [btnSearch.layer setCornerRadius:47];
    
    
    CGRect scanMaskRect = CGRectMake(330, 170, 364,364);
    CGRect newRect = [self getScanCrop:scanMaskRect readerViewBounds:_readerView.bounds];
    DLog(@"newRect:%@",NSStringFromCGRect(newRect));
    _readerView.scanCrop = newRect;
    UIImageView * image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pick_bg.png"]];
    image.frame = scanMaskRect;
    
    [_readerView addSubview:image];
    
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, scanMaskRect.size.width-20, 2)];
    _line.image = [UIImage imageNamed:@"line.png"];
    [image addSubview:_line];
    //   定时器，设定时间过1.5秒，
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
//    _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = NO;
    
//    btnPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btnPhoto setImage:[UIImage imageNamed:XCLocalized(@"qrcode")] forState:UIControlStateNormal];
//    [btnPhoto setImage:[UIImage imageNamed:XCLocalized(@"qrcode_h")] forState:UIControlStateHighlighted];
//    [self.view addSubview:btnPhoto];
//    btnPhoto.frame = Rect(kScreenWidth/2-112.5,self.readerView.frame.origin.y + self.readerView.frame.size.height/2.0+145 ,225.5,75.5);
//    [btnPhoto addTarget:self action:@selector(scanQRCode) forControlEvents:UIControlEventTouchUpInside];
   
    _addView = [[XCUpdView alloc] initWithFrame:Rect(256,102,500,500)];
    [_readerView addSubview:_addView];
    [_addView setTitle:XCLocalized(@"inputNO")];
    _addView.hidden = YES;
    _addView.txtField.delegate = self;
    _addView.txtField.tag = 30888;
    _addView.delegate = self;
}

-(void)enterInputView
{
     [self.readerView stop];
    _addView.hidden = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)animation1
{
    if (upOrdown == NO)
    {
        num ++;
        _line.frame = CGRectMake(10, 10+2*num, _line.frame.size.width, 2);
        if (2*num == 240)
        {
            upOrdown = YES;
        }
    }
    else
    {
        num --;
        _line.frame = CGRectMake(10, 10+2*num, _line.frame.size.width, 2);
        if (num == 0)
        {
            upOrdown = NO;
        }
    }
}

-(CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)readerViewBounds
{
    CGFloat x,y,width,height;
    
    x = rect.origin.x / readerViewBounds.size.width;
    y = rect.origin.y / readerViewBounds.size.height;
    width = rect.size.width / readerViewBounds.size.width;
    height = rect.size.height / readerViewBounds.size.height;
    return CGRectMake(x, y, width, height);
}
- (NSString *)findQRCode:(UIImage *)inputUIImage
{
    
    ZBarReaderController *imageReader = [ZBarReaderController new];
    
    [imageReader.scanner setSymbology: ZBAR_I25
                               config: ZBAR_CFG_ENABLE
                                   to: 0];
    
    id <NSFastEnumeration> results = [imageReader scanImage:inputUIImage.CGImage];
    
    ZBarSymbol *sym = nil;
    for(sym in results) {
        break;
    } // Get only last symbol
    
    if (!sym)
    {
        [self.view makeToast:XCLocalized(@"qrResult")];
        return nil;
    }
    //先禁用跳转功能
    
    return sym.data;
}


-(void)scanQRCode
{
    [self presentViewController:_imagePicker animated:YES completion:^{
    }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* image = nil;
    image = [info objectForKey: @"UIImagePickerControllerOriginalImage"];
    [self dismissViewControllerAnimated:YES completion:^{}];
    [self findQRCode:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}



-(void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{
    NSString *codeData = [[NSString alloc] init];;
    for (ZBarSymbol *sym in symbols) {
        codeData = sym.data;
        break;
    }
    //先禁用跳转功能
    DLog(@"%@", codeData);
    [_addView.txtField setText:codeData];
    [self enterInputView];
    [self addBlock];
}

-(void)addBlock
{
    __weak XCAddDevViewController *__weakSelf = self;
    if (addService==nil) {
        addService = [[AddDeviceService alloc] init];
    }
    addService.addDeviceBlock = ^(int nStatus)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [__weakSelf.addView hideToastActivity];
        });
        NSString *strMsg = nil;
        switch (nStatus)
        {
            case 1:
                strMsg = XCLocalized(@"addOk");
                break;
            case 45:
                strMsg = XCLocalized(@"bindingError");
                break;
            case 44:
                strMsg = XCLocalized(@"serialError");
                break ;
            case 64:
                strMsg = XCLocalized(@"serialError");
                break;
            case -999:
                strMsg = XCLocalized(@"addTimeout");
                break;
            default:
                strMsg = XCLocalized(@"ServerException");
                break;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [__weakSelf.addView makeToast:strMsg];
        });
        if(nStatus==1)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,2*NSEC_PER_SEC), dispatch_get_main_queue(),^{
                __weakSelf.addView.hidden = YES;
                [__weakSelf closeView];
            });
        }
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [__weakSelf.addView makeToastActivity];
    });
    
    [addService requestAddDevice:_addView.txtField.text auth:@"ABCDEF"];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.readerView start];
    DLog(@"start");
}
-(void)viewDidDisappear:(BOOL)animated
{
    [self.readerView stop];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

-(BOOL)shouldAutorotate
{
    return YES;
}
//
-(BOOL)prefersStatusBarHidden
{
    return YES;

}



-(void)addDeviceInfo
{
    [self addBlock];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addXCDeviceInfo) name:NSKEY_BOARD_RETURN_VC object:nil];
}

-(void)addXCDeviceInfo
{
    //添加
    if([_addView.txtField.text length]<13)
    {
        [_addView.txtField resignFirstResponder];
    }
    else
    {
        [self addBlock];
    }
}
-(void)closeView
{
    [_readerView start];
    [_addView.txtField setText:@""];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField.text length] >= 13 )//当字符串长度到13个的时候，只有删除按钮可以使用
    {
        NSString *emailRegex = @"[0-9]";//正则表达式0-9
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        BOOL bFlag = [emailTest evaluateWithObject:string];//检测字符内容
        if(bFlag)
        {
            return NO;
        }
        else
        {
            return YES;
        }
        emailTest = nil;
        emailRegex = nil;
    }
    return YES;
}


@end
