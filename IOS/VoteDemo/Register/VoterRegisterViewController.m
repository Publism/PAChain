

#import "VoterRegisterViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import <YYLabel.h>
#import <YYText.h>

@interface VoterRegisterViewController ()<UITextFieldDelegate,PopSignatureViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    UILabel *titleLab;
    //first View
    UIScrollView *firstView;
    UIImageView *signatureImage;
    NSString *signatureImageID;
    
    
    UIView *fourthView;
    
    //second view
    UIScrollView *secondView;
    UIImageView *frontImage;
    UIImageView *backImage;
    NSString *driverFrontImageID;
    NSString *driverBackImageID;
    
    //thirdview
    UIView *thirdView;
    YYLabel *thirdViewTipLab;
    UIButton *faceNextBtn;
    NSString *userImageID;
    UIImage *userImage;
    
    //fourthView
    CustomTextfield *codeTF;
    UIButton *fourthNextBtn;
    UILabel *requestTip;
    UIButton *requestbtn;
    
}
@property (nonatomic,retain)DropListView *licenseListView;
@property (nonatomic,retain)DropListView *stateListView;
@property (nonatomic,retain)DropListView *countyListView;
@property (nonatomic,retain)CustomTextfield *firstNameTF;
@property (nonatomic,retain)CustomTextfield *lastNameTF;
@property (nonatomic,retain)CustomTextfield *middleNameTF;
@property (nonatomic,retain)CustomTextfield *nameSuffixTF;
@property (nonatomic,retain)CustomTextfield *numberTF;
@property (nonatomic,retain)CustomTextfield *emailTF;
@property (nonatomic,retain)CustomTextfield *addressTF;
@property (nonatomic,retain)CustomTextfield *precintNO;
@property(retain,nonatomic) UISwitch * touchIDSwitch;
@property (nonatomic,assign)BOOL frontScan;
@property (nonatomic,assign)BOOL backScan;
@property (nonatomic,copy)NSString *encryKey;
@end

@implementation VoterRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _frontScan = NO;
    _backScan = NO;
    if ([_step isEqualToString:@"1"]) {
        self.view.backgroundColor = [UIColor whiteColor];
        [self firstView];
    }else if ([_step isEqualToString:@"2"]){
        self.view.backgroundColor = [UIColor whiteColor];
        [self secondView];
    }else if ([_step isEqualToString:@"3"]){
        self.view.backgroundColor = [UIColor whiteColor];
        [self thirdView];
    }else{
        self.view.backgroundColor = [UIColor purpleColor];
        [self fourthView];
    }
}

