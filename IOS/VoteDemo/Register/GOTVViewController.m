

#import "GOTVViewController.h"

@interface GOTVViewController (){
}
@property (nonatomic,retain)XLSlideSwitch *titleView;
@property (nonatomic,retain)NSMutableDictionary *param;
@property (nonatomic,assign)BOOL isRegister;
@end

@implementation GOTVViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _param = [[NSMutableDictionary alloc]init];
    [self configSlideView];
}

- (void)configSlideView{
    
    UIView *navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, FUll_VIEW_WIDTH, Height_NavBar)];
    navView.backgroundColor = HexRGBAlpha(0x075a93, 1);
    [self.view addSubview:navView];
    
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, Height_StatusBar, FUll_VIEW_WIDTH, Height_NavBar-Height_StatusBar)];
    titleLab.text = @"Verifications";
    titleLab.textColor = HexRGBAlpha(0xffffff, 1);
    titleLab.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(36)];
    titleLab.textAlignment = NSTextAlignmentCenter;
    [navView addSubview:titleLab];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(YWIDTH_SCALE(30), Height_StatusBar+YHEIGHT_SCALE(24), YWIDTH_SCALE(40), YHEIGHT_SCALE(40));
    backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [backBtn setBackgroundImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
    [backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    NSMutableArray *views = [[NSMutableArray alloc]init];
    NSArray *titleArray = @[@"1",@"1",@"1",@"1"];
    for (int i = 0; i < 4; i ++) {
        VoterRegisterViewController *vc = [[VoterRegisterViewController alloc]init];
        vc.step = [NSString stringWithFormat:@"%d",i+1];
        vc.voterID = _voterID.length>0?_voterID:@"";
        vc.ReturnFirstBlock = ^(NSInteger index, NSString * _Nonnull firstName, NSString * _Nonnull middleName, NSString * _Nonnull lastName, NSString * _Nonnull nameSuffix, NSString * _Nonnull number, NSString * _Nonnull emai, NSString * _Nonnull address, NSString * _Nonnull signature, NSString * _Nonnull state, NSString * _Nonnull county, NSString * _Nonnull precintNumber) {
            [self.param setObject:firstName forKey:@"firstName"];
            [self.param setObject:middleName forKey:@"middleName"];
            [self.param setObject:lastName forKey:@"lastName"];
            [self.param setObject:nameSuffix forKey:@"nameSuffix"];
            [self.param setObject:number forKey:@"cellphone"];
            [self.param setObject:emai forKey:@"email"];
            [self.param setObject:address forKey:@"address"];
            [self.param setObject:signature forKey:@"images"];
            StateInfo *staInfo = [StateInfo getStateInfoWithName:state];
            [self.param setObject:staInfo.shortName forKey:@"state"];
            CountyInfo *couInfo = [CountyInfo getCountyInfoWithName:county];
            [self.param setObject:couInfo.code forKey:@"county"];
            [self.param setObject:precintNumber forKey:@"precinctNumber"];
            VoterRegisterViewController *vc = (VoterRegisterViewController *)[self.titleView.viewControllers lastObject];
            vc.requestDic = self.param;
            vc.state = staInfo.name;
            VoterRegisterViewController *vc2 = (VoterRegisterViewController *)self.titleView.viewControllers[index];
            vc2.state = state;
            self.titleView.selectedIndex = index;
        };
        vc.ReturnSecondBlock = ^(NSInteger index, NSString * _Nonnull backID, NSString * _Nonnull frontID) {
            NSString *ids = [self.param objectForKey:@"images"];
            NSString *images = [NSString stringWithFormat:@"%@,%@,%@",ids,backID,frontID];
            [self.param setObject:images forKey:@"images"];
            self.titleView.selectedIndex = index;
        };
        vc.ReturnThirdBlock = ^(NSInteger index, NSString * _Nonnull imageID, NSString * _Nonnull imageData) {
            NSString *ids = [self.param objectForKey:@"images"];
            NSString *images = [NSString stringWithFormat:@"%@,%@",ids,imageID];
            [self.param setObject:images forKey:@"images"];
            VoterRegisterViewController *vc = (VoterRegisterViewController *)self.titleView.viewControllers[index];
            vc.userPhoto = imageData;
            self.titleView.selectedIndex = index;
        };
        vc.ReturnForthBlock = ^(BOOL isRegister) {
            self.isRegister = isRegister;
        };
        vc.ReturnBlock = ^(BOOL isBack) {
            [self.navigationController popViewControllerAnimated:YES];
        };
        [views addObject:vc];
    }
    self.titleView = [[XLSlideSwitch alloc] initWithFrame:CGRectMake(0, Height_NavBar, FUll_VIEW_WIDTH, FUll_VIEW_HEIGHT-Height_NavBar) Titles:titleArray viewControllers:views withType:2];
    self.titleView.selectedIndex = 0;
    [self.titleView showInViewController:self];
}

- (void)backClick{
    if (self.titleView.selectedIndex > 0 && !_isRegister) {
        self.titleView.selectedIndex = self.titleView.selectedIndex-1;
    }else if (_isRegister){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
