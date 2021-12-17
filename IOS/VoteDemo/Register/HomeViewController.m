

#import "HomeViewController.h"

@interface HomeViewController ()<UITextFieldDelegate>{
    UILabel *tipLab;
    UIButton *registerBtn;
    CustomTextfield *voterIDTF;
    UIView *backView;
}
@property (nonatomic,retain)DropListView *stateListView;
@property (nonatomic,retain)DropListView *countyListView;
@end

@implementation HomeViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(backClick)];
}

- (void)backClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"GOTV";
    [self configMainView];
}

- (void)configMainView{
    UILabel *welcom = [[UILabel alloc]initWithFrame:CGRectMake(0, YHEIGHT_SCALE(114)+Height_NavBar, FUll_VIEW_WIDTH, YHEIGHT_SCALE(50))];
    welcom.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(46)];
    welcom.textAlignment = NSTextAlignmentCenter;
    welcom.text = @"Welcome!";
    [self.view addSubview:welcom];
    
    voterIDTF = [[CustomTextfield alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(welcom.frame)+YHEIGHT_SCALE(56), FUll_VIEW_WIDTH-YWIDTH_SCALE(120), YHEIGHT_SCALE(80))];
    voterIDTF.insetX = 10;
    voterIDTF.delegate = self;
    voterIDTF.placeholder = @"Enter Voter ID";
    voterIDTF.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:voterIDTF];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(voterIDTF.frame)+YHEIGHT_SCALE(64), FUll_VIEW_WIDTH-YWIDTH_SCALE(120), YHEIGHT_SCALE(72));
    [nextBtn setTitle:@"Next" forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
    nextBtn.layer.cornerRadius = 4;
    nextBtn.layer.masksToBounds = YES;
    [nextBtn setBackgroundColor:HexRGBAlpha(0x0390fc, 1)];
    [nextBtn addTarget:self action:@selector(ballotClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
    
    if ([UserManager userInfo].accessToken.length <= 0) {
        tipLab = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(nextBtn.frame)+YHEIGHT_SCALE(140), FUll_VIEW_WIDTH, YHEIGHT_SCALE(40))];
        tipLab.textAlignment = NSTextAlignmentCenter;
        tipLab.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
        tipLab.text = @"Don't have your Voter ID?";
        [self.view addSubview:tipLab];
        
        registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        registerBtn.frame = CGRectMake(0, CGRectGetMaxY(tipLab.frame)+YHEIGHT_SCALE(60), FUll_VIEW_WIDTH, YHEIGHT_SCALE(40));
        [registerBtn setTitle:@"Register Now" forState:UIControlStateNormal];
        registerBtn.titleLabel.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
        [registerBtn setTitleColor:HexRGBAlpha(0x0390fc, 1) forState:UIControlStateNormal];
        [registerBtn addTarget:self action:@selector(registerClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:registerBtn];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    for (UITextField *tx in self.view.subviews) {
        if ([tx isKindOfClass:[UITextField class]]) {
            [tx resignFirstResponder];
        }
    }
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [voterIDTF resignFirstResponder];
}

- (void)registerClick{
    [self configSelectView];
}

- (void)ballotClick{
    if (voterIDTF.text.length > 0) {
        [voterIDTF resignFirstResponder];
        GOTVViewController *vc = [[GOTVViewController alloc]init];
        vc.voterID = voterIDTF.text;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [VoteDemoHUD setHUD:@"Please Enter Your Voter ID"];
    }
}

- (void)configSelectView{
    backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, FUll_VIEW_WIDTH, FUll_VIEW_HEIGHT)];
    backView.backgroundColor = [UIColor colorWithRed:0/255 green:0/255 blue:0/255 alpha:0.5];
    [[UIApplication sharedApplication].keyWindow addSubview:backView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backViewClick)];
    [backView addGestureRecognizer:tap];
    
    UIView *selectView = [[UIView alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(50), FUll_VIEW_HEIGHT/2-YHEIGHT_SCALE(200), FUll_VIEW_WIDTH-YWIDTH_SCALE(100), YHEIGHT_SCALE(400))];
    selectView.backgroundColor = [UIColor whiteColor];
    [backView addSubview:selectView];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectViewClick)];
    [selectView addGestureRecognizer:tap2];
    
    NSString *tipStr = @"Please select your state and county, we will help you find the entrance to registration quickly.";
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGRect rect = [tipStr boundingRectWithSize:CGSizeMake(FUll_VIEW_WIDTH-YWIDTH_SCALE(240), CGFLOAT_MAX) options:options attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:YFONTSIZEFROM_PX(32)]} context:nil];
    UILabel *tipLab = [[UILabel alloc]init];
    tipLab.frame = CGRectMake(YWIDTH_SCALE(40), YHEIGHT_SCALE(30), selectView.width-YWIDTH_SCALE(80), rect.size.height);
    tipLab.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(32)];
    tipLab.textColor = HexRGBAlpha(0x888888, 1);
    tipLab.text = tipStr;
    tipLab.numberOfLines = 0;
    [selectView addSubview:tipLab];
    
    NSArray *stateInfoArray = [StateInfo getStateArray];
    NSMutableArray *stateArray = [[NSMutableArray alloc]init];
    DropdownListItem *item = [[DropdownListItem alloc] initWithItem:@"0123" itemName:@"Your State"];
    [stateArray addObject:item];
    for (int i = 0; i < stateInfoArray.count; i ++) {
        StateInfo *info = stateInfoArray[i];
        DropdownListItem *item = [[DropdownListItem alloc] initWithItem:[NSString stringWithFormat:@"%@",info.code] itemName:info.name];
        [stateArray addObject:item];
    }
    CGFloat allWidth = (FUll_VIEW_WIDTH-YWIDTH_SCALE(240))/2;
    _stateListView = [[DropListView alloc] initWithDataSource:stateArray];
    _stateListView.frame = CGRectMake(YWIDTH_SCALE(40), CGRectGetMaxY(tipLab.frame)+YHEIGHT_SCALE(30), allWidth, YHEIGHT_SCALE(72));
    _stateListView.selectedIndex = 0;
    _stateListView.layer.borderWidth = 1;
    _stateListView.layer.borderColor = HexRGBAlpha(0x888888, 1).CGColor;
    _stateListView.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
    _stateListView.textColor = [UIColor blackColor];
    [selectView addSubview:_stateListView];
    
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
    
    NSMutableArray *countyArray = [[NSMutableArray alloc]init];
    DropdownListItem *item2 = [[DropdownListItem alloc]initWithItem:@"0123" itemName:@"Your County"];
    [countyArray addObject:item2];
    _countyListView = [[DropListView alloc] initWithDataSource:countyArray];
    _countyListView.frame = CGRectMake(CGRectGetMaxX(_stateListView.frame)+YWIDTH_SCALE(20), _stateListView.y, allWidth+YWIDTH_SCALE(40), YHEIGHT_SCALE(72));
    _countyListView.selectedIndex = 0;
    _countyListView.layer.borderWidth = 1;
    _countyListView.layer.borderColor = HexRGBAlpha(0x888888, 1).CGColor;
    _countyListView.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
    _countyListView.textColor = [UIColor blackColor];
    [selectView addSubview:_countyListView];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(YWIDTH_SCALE(40), CGRectGetMaxY(_countyListView.frame)+YHEIGHT_SCALE(30), tipLab.width, YHEIGHT_SCALE(72));
    [nextBtn setBackgroundColor:HexRGBAlpha(0x0390fc, 1)];
    [nextBtn setTitle:@"GO" forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [selectView addSubview:nextBtn];
    
    selectView.height = CGRectGetMaxY(nextBtn.frame)+YHEIGHT_SCALE(40);
    selectView.layer.cornerRadius = 6;
}

- (void)nextBtnClick{
    if ([_stateListView.selectedItem.itemName isEqualToString:@"Your State"]) {
        [VoteDemoHUD setHUD:@"Please select your state"];
    }else if ([_stateListView.selectedItem.itemName isEqualToString:@"Your County"]){
        [VoteDemoHUD setHUD:@"Please select your county"];
    }else{
        StateInfo *state = [StateInfo getStateInfoWithName:_stateListView.selectedItem.itemName];
        RegisterLinkModel *model = [RegisterLinkModel getRegisterLinkWithState:state.shortName withCounty:_countyListView.selectedItem.itemId];
        if (model.RegisterLink.length > 0) {
            NSLog(@"%@",model.RegisterLink);
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.RegisterLink] options:@{} completionHandler:^(BOOL success) {

                }];
            } else {

            }
        }
    }
}

- (void)selectViewClick{
}

- (void)backViewClick{
    [backView removeFromSuperview];
}



@end