#pragma mark - first
- (UIView *)firstView{
    if (!firstView) {
        firstView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, FUll_VIEW_WIDTH, FUll_VIEW_HEIGHT-Height_NavBar)];
        firstView.backgroundColor = [UIColor whiteColor];
        firstView.bounces = NO;
        firstView.userInteractionEnabled = YES;
        firstView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:firstView];
        
        UITapGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(firstViewClick)];
        [firstView addGestureRecognizer:viewTap];
        
        CGFloat allWidth = (FUll_VIEW_WIDTH-YWIDTH_SCALE(152))/2;
        
        titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, YHEIGHT_SCALE(68), FUll_VIEW_WIDTH, YHEIGHT_SCALE(40))];
        titleLab.text = @"First, you need to verify identity";
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(36)];
        [firstView addSubview:titleLab];
        
        
        for (int i = 0; i < 4; i ++) {
            UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake((FUll_VIEW_WIDTH-(YWIDTH_SCALE(140)*3+YWIDTH_SCALE(40)))/2+YWIDTH_SCALE(140)*i, CGRectGetMaxY(titleLab.frame)+YHEIGHT_SCALE(48), YWIDTH_SCALE(40), YWIDTH_SCALE(40))];
            if (i <= 0) {
                img.image = [UIImage imageNamed:@"in"];
            }else{
                img.image = [UIImage imageNamed:@"out"];
            }
            img.layer.cornerRadius = YWIDTH_SCALE(40)/2;
            img.layer.masksToBounds = YES;
            [firstView addSubview:img];
            
            if (i < 3) {
                UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(img.frame)+YWIDTH_SCALE(10), img.y+img.height/2-YHEIGHT_SCALE(1), YWIDTH_SCALE(80), YHEIGHT_SCALE(2))];
                line.backgroundColor = [UIColor grayColor];
                [firstView addSubview:line];
            }
        }
        
        NSArray *stateInfoArray = [StateInfo getStateArray];
        NSMutableArray *stateArray = [[NSMutableArray alloc]init];
        DropdownListItem *item = [[DropdownListItem alloc] initWithItem:@"0123" itemName:@"Your State"];
        [stateArray addObject:item];
        for (int i = 0; i < stateInfoArray.count; i ++) {
            StateInfo *info = stateInfoArray[i];
            DropdownListItem *item = [[DropdownListItem alloc] initWithItem:[NSString stringWithFormat:@"%@",info.code] itemName:info.name];
            [stateArray addObject:item];
        }
        
        _stateListView = [[DropListView alloc] initWithDataSource:stateArray];
        _stateListView.frame = CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(titleLab.frame)+YHEIGHT_SCALE(40)+YHEIGHT_SCALE(48)*2, allWidth, YHEIGHT_SCALE(72));
        _stateListView.selectedIndex = 0;
        _stateListView.layer.borderWidth = 1;
        _stateListView.layer.borderColor = HexRGBAlpha(0x888888, 1).CGColor;
        _stateListView.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
        _stateListView.textColor = [UIColor blackColor];
        [firstView addSubview:_stateListView];
        
        __weak typeof(self) weakSelf = self;
        [_stateListView setDropdownListViewSelectedBlock:^(DropListView *dropdownListView) {
            NSArray *array = [CountyInfo getCountyInfoWithStateName:dropdownListView.selectedItem.itemId];
            NSMutableArray *countyArray = [[NSMutableArray alloc]init];
            DropdownListItem *itema = [[DropdownListItem alloc]initWithItem:@"0123" itemName:@"Your County"];
            [countyArray addObject:itema];
            for (CountyInfo *info in array) {
                DropdownListItem *item = [[DropdownListItem alloc]initWithItem:info.code itemName:info.name];
                [countyArray addObject:item];
            }
            weakSelf.countyListView.dataSource = countyArray;
            weakSelf.countyListView.selectedIndex = 0;
        }];
        
        NSArray *countyInfoArray = [CountyInfo getCountyArray];
        NSMutableArray *countyArray = [[NSMutableArray alloc]init];
        DropdownListItem *item2 = [[DropdownListItem alloc]initWithItem:@"0123" itemName:@"Your County"];
        [countyArray addObject:item2];
        for (CountyInfo *info in countyInfoArray) {
            DropdownListItem *item = [[DropdownListItem alloc]initWithItem:info.code itemName:info.name];
            [countyArray addObject:item];
        }
        _countyListView = [[DropListView alloc] initWithDataSource:countyArray];
        _countyListView.frame = CGRectMake(CGRectGetMaxX(_stateListView.frame)+YWIDTH_SCALE(36), _stateListView.y, allWidth, YHEIGHT_SCALE(72));
        _countyListView.selectedIndex = 0;
        _countyListView.layer.borderWidth = 1;
        _countyListView.layer.borderColor = HexRGBAlpha(0x888888, 1).CGColor;
        _countyListView.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
        _countyListView.textColor = [UIColor blackColor];
        [firstView addSubview:_countyListView];
        

        [_countyListView setDropdownListViewSelectedBlock:^(DropListView *dropdownListView) {
            
        }];
        
        _precintNO = [[CustomTextfield alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(_stateListView.frame)+YHEIGHT_SCALE(28), allWidth, YHEIGHT_SCALE(72))];
        _precintNO.insetX = 10;
        _precintNO.delegate = self;
        _precintNO.placeholder = @"Precinct";
        _precintNO.returnKeyType = UIReturnKeyNext;
        [firstView addSubview:_precintNO];
        
        UIButton *questionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        questionBtn.frame = CGRectMake(CGRectGetMaxX(_stateListView.frame)+YWIDTH_SCALE(36), _precintNO.y+_precintNO.height/2-YHEIGHT_SCALE(20), YWIDTH_SCALE(40), YHEIGHT_SCALE(40));
        [questionBtn setBackgroundImage:[UIImage imageNamed:@"data"] forState:UIControlStateNormal];
        [questionBtn addTarget:self action:@selector(questionBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [firstView addSubview:questionBtn];
        
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(_precintNO.frame)+YHEIGHT_SCALE(44), FUll_VIEW_WIDTH-YWIDTH_SCALE(60), YHEIGHT_SCALE(40))];
        lab.text = @"Please fill out the form blow";
        lab.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(32)];
        [firstView addSubview:lab];
        
        _lastNameTF = [[CustomTextfield alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(lab.frame)+YHEIGHT_SCALE(30), allWidth, YHEIGHT_SCALE(72))];
        _lastNameTF.insetX = 10;
        _lastNameTF.delegate = self;
        _lastNameTF.placeholder = @"Last Name";
        _lastNameTF.returnKeyType = UIReturnKeyNext;
        [firstView addSubview:_lastNameTF];
        
        _firstNameTF = [[CustomTextfield alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(16)+FUll_VIEW_WIDTH/2, CGRectGetMaxY(lab.frame)+YHEIGHT_SCALE(30), allWidth, YHEIGHT_SCALE(72))];
        _firstNameTF.insetX = 10;
        _firstNameTF.placeholder = @"First Name";
        _firstNameTF.delegate = self;
        _firstNameTF.returnKeyType = UIReturnKeyNext;
        [firstView addSubview:_firstNameTF];
        
        _middleNameTF = [[CustomTextfield alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(_firstNameTF.frame)+YHEIGHT_SCALE(28), allWidth, YHEIGHT_SCALE(72))];
        _middleNameTF.insetX = 10;
        _middleNameTF.delegate = self;
        _middleNameTF.placeholder = @"Middle Name";
        _middleNameTF.returnKeyType = UIReturnKeyNext;
        [firstView addSubview:_middleNameTF];
        
        _nameSuffixTF = [[CustomTextfield alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(16)+FUll_VIEW_WIDTH/2, CGRectGetMaxY(_firstNameTF.frame)+YHEIGHT_SCALE(28), allWidth, YHEIGHT_SCALE(72))];
        _nameSuffixTF.insetX = 10;
        _nameSuffixTF.delegate = self;
        _nameSuffixTF.placeholder = @"Name Suffix";
        _nameSuffixTF.returnKeyType = UIReturnKeyNext;
        [firstView addSubview:_nameSuffixTF];
        
        _numberTF = [[CustomTextfield alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(_middleNameTF.frame)+YHEIGHT_SCALE(28), FUll_VIEW_WIDTH-YWIDTH_SCALE(120), YHEIGHT_SCALE(72))];
        _numberTF.insetX = 10;
        _numberTF.delegate = self;
        _numberTF.placeholder = @"Enter your mobile number";
        _numberTF.returnKeyType = UIReturnKeyNext;
        _numberTF.keyboardType = UIKeyboardTypeNumberPad; 
        [firstView addSubview:_numberTF];
        
        _emailTF = [[CustomTextfield alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(_numberTF.frame)+YHEIGHT_SCALE(28), FUll_VIEW_WIDTH-YWIDTH_SCALE(120), YHEIGHT_SCALE(72))];
        _emailTF.insetX = 10;
        _emailTF.delegate = self;
        _emailTF.placeholder = @"Enter your Email";
        _emailTF.returnKeyType = UIReturnKeyNext;
        [firstView addSubview:_emailTF];
        
        _addressTF = [[CustomTextfield alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(_emailTF.frame)+YHEIGHT_SCALE(28), FUll_VIEW_WIDTH-YWIDTH_SCALE(120), YHEIGHT_SCALE(72))];
        _addressTF.insetX = 10;
        _addressTF.delegate = self;
        _addressTF.placeholder = @"Enter your Address";
        _addressTF.returnKeyType = UIReturnKeyDone;
        [firstView addSubview:_addressTF];
        
        UILabel *signatureLab = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(_addressTF.frame)+YHEIGHT_SCALE(28), FUll_VIEW_WIDTH-YWIDTH_SCALE(120), YHEIGHT_SCALE(40))];
        signatureLab.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
        signatureLab.text = @"Please affix your signature.";
        [firstView addSubview:signatureLab];
        
        UIView *signatureView = [[UIView alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(signatureLab.frame)+YHEIGHT_SCALE(10), FUll_VIEW_WIDTH-YWIDTH_SCALE(120), YHEIGHT_SCALE(400))];
        signatureView.backgroundColor = [UIColor whiteColor];
        signatureView.layer.borderWidth = 1;
        signatureView.layer.borderColor = [UIColor grayColor].CGColor;
        [firstView addSubview:signatureView];
        
        signatureImage = [[UIImageView alloc]initWithFrame:CGRectMake((signatureView.width-(signatureView.height-YHEIGHT_SCALE(20))*414/297)/2, YHEIGHT_SCALE(20), (signatureView.height-YHEIGHT_SCALE(20))*414/297, signatureView.height-YHEIGHT_SCALE(20))];
        signatureImage.backgroundColor = [UIColor whiteColor];
        [signatureView addSubview:signatureImage];
        signatureImage.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(signatureMethod)];
        [signatureImage addGestureRecognizer:tap];
        
        UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        nextBtn.frame = CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(signatureView.frame)+YHEIGHT_SCALE(28), FUll_VIEW_WIDTH-YWIDTH_SCALE(120), YHEIGHT_SCALE(72));
        [nextBtn setBackgroundColor:HexRGBAlpha(0x0390fc, 1)];
        [nextBtn setTitle:@"Next" forState:UIControlStateNormal];
        [nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [firstView addSubview:nextBtn];
        
        firstView.contentSize = CGSizeMake(FUll_VIEW_WIDTH, CGRectGetMaxY(nextBtn.frame)+YHEIGHT_SCALE(20));
    }
    return firstView;
}

- (void)questionBtnClick{
    if (![_stateListView.selectedItem.itemName isEqualToString:@"Your State"] && ![_countyListView.selectedItem.itemName isEqualToString:@"Your County"]) {
        StateInfo *staInfo = [StateInfo getStateInfoWithName:_stateListView.selectedItem.itemName];
        RegisterLinkModel *model = [RegisterLinkModel getRegisterLinkWithState:staInfo.shortName withCounty:_countyListView.selectedItem.itemId];
        if (model.RegisterLink.length > 0) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.RegisterLink] options:@{} completionHandler:^(BOOL success) {
                    
                }];
            } else {

            }
        }
    }else{
        [VoteDemoHUD setHUD:@"Please select your state and county first, so that we can help you quickly jump to your local elections official website."];
    }
}

- (void)firstViewClick{
    for (UITextField *tf in firstView.subviews) {
        if ([tf isKindOfClass:[UITextField class]]) {
            [tf resignFirstResponder];
        }
    }
}

- (void)nextBtnClick{
    if ([_stateListView.selectedItem.itemId isEqualToString:@"0123"]) {
        [VoteDemoHUD setHUD:@"Please select your state"];
    }else if ([_countyListView.selectedItem.itemId isEqualToString:@"0123"]){
        [VoteDemoHUD setHUD:@"Please select your county"];
    }else if (_firstNameTF.text.length <= 0){
        [VoteDemoHUD setHUD:@"Please enter your firstName"];
    }else if (_middleNameTF.text.length <= 0){
        [VoteDemoHUD setHUD:@"Please enter your middleName"];
    }else if (_lastNameTF.text.length <= 0){
        [VoteDemoHUD setHUD:@"Please enter your lastName"];
    }else if (_nameSuffixTF.text.length <= 0){
        [VoteDemoHUD setHUD:@"Please enter your name suffix"];
    }else if (_numberTF.text.length <= 0){
        [VoteDemoHUD setHUD:@"Please enter your mobile number"];
    }else if (_addressTF.text.length <= 0){
        [VoteDemoHUD setHUD:@"Please enter your address"];
    }else if (_precintNO.text.length <= 0){
        [VoteDemoHUD setHUD:@"Please enter your precinct no."];
    }else if (_emailTF.text.length <= 0){
        [VoteDemoHUD setHUD:@"Please enter your email"];
    }else if (![CustomMethodTool validateEmail:_emailTF.text]){
        [VoteDemoHUD setHUD:@"Email not correct"];
    }else{
        NSData *imgData = UIImageJPEGRepresentation(signatureImage.image, 0.1f);
        NSString *imgStr = [imgData base64EncodedStringWithOptions:0];
        [self uploadImage:imgStr withIndex:1 withDriverLicenseFront:NO];
    }
}

- (void)signatureMethod{
    PopSignatureView *socialSingnatureView = [[PopSignatureView alloc] initWithFrame:CGRectMake(0, 0, FUll_VIEW_WIDTH, FUll_VIEW_HEIGHT)];
    socialSingnatureView.delegate = self;
    [socialSingnatureView show];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isEqual:_precintNO]) {
        [_precintNO resignFirstResponder];
        [_lastNameTF becomeFirstResponder];
    }else if ([textField isEqual:_lastNameTF]) {
        [_lastNameTF resignFirstResponder];
        [_firstNameTF becomeFirstResponder];
    }else if ([textField isEqual:_firstNameTF]){
        [_firstNameTF resignFirstResponder];
        [_middleNameTF becomeFirstResponder];
    }else if ([textField isEqual:_middleNameTF]){
        [_middleNameTF resignFirstResponder];
        [_nameSuffixTF becomeFirstResponder];
    }else if ([textField isEqual:_nameSuffixTF]){
        [_nameSuffixTF resignFirstResponder];
        [_numberTF becomeFirstResponder];
    }else if ([textField isEqual:_numberTF]){
        [_numberTF resignFirstResponder];
        [_emailTF becomeFirstResponder];
    }else if ([textField isEqual:_emailTF]){
        [_emailTF resignFirstResponder];
        [_addressTF becomeFirstResponder];
    }else if ([textField isEqual:_addressTF]){
        [_addressTF resignFirstResponder];
    }
    return YES;
}

#pragma mark - SocialSignatureViewDelegate
- (void)onSubmitBtn:(UIImage *)signatureImg {
    signatureImage.image = signatureImg;
}

#pragma mark - second
- (UIView *)secondView{
    if (!secondView) {
        secondView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, FUll_VIEW_WIDTH, FUll_VIEW_HEIGHT-Height_NavBar)];
        secondView.backgroundColor = [UIColor whiteColor];
        secondView.bounces = NO;
        [self.view addSubview:secondView];
        
        titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, YHEIGHT_SCALE(68), FUll_VIEW_WIDTH, YHEIGHT_SCALE(40))];
        titleLab.text = @"Scan Document";
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(36)];
        [secondView addSubview:titleLab];
        
        for (int i = 0; i < 4; i ++) {
            UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake((FUll_VIEW_WIDTH-(YWIDTH_SCALE(140)*3+YWIDTH_SCALE(40)))/2+YWIDTH_SCALE(140)*i, CGRectGetMaxY(titleLab.frame)+YHEIGHT_SCALE(48), YWIDTH_SCALE(40), YWIDTH_SCALE(40))];
            if (i < 1) {
                img.image = [UIImage imageNamed:@"box"];
            }else if (i == 1){
                img.image = [UIImage imageNamed:@"in"];;
            }else{
                img.image = [UIImage imageNamed:@"out"];;
            }
            img.layer.cornerRadius = YWIDTH_SCALE(40)/2;
            img.layer.masksToBounds = YES;
            [secondView addSubview:img];
            
            if (i < 3) {
                UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(img.frame)+YWIDTH_SCALE(10), img.y+img.height/2-YHEIGHT_SCALE(1), YWIDTH_SCALE(80), YHEIGHT_SCALE(2))];
                if (i <= 0) {
                    line.backgroundColor = HexRGBAlpha(0x075a93, 1);
                }else{
                    line.backgroundColor = HexRGBAlpha(0xc2c2c2, 1);
                }
                [secondView addSubview:line];
            }
        }
        
        NSString *noinfo =@"Please permit us to turn on camera to complete scan document.  YES  /  NO  ";
        YYLabel *tipLab = [[YYLabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(titleLab.frame)+YHEIGHT_SCALE(40)+YHEIGHT_SCALE(48)*2, FUll_VIEW_WIDTH-YWIDTH_SCALE(120), YHEIGHT_SCALE(80))];
        tipLab.textColor = [UIColor blackColor];
        NSMutableAttributedString *one = [[NSMutableAttributedString alloc] initWithString:noinfo];
        one.yy_font =[UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
        NSRange range = [noinfo rangeOfString:@"  YES  "];
        [one yy_setTextHighlightRange:range color:HexRGBAlpha(0x0090ff, 1) backgroundColor:[UIColor whiteColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            tipLab.hidden = YES;
            [self configScanView];
        }];
        NSRange range2 = [noinfo rangeOfString:@"  NO  "];
        [one yy_setTextHighlightRange:range2 color:HexRGBAlpha(0x0090ff, 1) backgroundColor:[UIColor whiteColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Your identity verification has not been completed. Are you sure to exit?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"No, continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            tipLab.hidden = YES;
            [self configScanView];
            }];

            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Yes, exit now" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (self.ReturnBlock) {
                    self.ReturnBlock(YES);
                }
            }];
            [alertController addAction:action];
            [alertController addAction:action1];
            [self presentViewController:alertController animated:YES completion:nil];
        }];
        tipLab.attributedText = one;
        tipLab.numberOfLines = 0;
        tipLab.userInteractionEnabled = YES;
        [secondView addSubview:tipLab];
    }
    return secondView;
}

- (void)configScanView{
    
    NSMutableArray *stateArray = [[NSMutableArray alloc]init];
    DropdownListItem *item = [[DropdownListItem alloc] initWithItem:@"aaa" itemName:[NSString stringWithFormat:@"%@  driver's license",_state]];
    [stateArray addObject:item];
    
    _licenseListView = [[DropListView alloc] initWithDataSource:stateArray];
    _licenseListView.frame = CGRectMake(YWIDTH_SCALE(60),YHEIGHT_SCALE(244), FUll_VIEW_WIDTH-YWIDTH_SCALE(120), YHEIGHT_SCALE(72));
    _licenseListView.selectedIndex = 0;
    _licenseListView.layer.borderWidth = 1;
    _licenseListView.layer.borderColor = HexRGBAlpha(0x888888, 1).CGColor;
    _licenseListView.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
    _licenseListView.textColor = [UIColor blackColor];
    [secondView addSubview:_licenseListView];
    

    [_stateListView setDropdownListViewSelectedBlock:^(DropListView *dropdownListView) {
        
    }];
    
    UILabel *tipLab = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(_licenseListView.frame)+YHEIGHT_SCALE(20), FUll_VIEW_WIDTH-YWIDTH_SCALE(120), YHEIGHT_SCALE(80))];
    tipLab.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(28)];
    tipLab.textColor = HexRGBAlpha(0x888888, 1);
    tipLab.text = @"Please scan the valid certificate you used when you registered";
    tipLab.numberOfLines = 0;
    [secondView addSubview:tipLab];
    
    UIButton *scanFront = [UIButton buttonWithType:UIButtonTypeCustom];
    scanFront.frame = CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(tipLab.frame)+YHEIGHT_SCALE(40), YWIDTH_SCALE(160), YHEIGHT_SCALE(60));
    [scanFront setTitle:@"Scan Front" forState:UIControlStateNormal];
    scanFront.titleLabel.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
    [scanFront setBackgroundColor:HexRGBAlpha(0xf9f9f9, 1)];
    [scanFront setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    scanFront.layer.cornerRadius = 4;
    scanFront.layer.borderWidth = 1;
    scanFront.layer.borderColor = [UIColor blackColor].CGColor;
    [scanFront addTarget:self action:@selector(scanFrontMethod) forControlEvents:UIControlEventTouchUpInside];
    [secondView addSubview:scanFront];
    
    CGFloat heightScale = (CGFloat)YWIDTH_SCALE(360)/YWIDTH_SCALE(586);
    frontImage = [[UIImageView alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(80), CGRectGetMaxY(scanFront.frame)+YHEIGHT_SCALE(30), FUll_VIEW_WIDTH-YWIDTH_SCALE(160), (FUll_VIEW_WIDTH-YWIDTH_SCALE(160))*heightScale)];
    frontImage.image = [UIImage imageNamed:@"scan"];
    [secondView addSubview:frontImage];
    
    UIButton *scanBack = [UIButton buttonWithType:UIButtonTypeCustom];
    scanBack.frame = CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(frontImage.frame)+YHEIGHT_SCALE(30), YWIDTH_SCALE(160), YHEIGHT_SCALE(60));
    [scanBack setTitle:@"Scan Back" forState:UIControlStateNormal];
    scanBack.titleLabel.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
    [scanBack setBackgroundColor:HexRGBAlpha(0xf9f9f9, 1)];
    [scanBack setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    scanBack.layer.cornerRadius = 4;
    scanBack.layer.borderWidth = 1;
    scanBack.layer.borderColor = [UIColor blackColor].CGColor;
    [scanBack addTarget:self action:@selector(scanBackMethod) forControlEvents:UIControlEventTouchUpInside];
    [secondView addSubview:scanBack];
    
    backImage = [[UIImageView alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(80), CGRectGetMaxY(scanBack.frame)+YHEIGHT_SCALE(30), FUll_VIEW_WIDTH-YWIDTH_SCALE(160), (FUll_VIEW_WIDTH-YWIDTH_SCALE(160))*heightScale)];
    backImage.image = [UIImage imageNamed:@"scan"];
    [secondView addSubview:backImage];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(backImage.frame)+YHEIGHT_SCALE(60), FUll_VIEW_WIDTH-YWIDTH_SCALE(120), YHEIGHT_SCALE(72));
    [nextBtn setBackgroundColor:HexRGBAlpha(0x0390fc, 1)];
    [nextBtn setTitle:@"Next" forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(secondNextBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [secondView addSubview:nextBtn];
    
    secondView.contentSize = CGSizeMake(FUll_VIEW_WIDTH, CGRectGetMaxY(nextBtn.frame)+YHEIGHT_SCALE(40));
}

- (void)scanFrontMethod{
    [self scanDriverLicensePhoto:@"front"];
}

- (void)scanBackMethod{
    [self scanDriverLicensePhoto:@"back"];
}

- (void)secondNextBtnClick{
    if (_frontScan && _backScan) {
        for (int i = 0; i < 2; i ++) {
            NSData *imgData;
            if (i == 0) {
                imgData = UIImageJPEGRepresentation(backImage.image, 0.1f);
                NSString *imgStr = [imgData base64EncodedStringWithOptions:0];
                [self uploadImage:imgStr withIndex:2 withDriverLicenseFront:NO];
            }else{
                imgData = UIImageJPEGRepresentation(frontImage.image, 0.1f);
                NSString *imgStr = [imgData base64EncodedStringWithOptions:0];
                [self uploadImage:imgStr withIndex:2 withDriverLicenseFront:YES];
            }
            
        }
    }
    
}

- (void)scanDriverLicensePhoto:(NSString *)type{
    CameraViewController *vc = [[CameraViewController alloc]init];
    vc.sessionType = @"2";
    vc.ReturnImageBlock = ^(UIImage * _Nonnull image) {
        if ([type isEqualToString:@"back"]) {
            self->backImage.image = image;
            self.backScan = YES;
        }else{
            self->frontImage.image = image;
            self.frontScan = YES;
        }
//        [self driverLicenseComplete];
    };
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

//- (void)driverLicenseComplete{
//    if (frontImage.image && backImage.image) {
//        for (UIButton *btn in secondView.subviews) {
//            if ([btn isKindOfClass: [UIButton class]] && [btn.titleLabel.text isEqualToString:@"Next"]) {
//                [btn setBackgroundColor:HexRGBAlpha(0x0390fc, 1)];
//                btn.userInteractionEnabled = YES;
//            }
//        }
//    }
//}

#pragma mark - third
- (UIView *)thirdView{
    if (!thirdView) {
        thirdView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, FUll_VIEW_WIDTH, FUll_VIEW_HEIGHT-Height_NavBar)];
        thirdView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:thirdView];
        
        titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, YHEIGHT_SCALE(68), FUll_VIEW_WIDTH, YHEIGHT_SCALE(40))];
        titleLab.text = @"Face Recognition";
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(36)];
        [thirdView addSubview:titleLab];
        
        for (int i = 0; i < 4; i ++) {
            UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake((FUll_VIEW_WIDTH-(YWIDTH_SCALE(140)*3+YWIDTH_SCALE(40)))/2+YWIDTH_SCALE(140)*i, CGRectGetMaxY(titleLab.frame)+YHEIGHT_SCALE(48), YWIDTH_SCALE(40), YWIDTH_SCALE(40))];
            if (i < 2) {
                img.image = [UIImage imageNamed:@"box"];;
            }else if (i == 2){
                img.image = [UIImage imageNamed:@"in"];;
            }else{
                img.image = [UIImage imageNamed:@"out"];;
            }
            img.layer.cornerRadius = YWIDTH_SCALE(40)/2;
            img.layer.masksToBounds = YES;
            [thirdView addSubview:img];
            
            if (i < 3) {
                UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(img.frame)+YWIDTH_SCALE(10), img.y+img.height/2-YHEIGHT_SCALE(1), YWIDTH_SCALE(80), YHEIGHT_SCALE(2))];
                if (i <= 1) {
                    line.backgroundColor = HexRGBAlpha(0x075a93, 1);
                }else{
                    line.backgroundColor = HexRGBAlpha(0xc2c2c2, 1);
                }
                [thirdView addSubview:line];
            }
        }
        
        NSString *noinfo =@"Need to perform face recognition, please click start and face the camera.  YES  /  NO  ";
        thirdViewTipLab = [[YYLabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(100), CGRectGetMaxY(titleLab.frame)+YHEIGHT_SCALE(40)+YHEIGHT_SCALE(48)*2, FUll_VIEW_WIDTH-YWIDTH_SCALE(200), YHEIGHT_SCALE(120))];
        thirdViewTipLab.textColor = [UIColor blackColor];
        NSMutableAttributedString *one = [[NSMutableAttributedString alloc] initWithString:noinfo];
        one.yy_font =[UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
        NSRange range = [noinfo rangeOfString:@"  YES  "];
        [one yy_setTextHighlightRange:range color:HexRGBAlpha(0x0090ff, 1) backgroundColor:[UIColor whiteColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            [self faceRecognition];
        }];
        NSRange range2 = [noinfo rangeOfString:@"  NO  "];
        [one yy_setTextHighlightRange:range2 color:HexRGBAlpha(0x0090ff, 1) backgroundColor:[UIColor whiteColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Your identity verification has not been completed. Are you sure to exit?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"No, continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self faceRecognition];
            }];

            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Yes, exit now" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (self.ReturnBlock) {
                    self.ReturnBlock(YES);
                }
            }];
            [alertController addAction:action];
            [alertController addAction:action1];
            [self presentViewController:alertController animated:YES completion:nil];
        }];
        thirdViewTipLab.attributedText = one;
        thirdViewTipLab.numberOfLines = 0;
        thirdViewTipLab.userInteractionEnabled = YES;
        [thirdView addSubview:thirdViewTipLab];

    }
    return thirdView;
}

- (void)faceRecognition{
    CameraViewController *vc = [[CameraViewController alloc]init];
    vc.sessionType = @"1";
    vc.ReturnImageBlock = ^(UIImage * _Nonnull image) {
        self->userImage = image;
        [self configFaceRecognisedSuccessView];
    };
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (void)configFaceRecognisedSuccessView{
    thirdViewTipLab.hidden = YES;
    
    UIImageView *successImage = [[UIImageView alloc]initWithFrame:CGRectMake(FUll_VIEW_WIDTH/2-YWIDTH_SCALE(50), YHEIGHT_SCALE(268), YWIDTH_SCALE(100), YWIDTH_SCALE(100))];
    successImage.image = [UIImage imageNamed:@"complete"];
    [thirdView addSubview:successImage];
    
    UILabel *tipLab = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(successImage.frame)+YHEIGHT_SCALE(48), FUll_VIEW_WIDTH, YHEIGHT_SCALE(40))];
    tipLab.textAlignment = NSTextAlignmentCenter;
    tipLab.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(34)];
    tipLab.text = @"Scan Successfully";
    [thirdView addSubview:tipLab];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(tipLab.frame)+YHEIGHT_SCALE(88), FUll_VIEW_WIDTH-YWIDTH_SCALE(120), YHEIGHT_SCALE(72));
    [nextBtn setBackgroundColor:HexRGBAlpha(0x0390fc, 1)];
    [nextBtn setTitle:@"Next" forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(faceNextBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [thirdView addSubview:nextBtn];
}

- (void)faceNextBtnClick{
    NSData *imgData = UIImageJPEGRepresentation(userImage, 0.1f);
    NSString *imgStr = [imgData base64EncodedStringWithOptions:0];
    [self uploadImage:imgStr withIndex:3 withDriverLicenseFront:YES];
    
}

#pragma mark - fourth
- (UIView *)fourthView{
    if (!fourthView) {
        fourthView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, FUll_VIEW_WIDTH, FUll_VIEW_HEIGHT-Height_NavBar)];
        fourthView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:fourthView];
        
        titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, YHEIGHT_SCALE(68), FUll_VIEW_WIDTH, YHEIGHT_SCALE(40))];
        titleLab.text = @"Verify Mobile Number";
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(36)];
        [fourthView addSubview:titleLab];
        
        for (int i = 0; i < 4; i ++) {
            UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake((FUll_VIEW_WIDTH-(YWIDTH_SCALE(140)*3+YWIDTH_SCALE(40)))/2+YWIDTH_SCALE(140)*i, CGRectGetMaxY(titleLab.frame)+YHEIGHT_SCALE(48), YWIDTH_SCALE(40), YWIDTH_SCALE(40))];
            if (i < 3) {
                img.image = [UIImage imageNamed:@"box"];
            }else if (i == 3){
                img.image = [UIImage imageNamed:@"in"];
            }else{
                img.image = [UIImage imageNamed:@"out"];
            }
            img.layer.cornerRadius = YWIDTH_SCALE(40)/2;
            img.layer.masksToBounds = YES;
            [fourthView addSubview:img];
            
            if (i < 3) {
                UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(img.frame)+YWIDTH_SCALE(10), img.y+img.height/2-YHEIGHT_SCALE(1), YWIDTH_SCALE(80), YHEIGHT_SCALE(2))];
                if (i <= 3) {
                    line.backgroundColor = HexRGBAlpha(0x075a93, 1);
                }else{
                    line.backgroundColor = HexRGBAlpha(0xc2c2c2, 1);
                }
                [fourthView addSubview:line];
            }
        }
        
        codeTF = [[CustomTextfield alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(titleLab.frame)+YHEIGHT_SCALE(88)+YHEIGHT_SCALE(40), FUll_VIEW_WIDTH-YWIDTH_SCALE(120), YHEIGHT_SCALE(72))];
        codeTF.insetX = 10;
        [fourthView addSubview:codeTF];
        
        fourthNextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        fourthNextBtn.frame = CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(codeTF.frame)+YHEIGHT_SCALE(40), FUll_VIEW_WIDTH-YWIDTH_SCALE(120), YHEIGHT_SCALE(72));
        [fourthNextBtn setBackgroundColor:HexRGBAlpha(0x0390fc, 1)];
        [fourthNextBtn setTitle:@"Register" forState:UIControlStateNormal];
        [fourthNextBtn addTarget:self action:@selector(fourthNextBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [fourthView addSubview:fourthNextBtn];
        
        requestTip = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(fourthNextBtn.frame)+YHEIGHT_SCALE(140), FUll_VIEW_WIDTH-YWIDTH_SCALE(120), YHEIGHT_SCALE(80))];
        requestTip.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
        requestTip.textAlignment = NSTextAlignmentCenter;
        requestTip.text = @"It may take a few minutes to receive your code, Still haven't received it?";
        requestTip.numberOfLines = 0;
        [fourthView addSubview:requestTip];
        
        requestbtn = [UIButton buttonWithType:UIButtonTypeCustom];
        requestbtn.frame = CGRectMake((FUll_VIEW_WIDTH-YWIDTH_SCALE(340))/2, CGRectGetMaxY(requestTip.frame)+YHEIGHT_SCALE(60), YWIDTH_SCALE(340), YHEIGHT_SCALE(60));
        [requestbtn setTitle:@"Request new code" forState:UIControlStateNormal];
        [requestbtn setTitleColor:HexRGBAlpha(0x0390fc, 1) forState:UIControlStateNormal];
        [requestbtn addTarget:self action:@selector(requestbtnClick) forControlEvents:UIControlEventTouchUpInside];
        [fourthView addSubview:requestbtn];
        
    }
    return fourthView;
}

- (void)fourthNextBtnClick{
    [VoteDemoHUD showLoding];
    NSString *publicKey = [UserManager userInfo].publicKey;
    if (publicKey.length > 0) {
        NSString *signature = [UserManager userInfo].publicKeySignature;
        //post ro server
        NSString *cerType = [NSString stringWithFormat:@"%@ driver's license",_state];
        NSMutableDictionary *param = [[NSMutableDictionary alloc]initWithDictionary:_requestDic];
        [param setObject:publicKey forKey:@"publicKey"];
        [param setObject:@"1200" forKey:@"appAuthorizationId"];
        [param setObject:_voterID.length>0?_voterID:@"322" forKey:@"voterId"];
        [param setObject:signature forKey:@"signature"];
        [param setObject:cerType.length>0?cerType:@"" forKey:@"certificateType"];
        [param setObject:@"rsa" forKey:@"keyType"];
        [param setObject:[UserManager userInfo].publicKey forKey:@"encryptKey"];
        [HttpTool requestWithUrl:@"register" withDictionary:param success:^(id  _Nullable data) {
            if (self.ReturnForthBlock) {
                self.ReturnForthBlock(YES);
            }
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSString *today = [dateFormatter stringFromDate:[NSDate date]];
            [param setObject:today forKey:@"deviceVerifyDate"];
            [param setObject:today forKey:@"userVerifyDate"];
            [param setObject:[UserManager userInfo].publicKey forKey:@"publicKey"];
            [param setObject:self.userPhoto forKey:@"imageData"];
            [param setObject:signature.length>0?signature:@"" forKey:@"publicKeySignature"];
            [UserManager updateUserInfoWithDictionary:param];
            [self configVerifySuccessView];
            [VoteDemoHUD hideLoding];
        } failure:^(NSString * _Nullable error) {
            [VoteDemoHUD hideLoding];
            [VoteDemoHUD setHUD:error];
        }];
    }
}

- (void)requestbtnClick{
    [self getSMSMessage];
}

- (void)configVerifySuccessView{
    codeTF.hidden = YES;
    fourthNextBtn.hidden = YES;
    requestTip.hidden = YES;
    requestbtn.hidden = YES;
    
    UIImageView *successImage = [[UIImageView alloc]initWithFrame:CGRectMake(FUll_VIEW_WIDTH/2-YWIDTH_SCALE(50), YHEIGHT_SCALE(268), YWIDTH_SCALE(100), YWIDTH_SCALE(100))];
    successImage.image = [UIImage imageNamed:@"complete"];
    [fourthView addSubview:successImage];
    
    UILabel *tipLab = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(successImage.frame)+YHEIGHT_SCALE(48), FUll_VIEW_WIDTH, YHEIGHT_SCALE(40))];
    tipLab.textAlignment = NSTextAlignmentCenter;
    tipLab.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(34)];
    tipLab.text = @"Verification Completed";
    [fourthView addSubview:tipLab];
    
    UILabel *fingerTip = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(150), CGRectGetMaxY(tipLab.frame)+YHEIGHT_SCALE(38), FUll_VIEW_WIDTH-YWIDTH_SCALE(300), YHEIGHT_SCALE(72))];
    fingerTip.text = @"Enable Fingerprint Log In: ";
    fingerTip.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
    fingerTip.textColor = HexRGBAlpha(0x888888, 1);
    [fourthView addSubview:fingerTip];
    [fingerTip sizeToFit];
    
    _touchIDSwitch = [[UISwitch alloc]init];
    _touchIDSwitch.frame=CGRectMake(CGRectGetMaxX(fingerTip.frame), fingerTip.y+fingerTip.height/2-15, 35, 20);
    _touchIDSwitch.transform=CGAffineTransformMakeScale(0.7,0.7);
    _touchIDSwitch.on = NO;
    [self.view addSubview:_touchIDSwitch];
    [_touchIDSwitch setOnTintColor:HexRGBAlpha(0x0390fc, 1)];
    [_touchIDSwitch setThumbTintColor:[UIColor grayColor]];
    [_touchIDSwitch addTarget:self action:@selector(swChange:) forControlEvents:UIControlEventValueChanged];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(_touchIDSwitch.frame)+YHEIGHT_SCALE(88), FUll_VIEW_WIDTH-YWIDTH_SCALE(120), YHEIGHT_SCALE(72));
    [nextBtn setBackgroundColor:HexRGBAlpha(0x0390fc, 1)];
    [nextBtn setTitle:@"Next" forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(ballotBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [fourthView addSubview:nextBtn];
    
}

- (void)ballotBtnClick{
    BallotsViewController *vc = [[BallotsViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) swChange:(UISwitch*) sw{
    if(sw.on==YES){
        [self touchIDRecognition:YES];
    }else{
        [self touchIDRecognition:NO];
    }
}

- (void)touchIDRecognition:(BOOL)recog{
    if(NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0)
    {
        _touchIDSwitch.on =!recog;
        [VoteDemoHUD setHUD:@"TouchID is not supported in the system version"];
    }else{
        LAContext *laContext = [[LAContext alloc] init];
        laContext.localizedFallbackTitle = @"";
        NSError *error;
        if ([laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error]) {
            [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"Please verify fingerprint" reply:^(BOOL success, NSError *error) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (success) {
                        if (recog) {
                            NSDictionary *userDic = @{@"canTouchIDVerify":@"yes"};
                            [UserManager updateUserInfoWithDictionary:userDic];
                        }else{
                            NSDictionary *userDic = @{@"canTouchIDVerify":@"no"};
                            [UserManager updateUserInfoWithDictionary:userDic];
                        }
                        self.touchIDSwitch.on = recog;
                        [VoteDemoHUD setHUD:@"Successfully"];
                    }else{
                        self.touchIDSwitch.on =!recog;
                    }
                });
            }];
        }else {
            switch (error.code) {
                case LAErrorTouchIDNotEnrolled:
                {
                    _touchIDSwitch.on =!recog;
                    [VoteDemoHUD setHUD:@"TouchID is not enrolled"];
                    NSLog(@"TouchID is not enrolled");
                    break;
                }
                case LAErrorPasscodeNotSet:
                {
                    _touchIDSwitch.on =!recog;
                    [VoteDemoHUD setHUD:@"A passcode has not been set"];
                    NSLog(@"A passcode has not been set");
                    break;
                }
                default:
                {
                    _touchIDSwitch.on =!recog;
                    [VoteDemoHUD setHUD:@"TouchID not available"];
                    NSLog(@"TouchID not available");
                    break;
                }
            }
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    for (UITextField *tf in fourthView.subviews) {
        if ([tf isKindOfClass:[UITextField class]]) {
            [tf resignFirstResponder];
        }
    }
}

#pragma mark - UploadImage

- (void)uploadImage:(NSString *)imageBaseStr withIndex:(int)index withDriverLicenseFront:(BOOL)isFront{
    
    NSString *publicKey = [UserManager userInfo].publicKey;
    if (publicKey.length > 0 && imageBaseStr.length>0 ) {
        publicKey = [publicKey stringByReplacingOccurrencesOfString:@"-----BEGIN PUBLIC KEY-----" withString:@""];
        publicKey = [publicKey stringByReplacingOccurrencesOfString:@"-----END PUBLIC KEY-----" withString:@""];
        NSDictionary *dic = @{@"publicKey":publicKey,
                              @"voterID":@"",
                              @"type":@"Signature",
                              @"image":imageBaseStr,
                              @"signature":[UserManager userInfo].publicKeySignature,
                              @"keyType":@"rsa"
        };
        NSMutableDictionary *para = [[NSMutableDictionary alloc]initWithDictionary:dic];
        if (index == 2) {
            if (isFront) {
                [para setObject:@"CertificateFront" forKey:@"type"];
            }else{
                [para setObject:@"CertificateBack" forKey:@"type"];
            }
        }else if (index == 3){
            [para setObject:@"FaceRecognition" forKey:@"type"];
        }
        [VoteDemoHUD showLoding];
        
        [HttpTool requestWithUrl:@"updateimage" withDictionary:dic success:^(id  _Nullable data) {
            NSString *ret = [NSString stringWithFormat:@"%@",data[@"ret"]];
            if ([ret isEqualToString:@"1"]) {
                if (index == 1) {
                    NSString *iamgeID = [NSString stringWithFormat:@"%@",data[@"id"]];
                    if (self.ReturnFirstBlock) {
                        self.ReturnFirstBlock(1, self.firstNameTF.text, self.middleNameTF.text, self.lastNameTF.text, self.nameSuffixTF.text, self.numberTF.text, self.emailTF.text, self.addressTF.text,iamgeID,self.stateListView.selectedItem.itemName,self.countyListView.selectedItem.itemName,self.precintNO.text);
                    }
                    [self->firstView setContentOffset:CGPointMake(0, 0) animated:NO];
                }else if (index == 2){
                    if (isFront) {
                        self->driverFrontImageID = [NSString stringWithFormat:@"%@",data[@"id"]];
                        if (self.ReturnSecondBlock) {
                            self.ReturnSecondBlock(2, self->driverBackImageID, self->driverFrontImageID);
                        }
                        [self->secondView setContentOffset:CGPointMake(0, 0) animated:NO];
                        [VoteDemoHUD hideLoding];
                    }else{
                        self->driverBackImageID = [NSString stringWithFormat:@"%@",data[@"id"]];
                    }
                }else{
                    self->userImageID = [NSString stringWithFormat:@"%@",data[@"id"]];
                    if (self.ReturnThirdBlock) {
                        self.ReturnThirdBlock(3, self->userImageID,imageBaseStr);
                    }
                    [self getSMSMessage];
                    [VoteDemoHUD hideLoding];
                }
            }
            [VoteDemoHUD hideLoding];
        } failure:^(NSString * _Nullable error) {
            [VoteDemoHUD setHUD:error];
            [VoteDemoHUD hideLoding];
        }];
    }
}

- (void)getSMSMessage{
    NSString *publicKey = [UserManager userInfo].publicKey;
    if (publicKey.length > 0) {
        NSString *cellphone = [NSString stringWithFormat:@"%@",_requestDic[@"cellphone"]];
        NSDictionary *dic = @{@"publicKey":publicKey,
                              @"to":cellphone.length>0?cellphone:@"",
                              @"message":@"",
                              @"signature":[UserManager userInfo].publicKeySignature,
                              @"keyType":@"rsa"
        };
        [HttpTool requestWithUrl:@"sendsmsmessage" withDictionary:dic success:^(id  _Nullable data) {

        } failure:^(NSString * _Nullable error) {

        }];
    }
}

@end
